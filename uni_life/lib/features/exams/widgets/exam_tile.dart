import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/exam.dart';
import '../../../shared/widgets/status_chip.dart';

class ExamTile extends StatelessWidget {
  const ExamTile({super.key, required this.exam, this.courseName, this.onTap});

  final Exam exam;
  final String? courseName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exam.date.day.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
              Text(
                AppDateUtils.shortDay(exam.date).split(' ').last,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          exam.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${courseName ?? "Corso"}  ·  ${AppDateUtils.time(exam.date)}',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        trailing: StatusChip.forExam(exam.status),
      ),
    );
  }
}
