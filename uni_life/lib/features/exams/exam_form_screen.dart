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
  String? _courseId;
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  ExamType _type = ExamType.scritto;
  Priority _priority = Priority.media;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      final e = context.read<ExamProvider>().byId(widget.examId!);
      if (e != null) {
        _title.text = e.title;
        _notes.text = e.notes ?? '';
        _courseId = e.courseId;
        _date = e.date;
        _time = TimeOfDay.fromDateTime(e.date);
        _type = e.type;
        _priority = e.priority;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_courseId == null) {
      AppSnackbar.show(context, 'Seleziona un corso', icon: Icons.warning);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final dateError = Validators.futureDate(_date);
    if (dateError != null) {
      AppSnackbar.show(context, dateError, icon: Icons.warning);
      return;
    }

    final combined =
        DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final p = context.read<ExamProvider>();
    if (widget.isEdit) {
      final existing = p.byId(widget.examId!);
      if (existing == null) return;
      await p.edit(existing.copyWith(
        title: _title.text.trim(),
        courseId: _courseId,
        date: combined,
        type: _type,
        priority: _priority,
        notes: _notes.text.trim(),
      ));
    } else {
      await p.add(
        title: _title.text.trim(),
        courseId: _courseId!,
        date: combined,
        type: _type,
        priority: _priority,
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
            DropdownButtonFormField<String>(
              initialValue: _courseId,
              decoration: const InputDecoration(labelText: 'Corso'),
              items: courses
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nome)))
                  .toList(),
              onChanged: (v) => setState(() => _courseId = v),
              validator: (v) =>
                  v == null ? 'Associa l\'esame a un corso' : null,
            ),
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
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
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
