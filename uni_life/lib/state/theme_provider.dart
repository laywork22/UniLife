import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/theme_preset.dart';

/// Tema chiaro/scuro/sistema + preset stagionale + nome utente,
/// tutto persistito in SharedPreferences (UI-1.2).
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  String _userName = 'Studente';
  ThemePreset _preset = ThemePreset.classico;

  ThemeMode get mode => _mode;
  String get userName => _userName;
  ThemePreset get preset => _preset;
  SeasonalPalette get palette => seasonalPalettes[_preset]!;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.themeModeKey);
    _mode = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _userName = prefs.getString(AppConstants.userNameKey) ?? 'Studente';
    final presetName = prefs.getString(AppConstants.themePresetKey);
    if (presetName != null) {
      _preset = ThemePreset.values.firstWhere(
        (p) => p.name == presetName,
        orElse: () => ThemePreset.classico,
      );
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeModeKey, mode.name);
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim().isEmpty ? 'Studente' : name.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userNameKey, _userName);
  }

  Future<void> setPreset(ThemePreset preset) async {
    _preset = preset;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themePresetKey, preset.name);
  }
}
