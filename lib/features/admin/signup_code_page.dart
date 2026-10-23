// Schermata Admin che mostra il signup_code del proprio locale, da
// comunicare fuori dall'app ai nuovi dipendenti. Vedi product/app.md,
// sezione "Ordine di creazione degli accessi".
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupCodePage extends StatefulWidget {
  const SignupCodePage({super.key});

  @override
  State<SignupCodePage> createState() => _SignupCodePageState();
}

class _SignupCodePageState extends State<SignupCodePage> {
  late Future<String> _signupCodeFuture;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _signupCodeFuture = _fetchSignupCode();
  }

  Future<String> _fetchSignupCode() async {
    final row = await Supabase.instance.client
        .from('clients')
        .select('signup_code')
        .single();
    return row['signup_code'] as String;
  }

  Future<void> _regenerateCode() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rigenerare il codice?'),
        content: const Text(
          'Il codice attuale smette subito di funzionare. Chi non si è '
          'ancora registrato dovrà usare il nuovo codice.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Rigenera'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isRegenerating = true);
    try {
      final newCode = await Supabase.instance.client.rpc(
        'regenerate_client_signup_code',
      ) as String;
      setState(() => _signupCodeFuture = Future.value(newCode));
    } finally {
      if (mounted) setState(() => _isRegenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Codice di registrazione')),
      body: Center(
        child: FutureBuilder<String>(
          future: _signupCodeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Errore: ${snapshot.error}');
            }
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Comunica questo codice ai nuovi dipendenti:'),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.data!,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Condividi codice'),
                    onPressed: () {
                      SharePlus.instance.share(
                        ShareParams(
                          text:
                              'Codice di registrazione Marcatempo: ${snapshot.data!}',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: _isRegenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('Rigenera codice'),
                    onPressed: _isRegenerating ? null : _regenerateCode,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
