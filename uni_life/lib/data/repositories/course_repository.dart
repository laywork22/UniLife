import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/database_helper.dart';
import '../models/course.dart';

/// Repository CRUD per Course (UC-1, UC-6, UC-10, UC-11).
class CourseRepository {
  CourseRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<List<Course>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableCourses,
      orderBy: 'nome COLLATE NOCASE ASC',
    );
    return rows.map(Course.fromMap).toList();
  }

  Future<Course?> getById(String id) async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableCourses,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Course.fromMap(rows.first);
  }

  Future<void> insert(Course c) async {
    final db = await _helper.database;
    await db.insert(
      AppConstants.tableCourses,
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Course c) async {
    final db = await _helper.database;
    await db.update(
      AppConstants.tableCourses,
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete(
      AppConstants.tableCourses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Ricerca su nome o docente (case-insensitive).
  Future<List<Course>> search(String query) async {
    if (query.trim().isEmpty) return getAll();
    final db = await _helper.database;
    final q = '%${query.trim()}%';
    final rows = await db.query(
      AppConstants.tableCourses,
      where: 'nome LIKE ? OR docente LIKE ?',
      whereArgs: [q, q],
      orderBy: 'nome COLLATE NOCASE ASC',
    );
    return rows.map(Course.fromMap).toList();
  }
}
