import 'package:flutter/material.dart';

/// Temi stagionali selezionabili dalle impostazioni.
enum ThemePreset {
  classico,
  halloween,
  natale,
  pasqua,
  primavera,
}

/// Una palette compatta che descrive un tema stagionale.
class SeasonalPalette {
  final String displayName;
  final String description;
  final IconData icon;
  final Color primary;
  final Color accent;
  final Color background;

  const SeasonalPalette({
    required this.displayName,
    required this.description,
    required this.icon,
    required this.primary,
    required this.accent,
    required this.background,
  });
}

/// Mappa preset → palette. I valori primary devono garantire contrasto con il
/// testo bianco usato negli header.
const Map<ThemePreset, SeasonalPalette> seasonalPalettes = {
  ThemePreset.classico: SeasonalPalette(
    displayName: 'Classico',
    description: 'Petrolio e arancio caldo',
    icon: Icons.school,
    primary: Color(0xFF2C5F66),
    accent: Color(0xFFE8A540),
    background: Color(0xFFE6ECEC),
  ),
  ThemePreset.halloween: SeasonalPalette(
    displayName: 'Halloween',
    description: 'Viola notte e zucca',
    icon: Icons.nightlight_round,
    primary: Color(0xFF4A148C),
    accent: Color(0xFFFF6F00),
    background: Color(0xFFEDE3F2),
  ),
  ThemePreset.natale: SeasonalPalette(
    displayName: 'Natale',
    description: 'Rosso vischio e pino',
    icon: Icons.park,
    primary: Color(0xFFB71C1C),
    accent: Color(0xFF2E7D32),
    background: Color(0xFFF1E5E5),
  ),
  ThemePreset.pasqua: SeasonalPalette(
    displayName: 'Pasqua',
    description: 'Lavanda pastello e crema',
    icon: Icons.egg_outlined,
    primary: Color(0xFF5E72B8),
    accent: Color(0xFFFFB74D),
    background: Color(0xFFE8EBF5),
  ),
  ThemePreset.primavera: SeasonalPalette(
    displayName: 'Primavera',
    description: 'Verde foglia e ciliegio',
    icon: Icons.local_florist,
    primary: Color(0xFF2E7D32),
    accent: Color(0xFFEC407A),
    background: Color(0xFFE6EFE7),
  ),
};
