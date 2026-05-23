/// Costanti applicative riusate da più moduli.
class AppConstants {
  AppConstants._();

  static const String appName = 'UniLife';
  static const String appVersion = '1.0.0+1';
  static const String userNameKey = 'pref_user_name';
  static const String themeModeKey = 'pref_theme_mode';
  static const String themePresetKey = 'pref_theme_preset';

  static const int pomodoroMinutes = 25;
  static const int shortBreakMinutes = 5;
  static const int longBreakMinutes = 15;

  static const String dbName = 'uni_life.db';
  static const int dbVersion = 1;
  static const String tableCourses = 'courses';
  static const String tableExams = 'exams';
  static const String tableSessions = 'study_sessions';
  static const String tableTasks = 'tasks';

  // Voti: 18..30 con 31 = lode.
  static const int gradeMin = 18;
  static const int gradeMax = 31;
  static const int gradeLode = 31;

  static const int cfuMin = 1;
  static const int cfuMax = 30;
}
