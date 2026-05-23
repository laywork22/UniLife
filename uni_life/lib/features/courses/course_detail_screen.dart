import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/enums.dart';
import '../../services/url_service.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/status_chip.dart';
import '../../state/course_provider.dart';
import '../../state/exam_provider.dart';
import '../../state/task_provider.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final coursesProv = context.watch<CourseProvider>();
    final examsProv = context.watch<ExamProvider>();
    final tasksProv = context.watch<TaskProvider>();

    final course = coursesProv.byId(courseId);
    if (course == null) {
      return const Scaffold(
        body: Center(child: Text('Corso non trovato')),
      );
    }

    final relatedExams = examsProv.byCourse(courseId);
    final relatedTasks = tasksProv.byCourse(courseId);

    return Scaffold(
      appBar: AppBar(
        title: Text(course.nome),
        actions: [
          IconButton(
            tooltip: 'Elimina corso',
            onPressed: () async {
              final ok = await showConfirmDialog(
                context,
                title: 'Eliminare il corso?',
                message: 'L\'operazione rimuove anche gli esami collegati.',
              );
              if (!ok) return;
              await context.read<CourseProvider>().remove(courseId);
              if (context.mounted) {
                AppSnackbar.show(context, 'Corso eliminato',
                    icon: Icons.delete);
                context.pop();
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/courses/$courseId/edit'),
        child: const Icon(Icons.edit),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Docente: ${course.docente}',
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      StatusChip.forCourse(course.stato),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoBox(label: 'CFU', value: '${course.cfu}'),
                      const SizedBox(width: 12),
                      _InfoBox(
                          label: 'Semestre', value: '${course.semestre}°'),
                      const SizedBox(width: 12),
                      _InfoBox(
                        label: 'Voto',
                        value: course.votoOttenuto == null
                            ? '—'
                            : '${course.votoOttenuto}',
                      ),
                    ],
                  ),
                  if ((course.descrizione ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(course.descrizione!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Esami collegati'),
          if (relatedExams.isEmpty)
            const _MutedRow('Nessun esame associato.')
          else
            ...relatedExams.map(
              (e) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(e.title),
                  subtitle: Text(AppDateUtils.formatDateTime(e.date)),
                  trailing: StatusChip.forExam(e.status),
                  onTap: () => context.push('/exams/${e.id}'),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const _SectionTitle('Attività collegate'),
          if (relatedTasks.isEmpty)
            const _MutedRow('Nessuna attività collegata.')
          else
            ...relatedTasks.map(
              (t) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(
                    t.status == TaskStatus.completato
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: t.status == TaskStatus.completato
                        ? AppColors.success
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(t.title),
                  subtitle: t.dueDate == null
                      ? null
                      : Text('Entro: ${AppDateUtils.formatDate(t.dueDate!)}'),
                  trailing: StatusChip.forPriority(t.priority),
                ),
              ),
            ),
          if (course.materiali.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionTitle('Materiali'),
            ...course.materiali.map(
              (url) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.link, color: AppColors.info),
                  title: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () async {
                    final ok = await UrlService.instance.open(url);
                    if (!ok && context.mounted) {
                      AppSnackbar.show(context, 'Impossibile aprire il link',
                          icon: Icons.error);
                    }
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary)),
            Text(label,
                style: TextStyle(
                    color: scheme.onSurfaceVariant, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Text(text,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.secondary)),
      );
}

class _MutedRow extends StatelessWidget {
  const _MutedRow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
