// Test di fumo: verifica che l'app si avvii correttamente mostrando la
// schermata di login (nessuna sessione attiva). Richiede il Supabase locale
// in esecuzione (supabase start): usa l'URL e la anon key di sviluppo
// locale, identiche per ogni installazione, non segrete.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:_marcatempo/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://127.0.0.1:54321',
      publishableKey: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
    );
  });

  testWidgets('App si avvia e mostra la schermata di login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MarcatempoApp()));
    await tester.pump();

    expect(find.text('Accesso Admin'), findsOneWidget);
  });
}
