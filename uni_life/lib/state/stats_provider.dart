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

  int get cfuAcquisiti => _courses.all
      .where((c) => c.stato == CourseStatus.superato)
      .fold<int>(0, (acc, c) => acc + c.cfu);

  int get cfuTotali =>
      _courses.all.fold<int>(0, (acc, c) => acc + c.cfu);

  /// Media voti ponderata sui CFU dei corsi superati.
  double get mediaPonderata {
    final superati = _courses.all
        .where((c) => c.stato == CourseStatus.superato && c.votoOttenuto != null);
    if (superati.isEmpty) return 0;
    final num totWeight = superati.fold<int>(0, (a, c) => a + c.cfu);
    final num totGrade = superati.fold<int>(
      0,
      (a, c) => a + ((c.votoOttenuto!.clamp(18, 30)) * c.cfu),
    );
    return totWeight == 0 ? 0 : totGrade / totWeight;
  }

  int get esamiCompletati =>
      _exams.all.where((e) => e.status == ExamStatus.completato).length;

  int get esamiProssimi =>
      _exams.all.where((e) => e.status == ExamStatus.prossimo).length;

  /// Percentuale completamento task del giorno (UC-7).
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
