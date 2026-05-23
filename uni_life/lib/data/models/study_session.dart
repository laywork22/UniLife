import 'enums.dart';

/// DF-1.3 — Sessione di studio pianificata o registrata (UC-3, UC-5, UC-9).
class StudySession {
  final String id;
  final String title;
  final String? courseId;
  final String? examId;
  final DateTime date;        // data del giorno
  final DateTime startTime;   // include data e ora di inizio
  final DateTime endTime;     // include data e ora di fine pianificata
  final SessionType type;
  final bool isCompleted;
  final int actualMinutes;    // minuti effettivamente svolti (Pomodoro)
  final String? notes;

  const StudySession({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.type = SessionType.studio,
    this.courseId,
    this.examId,
    this.isCompleted = false,
    this.actualMinutes = 0,
    this.notes,
  });

  int get plannedMinutes => endTime.difference(startTime).inMinutes;

  StudySession copyWith({
    String? id,
    String? title,
    String? courseId,
    String? examId,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    SessionType? type,
    bool? isCompleted,
    int? actualMinutes,
    String? notes,
  }) {
    return StudySession(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      examId: examId ?? this.examId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'course_id': courseId,
        'exam_id': examId,
        'date': date.toIso8601String(),
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'type': type.name,
        'is_completed': isCompleted ? 1 : 0,
        'actual_minutes': actualMinutes,
        'notes': notes,
      };

  factory StudySession.fromMap(Map<String, Object?> m) => StudySession(
        id: m['id'] as String,
        title: m['title'] as String,
        courseId: m['course_id'] as String?,
        examId: m['exam_id'] as String?,
        date: DateTime.parse(m['date'] as String),
        startTime: DateTime.parse(m['start_time'] as String),
        endTime: DateTime.parse(m['end_time'] as String),
        type: SessionTypeX.fromName(m['type'] as String?),
        isCompleted: ((m['is_completed'] as int?) ?? 0) == 1,
        actualMinutes: (m['actual_minutes'] as int?) ?? 0,
        notes: m['notes'] as String?,
      );
}
