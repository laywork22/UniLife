import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'state/course_provider.dart';
import 'state/exam_provider.dart';
import 'state/pomodoro_provider.dart';
import 'state/session_provider.dart';
import 'state/stats_provider.dart';
import 'state/task_provider.dart';
import 'state/theme_provider.dart';

/// Root widget. Monta tutti i provider e configura router/theme.
class UniLifeApp extends StatelessWidget {
  const UniLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => CourseProvider()..load()),
        ChangeNotifierProvider(create: (_) => ExamProvider()..load()),
        ChangeNotifierProvider(create: (_) => SessionProvider()..load()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..load()),
        ChangeNotifierProvider(
          create: (ctx) {
            final sessions = ctx.read<SessionProvider>();
            final tasks = ctx.read<TaskProvider>();
            return PomodoroProvider(
              onProgressSaved: () async {
                await sessions.load();
                await tasks.load();
              },
            );
          },
        ),
        ChangeNotifierProxyProvider3<CourseProvider, ExamProvider,
            TaskProvider, StatsProvider>(
          create: (ctx) => StatsProvider(
            courses: ctx.read<CourseProvider>(),
            exams: ctx.read<ExamProvider>(),
            tasks: ctx.read<TaskProvider>(),
          ),
          update: (_, courses, exams, tasks, previous) =>
              previous ??
              StatsProvider(courses: courses, exams: exams, tasks: tasks),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(theme.palette),
            darkTheme: AppTheme.dark(theme.palette),
            themeMode: theme.mode,
            routerConfig: appRouter,
            locale: const Locale('it', 'IT'),
            supportedLocales: const [Locale('it', 'IT'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
