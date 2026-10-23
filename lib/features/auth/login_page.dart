// Schermata di login per l'Admin: raccoglie email e password e li
// verifica tramite Supabase Auth. Unico punto di ingresso per ora: il
// dipendente non farà login con email/password ma con QR/PIN.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_form_scaffold.dart';
import 'self_signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      TextInput.finishAutofillContext();
    } on AuthException catch (e) {
      if (!mounted) return;
      final banned =
          e.code == 'user_banned' ||
          e.message.toLowerCase().contains('banned');
      final message = banned
          ? 'Il tuo accesso è stato disattivato. Rivolgiti al responsabile del locale.'
          : 'Email o password non corretti.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accesso Admin')),
      body: SafeArea(
        child: AppFormScaffold(
          formKey: _formKey,
          useAutofillGroup: true,
          isLoading: _isLoading,
          onSubmit: _signIn,
          submitLabel: 'Accedi',
          trailing: [
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SelfSignupPage()),
              ),
              child: const Text(
                'Non hai un account? Registrati come dipendente',
              ),
            ),
          ],
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Inserisci l\'email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
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
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Inserisci la password'
                  : null,
              onFieldSubmitted: (_) => _signIn(),
            ),
          ],
        ),
      ),
    );
  }
}
