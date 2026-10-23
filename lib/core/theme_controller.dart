// Stato del tema (chiaro/scuro/sistema), persistito su disco e ascoltato
// da MaterialApp per ridisegnare l'app quando cambia. Vedi settings_page.dart
// per l'unico punto da cui si modifica.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefKey = 'theme_mode';

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeModePrefKey);
    value = ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefKey, mode.name);
  }
}

final themeController = ThemeController();
