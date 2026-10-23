// Impostazioni turni (solo Admin, screens.md): oggi solo il range di
// giorni mostrati in griglia, in futuro anche aree e copertura minima
// (Blocco 10.1/10.3)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_form_scaffold.dart';
import '../clients/clients_repository.dart';
import 'shifts_notifier.dart';

class ShiftsSettingsPage extends ConsumerStatefulWidget {
  const ShiftsSettingsPage({super.key});

  @override
  ConsumerState<ShiftsSettingsPage> createState() =>
      _ShiftsSettingsPageState();
}

class _ShiftsSettingsPageState extends ConsumerState<ShiftsSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _rangeDaysController = TextEditingController();
  bool _isLoading = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentValue();
  }

  Future<void> _loadCurrentValue() async {
    final client = await ref.read(clientsRepositoryProvider).fetchOwn();
    _rangeDaysController.text = (client['grid_range_days'] as int).toString();
    if (mounted) setState(() => _isLoaded = true);
  }

  @override
  void dispose() {
    _rangeDaysController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(clientsRepositoryProvider)
          .setGridRangeDays(int.parse(_rangeDaysController.text));
      ref.invalidate(shiftsGridNotifierProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni turni')),
      body: SafeArea(
        child: !_isLoaded
            ? const Center(child: CircularProgressIndicator())
            : AppFormScaffold(
                formKey: _formKey,
                isLoading: _isLoading,
                onSubmit: _save,
                submitLabel: 'Salva',
                children: [
                  TextFormField(
                    controller: _rangeDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giorni mostrati nella griglia turni',
                    ),
                    validator: (value) {
                      final days = int.tryParse(value ?? '');
                      return (days == null || days < 1)
                          ? 'Inserisci un numero di giorni valido'
                          : null;
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
