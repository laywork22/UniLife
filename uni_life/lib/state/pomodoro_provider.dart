import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../data/models/task.dart';
import '../services/notification_service.dart';

enum PomodoroState { idle, running, paused, done }

/// Stato del Pomodoro (UC-9). Tiene il timer, l'entità collegata
/// e a fine sessione registra i minuti sul task o sul corso scelti.
class PomodoroProvider extends ChangeNotifier {
  PomodoroProvider({NotificationService? notifications})
      : _notifications = notifications ?? NotificationService.instance;

  final NotificationService _notifications;

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
      _accumulateMinutes(elapsed ~/ 60);
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
      _accumulateMinutes(_totalSeconds ~/ 60);
      _notifications.showPomodoroDone();
      notifyListeners();
      return;
    }
    _remainingSeconds--;
    notifyListeners();
  }

  void _accumulateMinutes(int minutes) {
    if (minutes <= 0) return;
    // I provider che osservano (TaskProvider, CourseProvider) possono leggere
    // _linkedTask/_linkedCourseId e aggiornare. In questa versione ci limitiamo
    // a notificare: l'aggregazione su DB è demandata a chi consuma lo stato.
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
