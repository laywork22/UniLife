import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/theme_preset.dart';
import '../../services/url_service.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../state/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Shareware Episode 1 di DOOM (1993) — distribuito liberamente da id Software,
  // hostato dall'Internet Archive con emulatore DOS in-browser.
  static const String _doomUrl =
      'https://archive.org/details/DoomsharewareEpisode';

  late final TextEditingController _name;
  int _versionTaps = 0;       // contatore totale, sblocca DOOM al 15°
  int _darkVersionTaps = 0;   // contatore in dark mode, sblocca dialog al 10°
  bool _easterEggUnlocked = false;
  bool _doomLaunched = false;
  bool _launchingDoom = false;

  @override
  void initState() {
    super.initState();
    _name =
        TextEditingController(text: context.read<ThemeProvider>().userName);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    await context.read<ThemeProvider>().setUserName(_name.text);
    if (!mounted) return;
    AppSnackbar.show(context, 'Nome aggiornato', icon: Icons.check_circle);
  }

  void _onVersionTap() {
    // Contatore globale: al 15° tap apriamo DOOM nel browser.
    setState(() => _versionTaps++);
    if (_versionTaps >= 15 && !_doomLaunched && !_launchingDoom) {
      _launchDoom();
    }

    // In parallelo: dialog easter egg al 10° tap consecutivo in dark mode.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) {
      if (_darkVersionTaps != 0) setState(() => _darkVersionTaps = 0);
      return;
    }
    if (_easterEggUnlocked) return;
    setState(() => _darkVersionTaps++);
    if (_darkVersionTaps >= 10) {
      _easterEggUnlocked = true;
      _showEasterEgg();
    }
  }

  Future<void> _launchDoom() async {
    _launchingDoom = true;
    AppSnackbar.show(context, '🎮 Lanciamento DOOM (1993)…',
        icon: Icons.videogame_asset);
    final ok = await UrlService.instance.open(_doomUrl);
    if (!mounted) return;
    setState(() {
      _launchingDoom = false;
      _doomLaunched = ok;
    });
    if (!ok) {
      AppSnackbar.show(context, 'Impossibile aprire DOOM nel browser',
          icon: Icons.error_outline);
    }
  }

  void _showEasterEgg() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 Easter egg sbloccato!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🚀', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              '«Studia tanto, dormi poco, prendi un caffè e ricomincia.»\n\n'
              '— Manuale ufficioso dello studente',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const _SectionTitle('Profilo'),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Il nome viene mostrato nella dashboard al posto di «Studente».',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _name,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveName(),
                    decoration: InputDecoration(
                      labelText: 'Il tuo nome',
                      prefixIcon: const Icon(Icons.person_outline),
                      suffixIcon: IconButton(
                        tooltip: 'Salva',
                        icon: const Icon(Icons.check),
                        onPressed: _saveName,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Aspetto'),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              value: theme.mode == ThemeMode.dark,
              onChanged: (v) => theme.setMode(
                v ? ThemeMode.dark : ThemeMode.light,
              ),
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: scheme.primary,
              ),
              title: const Text('Tema scuro'),
              subtitle: const Text('Attiva la dark mode dell\'app'),
            ),
          ),
          if (theme.mode != ThemeMode.system)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: TextButton.icon(
                onPressed: () => theme.setMode(ThemeMode.system),
                icon: const Icon(Icons.settings_suggest),
                label: const Text('Usa tema di sistema'),
              ),
            ),
          const SizedBox(height: 20),
          const _SectionTitle('Tema stagionale'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < ThemePreset.values.length; i++) ...[
                  _ThemePresetTile(
                    preset: ThemePreset.values[i],
                    selected: theme.preset == ThemePreset.values[i],
                    onTap: () => theme.setPreset(ThemePreset.values[i]),
                  ),
                  if (i < ThemePreset.values.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Informazioni'),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.info_outline, color: scheme.primary),
              title: const Text('Versione app'),
              subtitle: Text(AppConstants.appVersion),
              trailing: _easterEggUnlocked
                  ? Icon(Icons.emoji_events, color: scheme.secondary)
                  : null,
              onTap: _onVersionTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePresetTile extends StatelessWidget {
  const _ThemePresetTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final ThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = seasonalPalettes[preset]!;
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: palette.primary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: palette.accent,
            width: 3,
          ),
        ),
        child: Icon(palette.icon, color: Colors.white, size: 20),
      ),
      title: Text(palette.displayName),
      subtitle: Text(palette.description),
      trailing: selected
          ? Icon(Icons.check_circle, color: scheme.primary)
          : Icon(Icons.radio_button_unchecked,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.4,
          ),
        ),
      );
}
