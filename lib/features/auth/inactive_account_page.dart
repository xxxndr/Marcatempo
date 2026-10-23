// Schermata di un dipendente disattivato che ha ancora una sessione aperta:
// il ban lato Auth blocca i login nuovi ma non revoca il token già emesso,
// così senza questa pagina si troverebbe un'app vuota senza spiegazione.
// Vedi product/app.md, sezione "Creazione ed eliminazione profilo
// dipendente (Edge Function)".
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InactiveAccountPage extends StatelessWidget {
  const InactiveAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_off_outlined, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Account disattivato',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Il tuo accesso è stato disattivato. '
                    'Rivolgiti al responsabile del locale.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Supabase.instance.client.auth.signOut(),
                    child: const Text('Esci'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
