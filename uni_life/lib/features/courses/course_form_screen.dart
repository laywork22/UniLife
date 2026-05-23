import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../data/models/enums.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../state/course_provider.dart';

class CourseFormScreen extends StatefulWidget {
  const CourseFormScreen({super.key, this.courseId});

  final String? courseId;
  bool get isEdit => courseId != null;

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _docente = TextEditingController();
  final _cfu = TextEditingController();
  final _semestre = TextEditingController(text: '1');
  final _voto = TextEditingController();
  final _descrizione = TextEditingController();
  final _materiali = TextEditingController();
  CourseStatus _stato = CourseStatus.inCorso;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      final c = context.read<CourseProvider>().byId(widget.courseId!);
      if (c != null) {
        _nome.text = c.nome;
        _docente.text = c.docente;
        _cfu.text = c.cfu.toString();
        _semestre.text = c.semestre.toString();
        _voto.text = c.votoOttenuto?.toString() ?? '';
        _descrizione.text = c.descrizione ?? '';
        _materiali.text = c.materiali.join('\n');
        _stato = c.stato;
      }
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _docente.dispose();
    _cfu.dispose();
    _semestre.dispose();
    _voto.dispose();
    _descrizione.dispose();
    _materiali.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<CourseProvider>();
    final materiali = _materiali.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final voto = _voto.text.isEmpty ? null : int.tryParse(_voto.text);

    if (widget.isEdit) {
      final existing = p.byId(widget.courseId!);
      if (existing == null) return;
      await p.edit(existing.copyWith(
        nome: _nome.text.trim(),
        docente: _docente.text.trim(),
        cfu: int.parse(_cfu.text),
        semestre: int.parse(_semestre.text),
        stato: _stato,
        votoOttenuto: voto,
        clearVoto: voto == null,
        descrizione: _descrizione.text.trim(),
        materiali: materiali,
      ));
    } else {
      await p.add(
        nome: _nome.text.trim(),
        docente: _docente.text.trim(),
        cfu: int.parse(_cfu.text),
        semestre: int.parse(_semestre.text),
        stato: _stato,
        descrizione: _descrizione.text.trim(),
        materiali: materiali,
      );
    }
    if (!mounted) return;
    AppSnackbar.show(context,
        widget.isEdit ? 'Corso aggiornato' : 'Corso aggiunto',
        icon: Icons.check_circle);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Modifica corso' : 'Nuovo corso'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nome,
              decoration: const InputDecoration(labelText: 'Nome corso'),
              validator: (v) => Validators.notEmpty(v, field: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _docente,
              decoration: const InputDecoration(labelText: 'Docente'),
              validator: (v) => Validators.notEmpty(v, field: 'Docente'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cfu,
                    decoration: const InputDecoration(labelText: 'CFU'),
                    keyboardType: TextInputType.number,
                    validator: Validators.cfuRange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _semestre,
                    decoration:
                        const InputDecoration(labelText: 'Semestre (1/2)'),
                    keyboardType: TextInputType.number,
                    validator: Validators.semester,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CourseStatus>(
              initialValue: _stato,
              decoration: const InputDecoration(labelText: 'Stato'),
              items: CourseStatus.values
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _stato = v ?? CourseStatus.inCorso),
            ),
            if (_stato == CourseStatus.superato) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _voto,
                decoration: const InputDecoration(
                  labelText: 'Voto (18-30 oppure 31 per la lode)',
                ),
                keyboardType: TextInputType.number,
                validator: Validators.gradeRange,
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _descrizione,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _materiali,
              decoration: const InputDecoration(
                labelText: 'Materiali (un URL per riga)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(widget.isEdit ? 'Salva modifiche' : 'Crea corso'),
            ),
          ],
        ),
      ),
    );
  }
}
