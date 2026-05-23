import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/date_utils.dart';
import '../data/models/enums.dart';
import '../data/models/study_session.dart';
import '../data/repositories/session_repository.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({SessionRepository? repository})
      : _repo = repository ?? SessionRepository();

  final SessionRepository _repo;
  final _uuid = const Uuid();

  List<StudySession> _all = const [];
  bool _loading = false;
  DateTime _weekStart = AppDateUtils.startOfWeek(DateTime.now());

  List<StudySession> get all => _all;
  bool get isLoading => _loading;
  DateTime get weekStart => _weekStart;

  List<StudySession> get currentWeek {
    final end = _weekStart.add(const Duration(days: 7));
    return _all
        .where((s) => !s.date.isBefore(_weekStart) && s.date.isBefore(end))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<StudySession> byDay(DateTime day) {
    return _all.where((s) => AppDateUtils.isSameDay(s.date, day)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _all = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  void goToPreviousWeek() {
    _weekStart = _weekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void goToNextWeek() {
    _weekStart = _weekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  void goToThisWeek() {
    _weekStart = AppDateUtils.startOfWeek(DateTime.now());
    notifyListeners();
  }

  StudySession? byId(String id) {
    for (final s in _all) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<StudySession> add({
    required String title,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    SessionType type = SessionType.studio,
    String? courseId,
    String? examId,
    String? notes,
  }) async {
    final s = StudySession(
      id: _uuid.v4(),
      title: title,
      date: date,
      startTime: startTime,
      endTime: endTime,
      type: type,
      courseId: courseId,
      examId: examId,
      notes: notes,
    );
    await _repo.insert(s);
    await load();
    return s;
  }

  Future<void> edit(StudySession s) async {
    await _repo.update(s);
    await load();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> markCompleted(String id, int minutes) async {
    await _repo.markCompleted(id, minutes);
    await load();
  }
}
