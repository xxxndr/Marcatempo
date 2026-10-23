// Passo 2 della registrazione self-service del dipendente: nome, cognome e
// signup_code del locale, poi chiama la edge function self-signup che crea
// la riga employees. Mostrata in automatico da AuthGate quando c'è una
// sessione autenticata ma nessun profilo employees ancora. Vedi
// product/app.md, sezione "Ordine di creazione degli accessi".
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_form_scaffold.dart';

class CompleteSignupPage extends StatefulWidget {
  const CompleteSignupPage({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<CompleteSignupPage> createState() => _CompleteSignupPageState();
}

class _CompleteSignupPageState extends State<CompleteSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _signupCodeController = TextEditingController();
  bool _isLoading = false;
  bool _isBlocked = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _signupCodeController.dispose();
    super.dispose();
  }

  Future<void> _completeSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.functions.invoke(
        'self-signup',
        body: {
          'signup_code': _signupCodeController.text.trim(),
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
        },
      );
      widget.onCompleted();
    } on FunctionsHttpException catch (e) {
      if (!mounted) return;
      final message = switch (e.status) {
        403 =>
          'Troppi tentativi con questo account: rivolgiti '
              'all\'amministratore del locale.',
        404 => 'Codice non valido, controlla e riprova.',
        409 => 'Profilo già registrato.',
        _ => 'Errore imprevisto, riprova.',
      };
      if (e.status == 403) setState(() => _isBlocked = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa la registrazione'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: _isBlocked
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Troppi tentativi con questo account. Rivolgiti '
                      'all\'amministratore del locale per la creazione '
                      'manuale del profilo.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            : AppFormScaffold(
                formKey: _formKey,
                isLoading: _isLoading,
                onSubmit: _completeSignup,
                submitLabel: 'Completa registrazione',
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Inserisci il nome'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Cognome'),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Inserisci il cognome'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _signupCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Codice del locale',
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Inserisci il codice'
                        : null,
                    onFieldSubmitted: (_) => _completeSignup(),
                  ),
                ],
              ),
      ),
    );
  }
}
