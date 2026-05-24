import 'enums.dart';

/// DF-1.2 — Esame. Può essere legato a un corso (relazione 1‑N) oppure
/// "standalone" (esame inserito retroattivamente senza che il corso sia
/// stato registrato in app): in tal caso `courseId` è `null` e va valorizzato
/// `cfu` per far concorrere l'esame al calcolo dei crediti e della media.
class Exam {
  final String id;
  final String title;
  final String? courseId;
  final int? cfu; // valorizzato solo per esami standalone (courseId == null)
  final DateTime date;
  final ExamType type;
  final Priority priority;
  final ExamStatus status;
  final int? grade;
  final String? notes;

  const Exam({
    required this.id,
    required this.title,
    required this.date,
    this.courseId,
    this.cfu,
    this.type = ExamType.scritto,
    this.priority = Priority.media,
    this.status = ExamStatus.prossimo,
    this.grade,
    this.notes,
  });

  bool get isStandalone => courseId == null;

  Exam copyWith({
    String? id,
    String? title,
    String? courseId,
    int? cfu,
    DateTime? date,
    ExamType? type,
    Priority? priority,
    ExamStatus? status,
    int? grade,
    String? notes,
    bool clearGrade = false,
    bool clearCourse = false,
    bool clearCfu = false,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: clearCourse ? null : (courseId ?? this.courseId),
      cfu: clearCfu ? null : (cfu ?? this.cfu),
      date: date ?? this.date,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      grade: clearGrade ? null : (grade ?? this.grade),
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'course_id': courseId,
        'cfu': cfu,
        'date': date.toIso8601String(),
        'type': type.name,
        'priority': priority.name,
        'status': status.name,
        'grade': grade,
        'notes': notes,
      };

  factory Exam.fromMap(Map<String, Object?> m) => Exam(
        id: m['id'] as String,
        title: m['title'] as String,
        courseId: m['course_id'] as String?,
        cfu: m['cfu'] as int?,
        date: DateTime.parse(m['date'] as String),
        type: ExamTypeX.fromName(m['type'] as String?),
        priority: PriorityX.fromName(m['priority'] as String?),
        status: ExamStatusX.fromName(m['status'] as String?),
        grade: m['grade'] as int?,
        notes: m['notes'] as String?,
      );
}
