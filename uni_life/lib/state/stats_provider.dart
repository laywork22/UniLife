import 'package:flutter/foundation.dart';

import '../data/models/enums.dart';
import 'course_provider.dart';
import 'exam_provider.dart';
import 'task_provider.dart';

/// Aggrega altri provider per la dashboard (UC-7).
class StatsProvider extends ChangeNotifier {
  StatsProvider({
    required CourseProvider courses,
    required ExamProvider exams,
    required TaskProvider tasks,
  })  : _courses = courses,
        _exams = exams,
        _tasks = tasks {
    _courses.addListener(_onChange);
    _exams.addListener(_onChange);
    _tasks.addListener(_onChange);
  }

  final CourseProvider _courses;
  final ExamProvider _exams;
  final TaskProvider _tasks;

  void _onChange() => notifyListeners();


  int get cfuAcquisiti {
    int total = 0;
    for (final c in _courses.all) {
      if (_exams.latestPassedGrade(c.id) != null) {
        total += c.cfu;
      }
    }
    return total + _orphanCfu;
  }

  int get cfuTotali =>
      _courses.all.fold<int>(0, (acc, c) => acc + c.cfu) + _orphanCfu;

  int get _orphanCfu => _exams.all
      .where((e) =>
          e.courseId == null &&
          e.status == ExamStatus.completato &&
          e.cfu != null)
      .fold<int>(0, (acc, e) => acc + (e.cfu ?? 0));

  
  double get mediaPonderata {
    int totWeight = 0;
    int totGrade = 0;
    for (final c in _courses.all) {
      final grade = _exams.latestPassedGrade(c.id);
      if (grade == null) continue;
      final effective = grade.clamp(18, 30);
      totWeight += c.cfu;
      totGrade += effective * c.cfu;
    }
    for (final e in _exams.all) {
      if (e.courseId != null) continue;
      if (e.status != ExamStatus.completato) continue;
      final g = e.grade;
      final cfu = e.cfu;
      if (g == null || cfu == null) continue;
      final effective = g.clamp(18, 30);
      totWeight += cfu;
      totGrade += effective * cfu;
    }
    return totWeight == 0 ? 0 : totGrade / totWeight;
  }

  int get esamiCompletati =>
      _exams.all.where((e) => e.status == ExamStatus.completato).length;

  int get esamiProssimi =>
      _exams.all.where((e) => e.status == ExamStatus.prossimo).length;

  double get completamentoOggi {
    final today = _tasks.today;
    if (today.isEmpty) return 0;
    final done = today.where((t) => t.status == TaskStatus.completato).length;
    return done / today.length;
  }

  /// Percentuale CFU acquisiti rispetto al totale del piano.
  double get progressoPiano {
    if (cfuTotali == 0) return 0;
    return cfuAcquisiti / cfuTotali;
  }

  @override
  void dispose() {
    _courses.removeListener(_onChange);
    _exams.removeListener(_onChange);
    _tasks.removeListener(_onChange);
    super.dispose();
  }
}
