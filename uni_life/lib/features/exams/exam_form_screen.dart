import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/validators.dart';
import '../../data/models/enums.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../state/course_provider.dart';
import '../../state/exam_provider.dart';

class ExamFormScreen extends StatefulWidget {
  const ExamFormScreen({super.key, this.examId});

  final String? examId;
  bool get isEdit => examId != null;

  @override
  State<ExamFormScreen> createState() => _ExamFormScreenState();
}

class _ExamFormScreenState extends State<ExamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _cfu = TextEditingController();
  final _grade = TextEditingController();
  String? _courseId; // null = esame standalone (senza corso registrato)
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  ExamType _type = ExamType.scritto;
  Priority _priority = Priority.media;
  ExamStatus _status = ExamStatus.prossimo;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      final e = context.read<ExamProvider>().byId(widget.examId!);
      if (e != null) {
        _title.text = e.title;
        _notes.text = e.notes ?? '';
        _cfu.text = e.cfu?.toString() ?? '';
        _grade.text = e.grade?.toString() ?? '';
        _courseId = e.courseId;
        _date = e.date;
        _time = TimeOfDay.fromDateTime(e.date);
        _type = e.type;
        _priority = e.priority;
        _status = e.status;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _cfu.dispose();
    _grade.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    // Ammettiamo anche date passate: utile per registrare esami già sostenuti.
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final combined =
        DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

    final cfuValue = _courseId == null
        ? int.tryParse(_cfu.text)
        : null; // se c'è il corso, i CFU si leggono dal corso

    final gradeValue =
        _grade.text.trim().isEmpty ? null : int.tryParse(_grade.text);

    final p = context.read<ExamProvider>();
    if (widget.isEdit) {
      final existing = p.byId(widget.examId!);
      if (existing == null) return;
      await p.edit(existing.copyWith(
        title: _title.text.trim(),
        courseId: _courseId,
        clearCourse: _courseId == null,
        cfu: cfuValue,
        clearCfu: cfuValue == null,
        date: combined,
        type: _type,
        priority: _priority,
        status: _status,
        grade: gradeValue,
        clearGrade: gradeValue == null,
        notes: _notes.text.trim(),
      ));
    } else {
      await p.add(
        title: _title.text.trim(),
        courseId: _courseId,
        cfu: cfuValue,
        date: combined,
        type: _type,
        priority: _priority,
        status: _status,
        grade: gradeValue,
        notes: _notes.text.trim(),
      );
    }
    if (!mounted) return;
    AppSnackbar.show(context,
        widget.isEdit ? 'Esame aggiornato' : 'Esame aggiunto',
        icon: Icons.check_circle);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseProvider>().all;
    final scheme = Theme.of(context).colorScheme;
    final isStandalone = _courseId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Modifica esame' : 'Nuovo esame'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Titolo esame'),
              validator: (v) => Validators.notEmpty(v, field: 'Titolo'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _courseId,
              decoration: const InputDecoration(labelText: 'Corso'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('— Senza corso (registra solo i CFU) —'),
                ),
                ...courses.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.nome),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _courseId = v),
            ),
            if (isStandalone) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _cfu,
                decoration: const InputDecoration(
                  labelText: 'CFU (richiesto per esami senza corso)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (!isStandalone) return null;
                  final err = Validators.cfuRange(v);
                  return err;
                },
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(AppDateUtils.formatDate(_date)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_time.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExamType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipologia'),
              items: ExamType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? ExamType.scritto),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Priority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priorità'),
              items: Priority.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _priority = v ?? Priority.media),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExamStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Stato'),
              items: ExamStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _status = v ?? ExamStatus.prossimo),
            ),
            if (_status == ExamStatus.completato) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _grade,
                decoration: const InputDecoration(
                  labelText: 'Voto (18-30, 31 per la lode)',
                ),
                keyboardType: TextInputType.number,
                validator: Validators.gradeRange,
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                isStandalone
                    ? 'Esame "standalone": registri direttamente i CFU; concorrerà alla media solo se lo stato è «Completato» con un voto.'
                    : 'L\'esame è legato al corso selezionato; i suoi CFU sono quelli del corso.',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(widget.isEdit ? 'Salva modifiche' : 'Crea esame'),
            ),
          ],
        ),
      ),
    );
  }
}
