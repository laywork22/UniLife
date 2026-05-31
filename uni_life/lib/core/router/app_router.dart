import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/courses/course_detail_screen.dart';
import '../../features/courses/course_form_screen.dart';
import '../../features/courses/course_list_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/exams/calendar_screen.dart';
import '../../features/exams/exam_detail_screen.dart';
import '../../features/exams/exam_form_screen.dart';
import '../../features/exams/exam_list_screen.dart';
import '../../features/focus/focus_screen.dart';
import '../../features/planning/session_form_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/home_shell.dart';
import '../../features/tasks/task_form_screen.dart';

/// Centralizza la navigazione (FC-4): ShellRoute con NavigationBar a 4 tab
/// (Dashboard · Corsi · Esami · Focus) + rotte modali per form e dettagli.
final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/courses',
          name: 'courses',
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: CourseListScreen()),
          routes: [
            GoRoute(
              path: 'new',
              name: 'course-new',
              builder: (_, _) => const CourseFormScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'course-detail',
              builder: (_, state) =>
                  CourseDetailScreen(courseId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: ':id/edit',
              name: 'course-edit',
              builder: (_, state) =>
                  CourseFormScreen(courseId: state.pathParameters['id']),
            ),
          ],
        ),
        GoRoute(
          path: '/exams',
          name: 'exams',
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: ExamListScreen()),
          routes: [
            GoRoute(
              path: 'new',
              name: 'exam-new',
              builder: (_, _) => const ExamFormScreen(),
            ),
            GoRoute(
              path: 'calendar',
              name: 'exam-calendar',
              builder: (_, _) => const CalendarScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'exam-detail',
              builder: (_, state) =>
                  ExamDetailScreen(examId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: ':id/edit',
              name: 'exam-edit',
              builder: (_, state) =>
                  ExamFormScreen(examId: state.pathParameters['id']),
            ),
          ],
        ),
        GoRoute(
          path: '/focus',
          name: 'focus',
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: FocusScreen()),
        ),
      ],
    ),
    // Form raggiungibili dalla Dashboard (task) e dalla pianificazione (sessione).
    GoRoute(
      path: '/tasks/new',
      name: 'task-new',
      builder: (_, _) => const TaskFormScreen(),
    ),
    GoRoute(
      path: '/tasks/:id/edit',
      name: 'task-edit',
      builder: (_, state) =>
          TaskFormScreen(taskId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/sessions/new',
      name: 'session-new',
      builder: (_, state) {
        final dateParam = state.uri.queryParameters['date'];
        final initialDate =
            dateParam != null ? DateTime.tryParse(dateParam) : null;
        return SessionFormScreen(initialDate: initialDate);
      },
    ),
    GoRoute(
      path: '/sessions/:id/edit',
      name: 'session-edit',
      builder: (_, state) =>
          SessionFormScreen(sessionId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (_, _) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(
      child: Text('Rotta non trovata: ${state.uri}'),
    ),
  ),
);
