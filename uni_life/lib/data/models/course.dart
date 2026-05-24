import 'enums.dart';

/// DF-1.1 — Corso universitario.
///
/// Il voto NON è proprietà del corso: appartiene alle istanze di [Exam]
/// associate via `courseId`. Uno studente può sostenere lo stesso esame più
/// volte (rifiutando il voto), quindi il voto "ufficiale" del corso si deriva
/// dall'esame `completato` più recente.
class Course {
  final String id;
  final String nome;
  final String docente;
  final int cfu;
  final int semestre;
  final CourseStatus stato;
  final String? descrizione;
  final String? note;
  final List<String> materiali; // URL ai materiali (UC-10)

  const Course({
    required this.id,
    required this.nome,
    required this.docente,
    required this.cfu,
    required this.semestre,
    this.stato = CourseStatus.inCorso,
    this.descrizione,
    this.note,
    this.materiali = const [],
  });

  Course copyWith({
    String? id,
    String? nome,
    String? docente,
    int? cfu,
    int? semestre,
    CourseStatus? stato,
    String? descrizione,
    String? note,
    List<String>? materiali,
  }) {
    return Course(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      docente: docente ?? this.docente,
      cfu: cfu ?? this.cfu,
      semestre: semestre ?? this.semestre,
      stato: stato ?? this.stato,
      descrizione: descrizione ?? this.descrizione,
      note: note ?? this.note,
      materiali: materiali ?? this.materiali,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'nome': nome,
        'docente': docente,
        'cfu': cfu,
        'semestre': semestre,
        'stato': stato.name,
        'descrizione': descrizione,
        'note': note,
        // List<String> serializzata come stringa con separatore "|".
        'materiali': materiali.join('|'),
      };

  factory Course.fromMap(Map<String, Object?> m) => Course(
        id: m['id'] as String,
        nome: m['nome'] as String,
        docente: (m['docente'] as String?) ?? '',
        cfu: (m['cfu'] as int?) ?? 0,
        semestre: (m['semestre'] as int?) ?? 1,
        stato: CourseStatusX.fromName(m['stato'] as String?),
        descrizione: m['descrizione'] as String?,
        note: m['note'] as String?,
        materiali: (m['materiali'] as String?)?.isNotEmpty == true
            ? (m['materiali'] as String).split('|')
            : const [],
      );
}
