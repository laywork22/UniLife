import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/empty_state.dart';
import '../../state/exam_provider.dart';
import '../../state/stats_provider.dart';
import '../../state/task_provider.dart';
import '../../state/theme_provider.dart';
import 'widgets/deadline_card.dart';
import 'widgets/progress_ring.dart';
import 'widgets/today_task_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final stats = context.watch<StatsProvider>();
    final exams = context.watch<ExamProvider>();
    final tasks = context.watch<TaskProvider>();

    final upcoming = exams.upcoming.take(3).toList();
    final todayTasks = tasks.today;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/new'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _DashboardHeader(userName: theme.userName),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scadenze imminenti',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (upcoming.isEmpty &&
                                stats.completamentoOggi == 0)
                              const _NoDeadlines()
                            else
                              SizedBox(
                                height: 120,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: upcoming.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(width: 10),
                                        itemBuilder: (_, i) {
                                          final e = upcoming[i];
                                          return DeadlineCard(
                                            title: e.title,
                                            date: e.date,
                                            onTap: () => context
                                                .push('/exams/${e.id}'),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ProgressRing(
                                      value: stats.completamentoOggi,
                                      label: 'completati',
                                      size: 100,
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StatsRow(
                      cfu: stats.cfuAcquisiti,
                      cfuTot: stats.cfuTotali,
                      media: stats.mediaPonderata,
                      esami: stats.esamiCompletati,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Task Oggi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (todayTasks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: EmptyState(
                          icon: Icons.checklist_rtl,
                          title: 'Nessun task per oggi',
                          message: 'Tocca il + per aggiungere un\'attività.',
                        ),
                      )
                    else
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Column(
                            children: [
                              for (int i = 0; i < todayTasks.length; i++) ...[
                                TodayTaskTile(task: todayTasks[i]),
                                if (i < todayTasks.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 8, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ciao $userName,',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ecco il tuo piano per oggi.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Impostazioni',
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.cfu,
    required this.cfuTot,
    required this.media,
    required this.esami,
  });

  final int cfu;
  final int cfuTot;
  final double media;
  final int esami;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _StatBox(
          label: 'CFU',
          value: cfuTot == 0 ? '$cfu' : '$cfu/$cfuTot',
          color: scheme.primary,
        ),
        const SizedBox(width: 10),
        _StatBox(
          label: 'Media',
          value: media == 0 ? '—' : media.toStringAsFixed(1),
          color: scheme.secondary,
        ),
        const SizedBox(width: 10),
        _StatBox(
          label: 'Esami',
          value: '$esami',
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoDeadlines extends StatelessWidget {
  const _NoDeadlines();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'Nessun esame in arrivo. Goditi una giornata tranquilla! 🎉',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
