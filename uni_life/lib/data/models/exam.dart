import 'enums.dart';

/// DF-1.2 — Esame associato a un corso.
class Exam {
  final String id;
  final String title;
  final String courseId;
  final DateTime date;
  final ExamType type;
  final Priority priority;
  final ExamStatus status;
  final int? grade;
  final String? notes;

  const Exam({
    required this.id,
    required this.title,
    required this.courseId,
    required this.date,
    this.type = ExamType.scritto,
    this.priority = Priority.media,
    this.status = ExamStatus.prossimo,
    this.grade,
    this.notes,
  });

  Exam copyWith({
    String? id,
    String? title,
    String? courseId,
    DateTime? date,
    ExamType? type,
    Priority? priority,
    ExamStatus? status,
    int? grade,
    String? notes,
    bool clearGrade = false,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
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
        courseId: m['course_id'] as String,
        date: DateTime.parse(m['date'] as String),
        type: ExamTypeX.fromName(m['type'] as String?),
        priority: PriorityX.fromName(m['priority'] as String?),
        status: ExamStatusX.fromName(m['status'] as String?),
        grade: m['grade'] as int?,
        notes: m['notes'] as String?,
      );
}
