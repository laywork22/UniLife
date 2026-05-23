import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/enums.dart';
import '../../data/models/exam.dart';
import '../../shared/widgets/empty_state.dart';
import '../../state/course_provider.dart';
import '../../state/exam_provider.dart';
import 'widgets/exam_tile.dart';

class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final examsProv = context.watch<ExamProvider>();
    final coursesProv = context.watch<CourseProvider>();
    final exams = examsProv.visible;
    final grouped = AppDateUtils.groupByDay(exams, (Exam e) => e.date);
    final sortedKeys = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Esami'),
        actions: [
          IconButton(
            tooltip: 'Calendario',
            onPressed: () => context.push('/exams/calendar'),
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/exams/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tutti',
                  selected: examsProv.filter == null,
                  onTap: () => examsProv.setFilter(null),
                ),
                const SizedBox(width: 6),
                for (final s in ExamStatus.values) ...[
                  _FilterChip(
                    label: s.label,
                    selected: examsProv.filter == s,
                    onTap: () => examsProv.setFilter(s),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          Expanded(
            child: exams.isEmpty
                ? EmptyState(
                    icon: Icons.event_busy,
                    title: 'Nessun esame',
                    message: 'Aggiungi una sessione d\'esame per iniziare.',
                    ctaLabel: 'Nuovo esame',
                    onCta: () => context.push('/exams/new'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: sortedKeys.length,
                    itemBuilder: (_, i) {
                      final day = sortedKeys[i];
                      final dayExams = grouped[day]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                            child: Text(
                              '${AppDateUtils.weekday(day)}, ${AppDateUtils.formatDate(day)}',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ...dayExams.map((e) => ExamTile(
                                exam: e,
                                courseName:
                                    coursesProv.byId(e.courseId)?.nome,
                                onTap: () => context.push('/exams/${e.id}'),
                              )),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
