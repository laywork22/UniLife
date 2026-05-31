import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/validators.dart';
import '../../data/models/enums.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../state/course_provider.dart';
import '../../state/exam_provider.dart';
import '../../state/session_provider.dart';

class SessionFormScreen extends StatefulWidget {
  const SessionFormScreen({super.key, this.sessionId, this.initialDate});

  final String? sessionId;

  final DateTime? initialDate;

  bool get isEdit => sessionId != null;

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _notes = TextEditingController();
  String? _courseId;
  String? _examId;
  SessionType _type = SessionType.studio;
  late DateTime _date;
  TimeOfDay _start = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 16, minute: 0);

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
    if (widget.isEdit) {
      final s = context.read<SessionProvider>().byId(widget.sessionId!);
      if (s != null) {
        _title.text = s.title;
        _notes.text = s.notes ?? '';
        _courseId = s.courseId;
        _examId = s.examId;
        _type = s.type;
        _date = s.date;
        _start = TimeOfDay.fromDateTime(s.startTime);
        _end = TimeOfDay.fromDateTime(s.endTime);
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
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(context: context, initialTime: _start);
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(context: context, initialTime: _end);
    if (picked != null) setState(() => _end = picked);
  }

  Future<void> _save() async {
    // UC-3 prevede l'associazione corso obbligatoria.
    if (_courseId == null) {
      AppSnackbar.show(context, 'Associa la sessione a un corso',
          icon: Icons.warning);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final start = DateTime(
        _date.year, _date.month, _date.day, _start.hour, _start.minute);
    final end = DateTime(
        _date.year, _date.month, _date.day, _end.hour, _end.minute);
    if (!end.isAfter(start)) {
      AppSnackbar.show(context, 'L\'ora di fine deve seguire l\'inizio',
          icon: Icons.warning);
      return;
    }

    final p = context.read<SessionProvider>();
    if (widget.isEdit) {
      final existing = p.byId(widget.sessionId!);
      if (existing == null) return;
      await p.edit(existing.copyWith(
        title: _title.text.trim(),
        date: _date,
        startTime: start,
        endTime: end,
        type: _type,
        courseId: _courseId,
        examId: _examId,
        notes: _notes.text.trim(),
      ));
    } else {
      await p.add(
        title: _title.text.trim(),
        date: _date,
        startTime: start,
        endTime: end,
        type: _type,
        courseId: _courseId,
        examId: _examId,
        notes: _notes.text.trim(),
      );
    }
    if (!mounted) return;
    AppSnackbar.show(context,
        widget.isEdit ? 'Sessione aggiornata' : 'Sessione aggiunta',
        icon: Icons.check_circle);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseProvider>().all;
    final exams = context.watch<ExamProvider>().all;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Modifica sessione' : 'Nuova sessione'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Titolo'),
              validator: (v) => Validators.notEmpty(v, field: 'Titolo'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SessionType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipologia'),
              items: SessionType.values
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _type = v ?? SessionType.studio),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _courseId,
              decoration: const InputDecoration(labelText: 'Corso'),
              items: courses
                  .map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.nome)))
                  .toList(),
              onChanged: (v) => setState(() => _courseId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _examId,
              decoration:
                  const InputDecoration(labelText: 'Esame collegato (opz.)'),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('— Nessuno —')),
                ...exams.map(
                  (e) =>
                      DropdownMenuItem(value: e.id, child: Text(e.title)),
                ),
              ],
              onChanged: (v) => setState(() => _examId = v),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(AppDateUtils.formatDate(_date)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickStart,
                    icon: const Icon(Icons.play_arrow),
                    label: Text('Inizio: ${_start.format(context)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickEnd,
                    icon: const Icon(Icons.stop),
                    label: Text('Fine: ${_end.format(context)}'),
                  ),
                ),
              ],
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
              label: Text(widget.isEdit ? 'Salva modifiche' : 'Crea sessione'),
            ),
          ],
        ),
      ),
    );
  }
}
