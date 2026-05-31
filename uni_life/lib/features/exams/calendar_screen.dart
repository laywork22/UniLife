import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/enums.dart';
import '../../data/models/exam.dart';
import '../../data/models/study_session.dart';
import '../../data/models/task.dart';
import '../../state/exam_provider.dart';
import '../../state/session_provider.dart';
import '../../state/task_provider.dart';

/// UC-8 — calendario mensile con eventi (esami / sessioni / task).
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected = DateTime.now();

  List<_CalendarEvent> _eventsForDay(DateTime day) {
    final exams = context.read<ExamProvider>().all;
    final sessions = context.read<SessionProvider>().all;
    final tasks = context.read<TaskProvider>().all;
    final events = <_CalendarEvent>[];
    for (final e in exams) {
      if (AppDateUtils.isSameDay(e.date, day)) {
        events.add(_CalendarEvent.exam(
          e,
          onTap: () => context.push('/exams/${e.id}'),
        ));
      }
    }
    for (final s in sessions) {
      if (AppDateUtils.isSameDay(s.date, day)) {
        events.add(_CalendarEvent.session(
          s,
          onTap: () => context.push('/sessions/${s.id}/edit'),
        ));
      }
    }
    for (final t in tasks) {
      if (t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!, day)) {
        events.add(_CalendarEvent.task(
          t,
          onTap: () => context.push('/tasks/${t.id}/edit'),
        ));
      }
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected ?? _focused;
    final events = _eventsForDay(selected);
    // Forza rebuild quando i provider notificano
    context.watch<ExamProvider>();
    context.watch<SessionProvider>();
    context.watch<TaskProvider>();

    // Codifica la data selezionata come query parameter per precompilare
    // la data nel form di nuova sessione (UC-3).
    final selectedIso = selected.toIso8601String();

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario: ${AppDateUtils.monthYear(_focused)}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sessions/new?date=$selectedIso'),
        icon: const Icon(Icons.add),
        label: const Text('Sessione'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'it_IT',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focused,
            selectedDayPredicate: (d) =>
                _selected != null && AppDateUtils.isSameDay(d, _selected!),
            onDaySelected: (sel, foc) {
              setState(() {
                _selected = sel;
                _focused = foc;
              });
            },
            onPageChanged: (foc) => setState(() => _focused = foc),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mese',
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader: _eventsForDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      'Nessun evento per il giorno selezionato',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
                    itemCount: events.length,
                    itemBuilder: (_, i) => _EventTile(event: events[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CalendarEvent {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _CalendarEvent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  factory _CalendarEvent.exam(Exam e, {required VoidCallback onTap}) =>
      _CalendarEvent(
        title: '${AppDateUtils.time(e.date)} — ${e.title}',
        subtitle: 'Esame',
        icon: Icons.event,
        color: AppColors.primary,
        onTap: onTap,
      );

  factory _CalendarEvent.session(StudySession s,
          {required VoidCallback onTap}) =>
      _CalendarEvent(
        title:
            '${AppDateUtils.time(s.startTime)} — ${s.title} (${s.type.label})',
        subtitle: 'Sessione',
        icon: Icons.menu_book,
        color: AppColors.info,
        onTap: onTap,
      );

  factory _CalendarEvent.task(Task t, {required VoidCallback onTap}) =>
      _CalendarEvent(
        title: t.title,
        subtitle: 'Task',
        icon: Icons.check_box_outlined,
        color: AppColors.warning,
        onTap: onTap,
      );
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final _CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.color.withValues(alpha: 0.15),
          child: Icon(event.icon, color: event.color),
        ),
        title: Text(event.title),
        subtitle: Text(event.subtitle),
        onTap: event.onTap,
        trailing: event.onTap == null
            ? null
            : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}
