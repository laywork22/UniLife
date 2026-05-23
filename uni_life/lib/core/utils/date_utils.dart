import 'package:intl/intl.dart';

/// Helper di formattazione e raggruppamento date.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dayMonthYear = DateFormat('dd/MM/yyyy', 'it_IT');
  static final DateFormat _dayMonthYearHour =
      DateFormat('dd/MM/yyyy HH:mm', 'it_IT');
  static final DateFormat _weekdayLong = DateFormat('EEEE', 'it_IT');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'it_IT');
  static final DateFormat _shortDay = DateFormat('d MMM', 'it_IT');
  static final DateFormat _time = DateFormat('HH:mm', 'it_IT');

  static String formatDate(DateTime d) => _dayMonthYear.format(d);
  static String formatDateTime(DateTime d) => _dayMonthYearHour.format(d);
  static String weekday(DateTime d) => _weekdayLong.format(d);
  static String monthYear(DateTime d) => _monthYear.format(d);
  static String shortDay(DateTime d) => _shortDay.format(d);
  static String time(DateTime d) => _time.format(d);

  /// Etichetta relativa: "Oggi", "Domani", "Tra N giorni", "Ieri", "Scaduto da N giorni".
  static String relativeLabel(DateTime target) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final t = DateTime(target.year, target.month, target.day);
    final diff = t.difference(today).inDays;
    if (diff == 0) return 'Oggi';
    if (diff == 1) return 'Domani';
    if (diff > 1) return 'Tra $diff giorni';
    if (diff == -1) return 'Ieri';
    return 'Scaduto da ${diff.abs()} giorni';
  }

  /// Raggruppa per giorno (chiave alle 00:00) usando un selettore.
  static Map<DateTime, List<T>> groupByDay<T>(
    Iterable<T> items,
    DateTime Function(T) selector,
  ) {
    final map = <DateTime, List<T>>{};
    for (final it in items) {
      final d = selector(it);
      final key = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(key, () => []).add(it);
    }
    return map;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Lunedì 00:00 della settimana che contiene [d].
  static DateTime startOfWeek(DateTime d) {
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }
}
