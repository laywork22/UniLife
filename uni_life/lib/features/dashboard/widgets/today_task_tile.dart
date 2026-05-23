import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/task.dart';
import '../../../state/task_provider.dart';

class TodayTaskTile extends StatelessWidget {
  const TodayTaskTile({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final done = task.status == TaskStatus.completato;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push('/tasks/${task.id}/edit'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: done,
                onChanged: (_) =>
                    context.read<TaskProvider>().toggleComplete(task.id),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  color: done ? scheme.onSurfaceVariant : scheme.onSurface,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (task.priority == Priority.alta && !done)
              const Icon(Icons.flag, size: 16, color: AppColors.danger),
          ],
        ),
      ),
    );
  }
}
