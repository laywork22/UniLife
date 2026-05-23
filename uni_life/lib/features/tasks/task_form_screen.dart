import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/validators.dart';
import '../../data/models/enums.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../state/course_provider.dart';
import '../../state/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;
  bool get isEdit => taskId != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _estimated = TextEditingController(text: '0');
  String? _courseId;
  Priority _priority = Priority.media;
  DateTime? _dueDate;
  bool _isGoal = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      final t = context.read<TaskProvider>().byId(widget.taskId!);
      if (t != null) {
        _title.text = t.title;
        _description.text = t.description ?? '';
        _estimated.text = t.estimatedMinutes.toString();
        _courseId = t.courseId;
        _priority = t.priority;
        _dueDate = t.dueDate;
        _isGoal = t.isGoal;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _estimated.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Se il task esistente ha una scadenza già passata la rispettiamo come
    // valore iniziale, ma il selettore non consente di sceglierne di nuove.
    final initial =
        (_dueDate != null && !_dueDate!.isBefore(today)) ? _dueDate! : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<TaskProvider>();
    final estimated = int.tryParse(_estimated.text) ?? 0;

    if (widget.isEdit) {
      final existing = p.byId(widget.taskId!);
      if (existing == null) return;
      await p.edit(existing.copyWith(
        title: _title.text.trim(),
        description: _description.text.trim(),
        courseId: _courseId,
        priority: _priority,
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
        estimatedMinutes: estimated,
        isGoal: _isGoal,
      ));
    } else {
      await p.add(
        title: _title.text.trim(),
        description: _description.text.trim(),
        courseId: _courseId,
        priority: _priority,
        dueDate: _dueDate,
        estimatedMinutes: estimated,
        isGoal: _isGoal,
      );
    }
    if (!mounted) return;
    AppSnackbar.show(context,
        widget.isEdit ? 'Attività aggiornata' : 'Attività aggiunta',
        icon: Icons.check_circle);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseProvider>().all;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Modifica attività' : 'Nuova attività'),
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
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _courseId,
              decoration:
                  const InputDecoration(labelText: 'Corso (opzionale)'),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('— Nessuno —')),
                ...courses.map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.nome)),
                ),
              ],
              onChanged: (v) => setState(() => _courseId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Priority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priorità'),
              items: Priority.values
                  .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _priority = v ?? Priority.media),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_dueDate == null
                        ? 'Scegli scadenza'
                        : AppDateUtils.formatDate(_dueDate!)),
                  ),
                ),
                if (_dueDate != null)
                  IconButton(
                    onPressed: () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.clear),
                    tooltip: 'Rimuovi scadenza',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _estimated,
              decoration:
                  const InputDecoration(labelText: 'Minuti stimati'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isGoal,
              onChanged: (v) => setState(() => _isGoal = v),
              title: const Text('Obiettivo personale'),
              subtitle: const Text(
                  'Distingue gli obiettivi a lungo termine dalle attività operative.'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(
                widget.isEdit ? 'Salva modifiche' : 'Crea attività',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
