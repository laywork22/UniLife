import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/database_helper.dart';
import '../models/enums.dart';
import '../models/task.dart';

/// Repository CRUD + query per Task (UC-4, UC-5).
class TaskRepository {
  TaskRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<List<Task>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableTasks,
      orderBy: 'COALESCE(due_date, "9999") ASC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<Task?> getById(String id) async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableTasks,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Task.fromMap(rows.first);
  }

  Future<List<Task>> getToday() async {
    final db = await _helper.database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final rows = await db.query(
      AppConstants.tableTasks,
      where: '(due_date >= ? AND due_date < ?) OR status = ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
        TaskStatus.daCompletare.name,
      ],
      orderBy: 'priority DESC, due_date ASC',
      limit: 8,
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<List<Task>> getByCourse(String courseId) async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableTasks,
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'COALESCE(due_date, "9999") ASC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<List<Task>> getByPriority(Priority p) async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableTasks,
      where: 'priority = ?',
      whereArgs: [p.name],
      orderBy: 'COALESCE(due_date, "9999") ASC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<void> insert(Task t) async {
    final db = await _helper.database;
    await db.insert(
      AppConstants.tableTasks,
      t.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Task t) async {
    final db = await _helper.database;
    await db.update(
      AppConstants.tableTasks,
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete(
      AppConstants.tableTasks,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Task> toggleComplete(String id) async {
    final t = await getById(id);
    if (t == null) {
      throw StateError('Task $id non trovato');
    }
    final isDone = t.status == TaskStatus.completato;
    final updated = t.copyWith(
      status: isDone ? TaskStatus.daCompletare : TaskStatus.completato,
      completedAt: isDone ? null : DateTime.now(),
      clearCompletedAt: isDone,
    );
    await update(updated);
    return updated;
  }
}
