import '../constants/app_constants.dart';

/// Funzioni di validazione pure usate dai form (UI-1.5).
class Validators {
  Validators._();

  static String? notEmpty(String? v, {String field = 'Campo'}) {
    if (v == null || v.trim().isEmpty) return '$field obbligatorio';
    return null;
  }

  static String? cfuRange(String? v) {
    if (v == null || v.isEmpty) return 'CFU obbligatori';
    final n = int.tryParse(v);
    if (n == null) return 'Inserisci un numero';
    if (n < AppConstants.cfuMin || n > AppConstants.cfuMax) {
      return 'CFU tra ${AppConstants.cfuMin} e ${AppConstants.cfuMax}';
    }
    return null;
  }

  /// 18..30 oppure 31 (lode). Stringa vuota = nessun voto registrato (valido).
  static String? gradeRange(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'Inserisci un numero';
    if (n < AppConstants.gradeMin || n > AppConstants.gradeMax) {
      return 'Voto 18..30 oppure 31 per la lode';
    }
    return null;
  }

  static String? futureDate(DateTime? d) {
    if (d == null) return 'Data obbligatoria';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (d.isBefore(today)) return 'La data non può essere nel passato';
    return null;
  }

  static String? semester(String? v) {
    if (v == null || v.trim().isEmpty) return 'Semestre obbligatorio';
    final n = int.tryParse(v);
    if (n == null || (n != 1 && n != 2)) return 'Inserisci 1 o 2';
    return null;
  }
}
