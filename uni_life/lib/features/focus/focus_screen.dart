import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/enums.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../state/course_provider.dart';
import '../../state/pomodoro_provider.dart';
import '../../state/task_provider.dart';
import 'widgets/pomodoro_timer.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pomodoro = context.watch<PomodoroProvider>();
    final courses = context.watch<CourseProvider>().all;
    final tasks = context.watch<TaskProvider>().all
        .where((t) => t.status == TaskStatus.daCompletare)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: PomodoroTimer(
                display: pomodoro.display,
                progress: pomodoro.progress,
                state: pomodoro.state,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (pomodoro.state == PomodoroState.idle ||
                    pomodoro.state == PomodoroState.done)
                  FilledButton.icon(
                    onPressed: pomodoro.start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Avvia'),
                  ),
                if (pomodoro.state == PomodoroState.running)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.warning),
                    onPressed: pomodoro.pause,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pausa'),
                  ),
                if (pomodoro.state == PomodoroState.paused)
                  FilledButton.icon(
                    onPressed: pomodoro.resume,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Riprendi'),
                  ),
                OutlinedButton.icon(
                  onPressed: pomodoro.state == PomodoroState.idle
                      ? null
                      : () async {
                          final keep = await showConfirmDialog(
                            context,
                            title: 'Interrompere la sessione?',
                            message:
                                'Salvare i minuti già svolti come tempo studio?',
                            confirmLabel: 'Salva e termina',
                            cancelLabel: 'Scarta',
                            destructive: false,
                          );
                          pomodoro.stop(saveProgress: keep);
                        },
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DurationSelector(
              currentMinutes: pomodoro.totalSeconds ~/ 60,
              enabled: pomodoro.state == PomodoroState.idle,
              onSelect: pomodoro.setDurationMinutes,
            ),
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('A cosa stai lavorando?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.secondary)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                      initialValue: pomodoro.linkedCourseId,
                      decoration:
                          const InputDecoration(labelText: 'Corso'),
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null, child: Text('— Nessuno —')),
                        ...courses.map(
                          (c) => DropdownMenuItem(
                              value: c.id, child: Text(c.nome)),
                        ),
                      ],
                      onChanged: pomodoro.selectCourse,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: pomodoro.linkedTask?.id,
                      decoration:
                          const InputDecoration(labelText: 'Task (opz.)'),
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null, child: Text('— Nessuno —')),
                        ...tasks.map(
                          (t) => DropdownMenuItem(
                              value: t.id, child: Text(t.title)),
                        ),
                      ],
                      onChanged: (id) {
                        final t = id == null
                            ? null
                            : context.read<TaskProvider>().byId(id);
                        pomodoro.selectTask(t);
                      },
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

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({
    required this.currentMinutes,
    required this.onSelect,
    required this.enabled,
  });

  final int currentMinutes;
  final ValueChanged<int> onSelect;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const options = [
      AppConstants.shortBreakMinutes,
      AppConstants.pomodoroMinutes,
      AppConstants.longBreakMinutes,
    ];
    return Wrap(
      spacing: 8,
      children: options.map((m) {
        final selected = m == currentMinutes;
        return ChoiceChip(
          label: Text('$m min'),
          selected: selected,
          onSelected: enabled ? (_) => onSelect(m) : null,
        );
      }).toList(),
    );
  }
}
