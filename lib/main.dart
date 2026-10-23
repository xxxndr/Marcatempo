// Punto di ingresso dell'app: inizializza le variabili d'ambiente e la
// connessione al backend Supabase, poi instrada tra login, completamento
// registrazione, account disattivato e home in base allo stato di
// autenticazione corrente (AuthGate).
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/theme_controller.dart';
import 'features/admin/admin_home_page.dart';
import 'features/auth/complete_signup_page.dart';
import 'features/auth/inactive_account_page.dart';
import 'features/auth/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );
  await themeController.load();
  runApp(const ProviderScope(child: MarcatempoApp()));
}

class MarcatempoApp extends StatelessWidget {
  const MarcatempoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) => MaterialApp(
        title: 'Marcatempo',
        theme: ThemeData(brightness: Brightness.light),
        darkTheme: ThemeData(brightness: Brightness.dark),
        themeMode: mode,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  void _onSignupCompleted() => setState(() {});

  Future<String> _employeeStatus() async {
    final status = await Supabase.instance.client.rpc(
      'current_employee_status',
    );
    return status as String;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const LoginPage();
        }
        return FutureBuilder<String>(
          future: _employeeStatus(),
          builder: (context, statusSnapshot) {
            if (!statusSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return switch (statusSnapshot.data!) {
              'active' => const AdminHomePage(),
              'inactive' => const InactiveAccountPage(),
              _ => CompleteSignupPage(onCompleted: _onSignupCompleted),
            };
          },
        );
      },
    );
  }
}
