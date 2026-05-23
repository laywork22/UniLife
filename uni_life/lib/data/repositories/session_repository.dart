import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/database_helper.dart';
import '../models/study_session.dart';

/// Repository CRUD + query per StudySession (UC-3, UC-5, UC-9).
class SessionRepository {
  SessionRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<List<StudySession>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableSessions,
      orderBy: 'start_time ASC',
    );
    return rows.map(StudySession.fromMap).toList();
  }

  Future<StudySession?> getById(String id) async {
    final db = await _helper.database;
    final rows = await db.query(
      AppConstants.tableSessions,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : StudySession.fromMap(rows.first);
  }

  Future<List<StudySession>> getByWeek(DateTime weekStart) async {
    final db = await _helper.database;
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    final rows = await db.query(
      AppConstants.tableSessions,
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'start_time ASC',
    );
    return rows.map(StudySession.fromMap).toList();
  }

  Future<List<StudySession>> getByDay(DateTime day) async {
    final db = await _helper.database;
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await db.query(
      AppConstants.tableSessions,
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'start_time ASC',
    );
    return rows.map(StudySession.fromMap).toList();
  }

  Future<void> insert(StudySession s) async {
    final db = await _helper.database;
    await db.insert(
      AppConstants.tableSessions,
      s.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(StudySession s) async {
    final db = await _helper.database;
    await db.update(
      AppConstants.tableSessions,
      s.toMap(),
      where: 'id = ?',
      whereArgs: [s.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _helper.database;
    await db.delete(
      AppConstants.tableSessions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markCompleted(String id, int minutes) async {
    final db = await _helper.database;
    await db.update(
      AppConstants.tableSessions,
      {'is_completed': 1, 'actual_minutes': minutes},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
