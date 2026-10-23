// Pagina Impostazioni condivisa tra i ruoli (Blocco 21): punto d'appoggio
// per le voci di configurazione future. Prima voce: tema chiaro/scuro/
// sistema, vedi theme_controller.dart.
import 'package:flutter/material.dart';

import '../../core/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: SafeArea(
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeController,
          builder: (context, mode, _) => RadioGroup<ThemeMode>(
            groupValue: mode,
            onChanged: (value) => themeController.setThemeMode(value!),
            child: ListView(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text('Tema di sistema'),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Tema chiaro'),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Tema scuro'),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
