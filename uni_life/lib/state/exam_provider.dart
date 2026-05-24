import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/enums.dart';
import '../data/models/exam.dart';
import '../data/repositories/exam_repository.dart';

class ExamProvider extends ChangeNotifier {
  ExamProvider({ExamRepository? repository})
      : _repo = repository ?? ExamRepository();

  final ExamRepository _repo;
  final _uuid = const Uuid();

  List<Exam> _all = const [];
  ExamStatus? _filter;
  bool _loading = false;

  List<Exam> get all => _all;
  bool get isLoading => _loading;
  ExamStatus? get filter => _filter;

  List<Exam> get visible => _filter == null
      ? _all
      : _all.where((e) => e.status == _filter).toList();

  /// Esami "in arrivo": tutti quelli ancora marcati `prossimo`, indipendente
  /// dalla data — così anche un appello scaduto ma non ancora sostenuto resta
  /// visibile come reminder finché lo studente non lo aggiorna.
  List<Exam> get upcoming {
    return _all.where((e) => e.status == ExamStatus.prossimo).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Map<DateTime, List<Exam>> get groupedByDay {
    final map = <DateTime, List<Exam>>{};
    for (final e in _all) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _all = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  void setFilter(ExamStatus? f) {
    _filter = f;
    notifyListeners();
  }

  Exam? byId(String id) {
    for (final e in _all) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<Exam> byCourse(String courseId) =>
      _all.where((e) => e.courseId == courseId).toList();

  /// Voto "ufficiale" del corso: il `grade` dell'esame `completato` con la
  /// data più recente (lo studente può aver rifiutato voti precedenti tramite
  /// `annullato`). Restituisce `null` se nessun esame è ancora stato superato.
  int? latestPassedGrade(String courseId) {
    final passed = _all
        .where((e) =>
            e.courseId == courseId &&
            e.status == ExamStatus.completato &&
            e.grade != null)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return passed.isEmpty ? null : passed.first.grade;
  }

  Future<Exam> add({
    required String title,
    required DateTime date,
    String? courseId,
    int? cfu,
    ExamType type = ExamType.scritto,
    Priority priority = Priority.media,
    ExamStatus status = ExamStatus.prossimo,
    int? grade,
    String? notes,
  }) async {
    final e = Exam(
      id: _uuid.v4(),
      title: title,
      courseId: courseId,
      cfu: cfu,
      date: date,
      type: type,
      priority: priority,
      status: status,
      grade: grade,
      notes: notes,
    );
    await _repo.insert(e);
    await load();
    return e;
  }

  Future<void> edit(Exam updated) async {
    await _repo.update(updated);
    await load();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await load();
  }

  /// Registra il voto e marca completato (IF-2).
  Future<void> registerGrade(String id, int grade) async {
    final e = byId(id);
    if (e == null) return;
    await edit(e.copyWith(grade: grade, status: ExamStatus.completato));
  }

  Future<void> cancel(String id) async {
    final e = byId(id);
    if (e == null) return;
    await edit(e.copyWith(status: ExamStatus.annullato));
  }
}
