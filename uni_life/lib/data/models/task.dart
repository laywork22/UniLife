import 'enums.dart';

/// DF-1.4 — Attività / obiettivo personale.
class Task {
  final String id;
  final String title;
  final String? description;
  final String? courseId;
  final Priority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final int estimatedMinutes;
  final int actualMinutes;
  final DateTime? completedAt;
  final bool isGoal;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.courseId,
    this.priority = Priority.media,
    this.status = TaskStatus.daCompletare,
    this.dueDate,
    this.estimatedMinutes = 0,
    this.actualMinutes = 0,
    this.completedAt,
    this.isGoal = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    Priority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    int? estimatedMinutes,
    int? actualMinutes,
    DateTime? completedAt,
    bool? isGoal,
    bool clearCompletedAt = false,
    bool clearDueDate = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      isGoal: isGoal ?? this.isGoal,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'course_id': courseId,
        'priority': priority.name,
        'status': status.name,
        'due_date': dueDate?.toIso8601String(),
        'estimated_minutes': estimatedMinutes,
        'actual_minutes': actualMinutes,
        'completed_at': completedAt?.toIso8601String(),
        'is_goal': isGoal ? 1 : 0,
      };

  factory Task.fromMap(Map<String, Object?> m) => Task(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String?,
        courseId: m['course_id'] as String?,
        priority: PriorityX.fromName(m['priority'] as String?),
        status: TaskStatusX.fromName(m['status'] as String?),
        dueDate: m['due_date'] != null
            ? DateTime.parse(m['due_date'] as String)
            : null,
        estimatedMinutes: (m['estimated_minutes'] as int?) ?? 0,
        actualMinutes: (m['actual_minutes'] as int?) ?? 0,
        completedAt: m['completed_at'] != null
            ? DateTime.parse(m['completed_at'] as String)
            : null,
        isGoal: ((m['is_goal'] as int?) ?? 0) == 1,
      );
}
