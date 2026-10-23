// Form fallback manuale Admin: crea un dipendente quando il self-signup non
// va a buon fine per un problema tecnico. Chiama l'edge function
// create-employee, che forza sempre role="employee" e usa il client_id
// dell'Admin che chiama. Vedi product/app.md, sezione "Creazione ed
// eliminazione profilo dipendente (Edge Function)".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_form_scaffold.dart';
import 'employees_repository.dart';

class CreateEmployeePage extends ConsumerStatefulWidget {
  const CreateEmployeePage({super.key});

  @override
  ConsumerState<CreateEmployeePage> createState() =>
      _CreateEmployeePageState();
}

class _CreateEmployeePageState extends ConsumerState<CreateEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _createEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(employeesRepositoryProvider).create(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } on FunctionsHttpException catch (e) {
      if (!mounted) return;
      final message = switch (e.status) {
        400 => 'Dati non validi, o email già registrata.',
        403 => 'Non hai i permessi per creare un dipendente.',
        _ => 'Errore imprevisto, riprova.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crea dipendente')),
      body: SafeArea(
        child: AppFormScaffold(
          formKey: _formKey,
          isLoading: _isLoading,
          onSubmit: _createEmployee,
          submitLabel: 'Crea dipendente',
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Inserisci il nome' : null,
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Inserisci l\'email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
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
              onFieldSubmitted: (_) => _createEmployee(),
            ),
          ],
        ),
      ),
    );
  }
}
