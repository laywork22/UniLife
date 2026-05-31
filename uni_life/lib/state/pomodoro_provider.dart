import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../data/models/enums.dart';
import '../data/models/study_session.dart';
import '../data/models/task.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/task_repository.dart';
import '../services/notification_service.dart';

enum PomodoroState { idle, running, paused, done }

/// Stato del Pomodoro (UC-9). Gestisce il timer, l'entità collegata
/// (task / corso) e, al termine della sessione, **persiste una
/// `StudySession`** nel database con i minuti effettivamente svolti.
/// Se è collegato un task ne aggiorna anche il campo `actualMinutes`.
class PomodoroProvider extends ChangeNotifier {
  PomodoroProvider({
    NotificationService? notifications,
    SessionRepository? sessionRepository,
    TaskRepository? taskRepository,
    this.onProgressSaved,
  })  : _notifications = notifications ?? NotificationService.instance,
        _sessionRepo = sessionRepository ?? SessionRepository(),
        _taskRepo = taskRepository ?? TaskRepository();

  final NotificationService _notifications;
  final SessionRepository _sessionRepo;
  final TaskRepository _taskRepo;

  final Future<void> Function()? onProgressSaved;

  final _uuid = const Uuid();

  Timer? _ticker;
  int _remainingSeconds = AppConstants.pomodoroMinutes * 60;
  int _totalSeconds = AppConstants.pomodoroMinutes * 60;
  PomodoroState _state = PomodoroState.idle;
  Task? _linkedTask;
  String? _linkedCourseId;

  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  PomodoroState get state => _state;
  Task? get linkedTask => _linkedTask;
  String? get linkedCourseId => _linkedCourseId;

  double get progress =>
      _totalSeconds == 0 ? 0 : 1 - (_remainingSeconds / _totalSeconds);

  String get display {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void selectTask(Task? t) {
    _linkedTask = t;
    notifyListeners();
  }

  void selectCourse(String? courseId) {
    _linkedCourseId = courseId;
    notifyListeners();
  }

  void setDurationMinutes(int minutes) {
    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;
    notifyListeners();
  }

  void start() {
    if (_state == PomodoroState.running) return;
    _state = PomodoroState.running;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void pause() {
    if (_state != PomodoroState.running) return;
    _ticker?.cancel();
    _state = PomodoroState.paused;
    notifyListeners();
  }

  void resume() => start();

  void stop({bool saveProgress = false}) {
    _ticker?.cancel();
    if (saveProgress) {
      final elapsed = _totalSeconds - _remainingSeconds;
      // Fire and forget: la UI non blocca sull'insert.
      unawaited(_persistProgress(elapsed ~/ 60));
    }
    _state = PomodoroState.idle;
    _remainingSeconds = _totalSeconds;
    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    _remainingSeconds = _totalSeconds;
    _state = PomodoroState.idle;
    notifyListeners();
  }

  void _tick() {
    if (_remainingSeconds <= 1) {
      _ticker?.cancel();
      _remainingSeconds = 0;
      _state = PomodoroState.done;
      unawaited(_persistProgress(_totalSeconds ~/ 60));
      _notifications.showPomodoroDone();
      notifyListeners();
      return;
    }
    _remainingSeconds--;
    notifyListeners();
  }

  Future<void> _persistProgress(int minutes) async {
    if (minutes <= 0) return;
    try {
      final endTime = DateTime.now();
      final startTime = endTime.subtract(Duration(minutes: minutes));
      final today = DateTime(endTime.year, endTime.month, endTime.day);

      final session = StudySession(
        id: _uuid.v4(),
        title: _linkedTask?.title ?? 'Sessione Pomodoro',
        courseId: _linkedCourseId,
        date: today,
        startTime: startTime,
        endTime: endTime,
        type: SessionType.studio,
        isCompleted: true,
        actualMinutes: minutes,
      );
      await _sessionRepo.insert(session);

      if (_linkedTask != null) {
        final updated = _linkedTask!.copyWith(
          actualMinutes: _linkedTask!.actualMinutes + minutes,
        );
        await _taskRepo.update(updated);
        _linkedTask = updated;
      }

      await onProgressSaved?.call();
    } catch (_) {

    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
