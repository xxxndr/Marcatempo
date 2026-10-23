// Home dopo il login: accesso alle sezioni Admin e logout. Oggi la vedono
// tutti i ruoli, la separazione per ruolo arriva più avanti (vedi
// notes/product/screens.md).
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../employees/employees_page.dart';
import '../shifts/shifts_grid_page.dart';
import '../shifts/shifts_settings_page.dart';
import 'settings_page.dart';
import 'signup_code_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcatempo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SignupCodePage())),
              child: const Text('Codice di registrazione dipendenti'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const EmployeesPage())),
              child: const Text('Dipendenti'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ShiftsGridPage()),
              ),
              child: const Text('Turni'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ShiftsSettingsPage()),
              ),
              child: const Text('Impostazioni turni'),
            ),
          ],
        ),
      ),
    );
  }
}
