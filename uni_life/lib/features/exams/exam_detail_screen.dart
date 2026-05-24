import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validators.dart';
import '../../data/models/enums.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/status_chip.dart';
import '../../state/course_provider.dart';
import '../../state/exam_provider.dart';

class ExamDetailScreen extends StatefulWidget {
  const ExamDetailScreen({super.key, required this.examId});

  final String examId;

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  final _notes = TextEditingController();
  bool _notesInit = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final examsProv = context.watch<ExamProvider>();
    final coursesProv = context.watch<CourseProvider>();
    final exam = examsProv.byId(widget.examId);
    if (exam == null) {
      return const Scaffold(body: Center(child: Text('Esame non trovato')));
    }
    final course = coursesProv.byId(exam.courseId);
    if (!_notesInit) {
      _notes.text = exam.notes ?? '';
      _notesInit = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Esame: ${exam.title}'),
        actions: [
          IconButton(
            tooltip: 'Elimina',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showConfirmDialog(
                context,
                title: 'Eliminare l\'esame?',
                message: 'Operazione non reversibile.',
              );
              if (!ok) return;
              await context.read<ExamProvider>().remove(widget.examId);
              if (context.mounted) {
                AppSnackbar.show(context, 'Esame eliminato',
                    icon: Icons.delete);
                context.pop();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/exams/${exam.id}/edit'),
        child: const Icon(Icons.edit),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _LabelValue(
              label: 'Corso',
              value: course?.nome ?? '— senza corso —'),
          const SizedBox(height: 12),
          _LabelValue(
              label: 'Docente', value: course?.docente ?? '—'),
          const SizedBox(height: 12),
          _LabelValue(
              label: 'Data Appello',
              value: AppDateUtils.formatDateTime(exam.date)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LabelValue(
                  label: 'CFU',
                  value: course != null
                      ? '${course.cfu}'
                      : (exam.cfu != null ? '${exam.cfu}' : '—'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabelValue(label: 'Tipologia', value: exam.type.label),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Descrizione/Note'),
            maxLines: 4,
            onChanged: (v) {
              // salvataggio differito su esplicito tap "Salva note"
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                await context.read<ExamProvider>().edit(
                      exam.copyWith(notes: _notes.text.trim()),
                    );
                if (context.mounted) {
                  AppSnackbar.show(context, 'Note salvate',
                      icon: Icons.save);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Salva note'),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in ExamStatus.values)
                StatusChip.forExam(
                  s,
                  selected: exam.status == s,
                  onTap: () async {
                    await context
                        .read<ExamProvider>()
                        .edit(exam.copyWith(status: s));
                  },
                ),
            ],
          ),
          // Il voto si registra SOLO quando l'esame è stato completato.
          if (exam.status == ExamStatus.completato) ...[
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registra voto',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.secondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _GradeInput(
                            initial: exam.grade,
                            onSubmit: (g) async {
                              await context
                                  .read<ExamProvider>()
                                  .registerGrade(exam.id, g);
                              if (context.mounted) {
                                AppSnackbar.show(context,
                                    'Voto registrato: $g',
                                    icon: Icons.check);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (exam.grade != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Voto corrente: ${exam.grade}${exam.grade == 31 ? "L" : ""}',
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: scheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface)),
        ],
      ),
    );
  }
}

class _GradeInput extends StatefulWidget {
  const _GradeInput({this.initial, required this.onSubmit});
  final int? initial;
  final ValueChanged<int> onSubmit;

  @override
  State<_GradeInput> createState() => _GradeInputState();
}

class _GradeInputState extends State<_GradeInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial?.toString() ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Voto'),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: () {
            final err = Validators.gradeRange(_ctrl.text);
            if (err != null || _ctrl.text.isEmpty) {
              AppSnackbar.show(
                  context, err ?? 'Inserisci un voto valido',
                  icon: Icons.warning);
              return;
            }
            widget.onSubmit(int.parse(_ctrl.text));
          },
          child: const Text('Salva voto'),
        ),
      ],
    );
  }
}
