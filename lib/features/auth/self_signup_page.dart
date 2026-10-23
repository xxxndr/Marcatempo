// Passo 1 della registrazione self-service del dipendente: crea l'account
// Supabase Auth (email+password). Il profilo employees si completa nel
// passo successivo (complete_signup_page.dart), mostrato in automatico da
// AuthGate una volta autenticato. Vedi product/app.md, sezione "Ordine
// di creazione degli accessi".
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_form_scaffold.dart';

class SelfSignupPage extends StatefulWidget {
  const SelfSignupPage({super.key});

  @override
  State<SelfSignupPage> createState() => _SelfSignupPageState();
}

class _SelfSignupPageState extends State<SelfSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      TextInput.finishAutofillContext();
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrazione dipendente')),
      body: SafeArea(
        child: AppFormScaffold(
          formKey: _formKey,
          useAutofillGroup: true,
          isLoading: _isLoading,
          onSubmit: _signUp,
          submitLabel: 'Crea account',
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.newUsername],
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Inserisci l\'email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) => (value == null || value.length < 6)
                  ? 'Minimo 6 caratteri'
                  : null,
              onFieldSubmitted: (_) => _signUp(),
            ),
          ],
        ),
      ),
    );
  }
}
