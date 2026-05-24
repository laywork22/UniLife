import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/course.dart';
import '../data/models/enums.dart';
import '../data/repositories/course_repository.dart';

/// State per i corsi: lista corrente, filtro tab e ricerca testuale.
class CourseProvider extends ChangeNotifier {
  CourseProvider({CourseRepository? repository})
      : _repo = repository ?? CourseRepository();

  final CourseRepository _repo;
  final _uuid = const Uuid();

  List<Course> _all = const [];
  CourseStatus? _filter; // null = mostra tutto
  String _query = '';
  bool _loading = false;

  List<Course> get all => _all;
  bool get isLoading => _loading;
  CourseStatus? get filter => _filter;
  String get query => _query;

  List<Course> get visible {
    Iterable<Course> result = _all;
    if (_filter != null) result = result.where((c) => c.stato == _filter);
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      result = result.where((c) =>
          c.nome.toLowerCase().contains(q) ||
          c.docente.toLowerCase().contains(q));
    }
    return result.toList();
  }

  List<Course> get correnti =>
      _all.where((c) => c.stato == CourseStatus.inCorso).toList();
  List<Course> get terminati =>
      _all.where((c) => c.stato == CourseStatus.superato).toList();

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _all = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  void setFilter(CourseStatus? filter) {
    _filter = filter;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  Course? byId(String? id) {
    if (id == null) return null;
    for (final c in _all) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<Course> add({
    required String nome,
    required String docente,
    required int cfu,
    required int semestre,
    CourseStatus stato = CourseStatus.inCorso,
    String? descrizione,
    String? note,
    List<String> materiali = const [],
  }) async {
    final c = Course(
      id: _uuid.v4(),
      nome: nome,
      docente: docente,
      cfu: cfu,
      semestre: semestre,
      stato: stato,
      descrizione: descrizione,
      note: note,
      materiali: materiali,
    );
    await _repo.insert(c);
    await load();
    return c;
  }

  Future<void> edit(Course updated) async {
    await _repo.update(updated);
    await load();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await load();
  }
}
