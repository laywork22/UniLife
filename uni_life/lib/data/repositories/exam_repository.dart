import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/database_helper.dart';
import '../models/enums.dart';
import '../models/exam.dart';

/// Repository CRUD + query per Exam (UC-2, UC-6, UC-10, UC-11).
class ExamRepository {
  ExamRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<List<Exam>> getAll() async {
    final db = await _helper.database;
    final rows =
        await db.query(AppConstants.tableExams, orderBy: 'date ASC');
    return rows.map(Exam.fromMap).toList();
  }

  Future<Exam?> getById(String id) async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableExams,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Exam.fromMap(rows.first);
  }

  Future<List<Exam>> getByCourse(String courseId) async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableExams,
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'date ASC',
    );
    return rows.map(Exam.fromMap).toList();
  }

  /// Esami prossimi (data >= oggi e status = prossimo) ordinati per data.
  Future<List<Exam>> getUpcoming({int? limit}) async {
    final db = await _helper.database;
    final today = DateTime.now().toIso8601String();
    final rows = await db.query(
      AppConstants.tableExams,
      where: 'date >= ? AND status = ?',
      whereArgs: [today, ExamStatus.prossimo.name],
      orderBy: 'date ASC',
      limit: limit,
    );
    return rows.map(Exam.fromMap).toList();
  }

  Future<List<Exam>> filterByStatus(ExamStatus status) async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableExams,
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'date ASC',
    );
    return rows.map(Exam.fromMap).toList();
  }

  Future<void> insert(Exam e) async {
    final db = await _helper.database;
    await db.insert(
      AppConstants.tableExams,
      e.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Exam e) async {
    final db = await _helper.database;
    await db.update(
      AppConstants.tableExams,
      e.toMap(),
      where: 'id = ?',
      whereArgs: [e.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete(
      AppConstants.tableExams,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
