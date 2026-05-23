import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/course.dart';
import '../../data/models/enums.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/search_field.dart';
import '../../state/course_provider.dart';
import '../../state/exam_provider.dart';
import 'widgets/course_card.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(_onTabChange);
  }

  void _onTabChange() {
    final p = context.read<CourseProvider>();
    p.setFilter(
        _tabs.index == 0 ? CourseStatus.inCorso : CourseStatus.superato);
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChange);
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesProv = context.watch<CourseProvider>();
    final examsProv = context.watch<ExamProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course List'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Correnti'),
            Tab(text: 'Terminate'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/courses/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SearchField(
              hintText: 'Cerca per nome o docente…',
              onChanged: coursesProv.setQuery,
            ),
          ),
          Expanded(
            child: coursesProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _CoursesList(
                    courses: coursesProv.visible,
                    progressForCourse: (Course c) {
                      final exams = examsProv.byCourse(c.id);
                      if (exams.isEmpty) return 0.0;
                      final done = exams
                          .where((e) => e.status == ExamStatus.completato)
                          .length;
                      return done / exams.length;
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CoursesList extends StatelessWidget {
  const _CoursesList({
    required this.courses,
    required this.progressForCourse,
  });

  final List<Course> courses;
  final double Function(Course) progressForCourse;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return EmptyState(
        icon: Icons.menu_book,
        title: 'Nessun corso',
        message: 'Aggiungi il tuo primo corso per iniziare.',
        ctaLabel: 'Nuovo corso',
        onCta: () => context.push('/courses/new'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 96),
      itemCount: courses.length,
      itemBuilder: (_, i) {
        final c = courses[i];
        return CourseCard(
          course: c,
          progress: progressForCourse(c),
          onTap: () => context.push('/courses/${c.id}'),
        );
      },
    );
  }
}
