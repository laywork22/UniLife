import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/date_utils.dart';
import '../data/models/enums.dart';
import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskRepository? repository})
      : _repo = repository ?? TaskRepository();

  final TaskRepository _repo;
  final _uuid = const Uuid();

  List<Task> _all = const [];
  bool _loading = false;

  List<Task> get all => _all;
  bool get isLoading => _loading;

  List<Task> get today {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59);
    return _all.where((t) {
      // I task completati restano visibili se sono stati chiusi oggi.
      if (t.status == TaskStatus.completato) {
        return t.completedAt != null &&
            AppDateUtils.isSameDay(t.completedAt!, now);
      }
      // Task ancora aperti: senza scadenza, oppure scaduti / in scadenza oggi.
      if (t.dueDate == null) return true;
      return !t.dueDate!.isAfter(endOfToday);
    }).toList()
      ..sort((a, b) {
        // I pending precedono i completati; a parità di stato, priorità decrescente.
        if (a.status != b.status) {
          return a.status == TaskStatus.daCompletare ? -1 : 1;
        }
        return b.priority.index.compareTo(a.priority.index);
      });
  }

  List<Task> byCourse(String courseId) =>
      _all.where((t) => t.courseId == courseId).toList();

  List<Task> byPriority(Priority p) =>
      _all.where((t) => t.priority == p).toList();

  Task? byId(String id) {
    for (final t in _all) {
      if (t.id == id) return t;
    }
    return null;
  }

  int get completedToday {
    final now = DateTime.now();
    return _all.where((t) {
      if (t.completedAt == null) return false;
      return AppDateUtils.isSameDay(t.completedAt!, now);
    }).length;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _all = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<Task> add({
    required String title,
    String? description,
    String? courseId,
    Priority priority = Priority.media,
    DateTime? dueDate,
    int estimatedMinutes = 0,
    bool isGoal = false,
  }) async {
    final t = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      courseId: courseId,
      priority: priority,
      dueDate: dueDate,
      estimatedMinutes: estimatedMinutes,
      isGoal: isGoal,
    );
    await _repo.insert(t);
    await load();
    return t;
  }

  Future<void> edit(Task t) async {
    await _repo.update(t);
    await load();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> toggleComplete(String id) async {
    await _repo.toggleComplete(id);
    await load();
  }
}
