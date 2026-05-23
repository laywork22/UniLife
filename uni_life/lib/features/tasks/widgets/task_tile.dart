import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/task.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../state/task_provider.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = task.status == TaskStatus.completato;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: (_) =>
              context.read<TaskProvider>().toggleComplete(task.id),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: done ? TextDecoration.lineThrough : null,
            color: done
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: task.dueDate == null
            ? null
            : Text('Entro: ${AppDateUtils.formatDate(task.dueDate!)}'),
        trailing: StatusChip.forPriority(task.priority),
      ),
    );
  }
}
