import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wrapper sulle notifiche locali (IS-1.1).
/// Adattato all'API di `flutter_local_notifications` v21+, in cui sia
/// `initialize` sia `show` accettano solo parametri nominati.
/// In ambienti non supportati (es. Windows senza canale) i metodi degradano
/// silenziosamente.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const macos = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: 'Apri');
    const settings = InitializationSettings(
      android: android,
      iOS: ios,
      macOS: macos,
      linux: linux,
    );
    try {
      await _plugin.initialize(settings: settings);
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> showPomodoroDone() async {
    if (!_initialized) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pomodoro_channel',
        'Pomodoro',
        channelDescription: 'Notifiche di fine sessione Pomodoro',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );
    try {
      await _plugin.show(
        id: 1,
        title: 'Pomodoro completato',
        body: 'Ottimo lavoro! Concediti una pausa.',
        notificationDetails: details,
      );
    } catch (_) {/* noop */}
  }
}
