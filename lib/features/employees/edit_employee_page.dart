// Form esteso anagrafica Admin (Blocco 3.5): ore contrattuali, orario
// fisso, Senior, ore di default per dipendenti flessibili, template
// settimanale (weekly_schedule_editor.dart) per dipendenti a orario fisso.
// Scrive su employees via RLS employees_write_admin. Vedi
// product/app.md, sezione "Generazione automatica dei turni".
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_form_scaffold.dart';
import 'weekly_schedule_editor.dart';

class EditEmployeePage extends StatefulWidget {
  const EditEmployeePage({required this.employee, super.key});

  final Map<String, dynamic> employee;

  @override
  State<EditEmployeePage> createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weeklyContractedHoursController;
  late final TextEditingController _defaultShiftHoursController;
  late bool _hasFixedWeeklySchedule;
  late bool _senior;
  bool _isLoading = false;
  bool _templatesLoading = true;
  List<DayTemplate> _dayTemplates = [];

  @override
  void initState() {
    super.initState();
    _weeklyContractedHoursController = TextEditingController(
      text: widget.employee['weekly_contracted_hours']?.toString() ?? '',
    );
    _defaultShiftHoursController = TextEditingController(
      text: widget.employee['default_shift_hours']?.toString() ?? '',
    );
    _hasFixedWeeklySchedule =
        widget.employee['has_fixed_weekly_schedule'] as bool? ?? false;
    _senior = widget.employee['senior'] as bool? ?? false;
    _loadTemplates();
  }

  @override
  void dispose() {
    _weeklyContractedHoursController.dispose();
    _defaultShiftHoursController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    try {
      final days = await loadWeeklySchedule(widget.employee['id'] as String);
      if (!mounted) return;
      setState(() {
        _dayTemplates = days;
        _templatesLoading = false;
      });
    } on PostgrestException catch (_) {
      if (!mounted) return;
      setState(() {
        _dayTemplates = List.generate(
          7,
          (day) => DayTemplate(dayOfWeek: day, dayType: DayType.rest),
        );
        _templatesLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossibile caricare il template settimanale.'),
        ),
      );
    }
  }

  double? _parseHours(String text) {
    final normalized = text.trim().replaceAll(',', '.');
    return normalized.isEmpty ? null : double.tryParse(normalized);
  }

  String? _validateWeeklyContractedHours(String? value) {
    final hours = _parseHours(value ?? '');
    if (value != null && value.trim().isNotEmpty && hours == null) {
      return 'Numero non valido';
    }
    if (hours != null && (hours <= 0 || hours > 78)) {
      return 'Deve essere tra 0 e 78';
    }
    return null;
  }

  String? _validateDefaultShiftHours(String? value) {
    final hours = _parseHours(value ?? '');
    if (value != null && value.trim().isNotEmpty && hours == null) {
      return 'Numero non valido';
    }
    if (hours != null && (hours <= 0 || hours > 13)) {
      return 'Deve essere tra 0 e 13';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_hasFixedWeeklySchedule) {
      final templateError = validateWeeklySchedule(_dayTemplates);
      if (templateError != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(templateError)));
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final employeeId = widget.employee['id'] as String;
      await Supabase.instance.client
          .from('employees')
          .update({
            'weekly_contracted_hours': _parseHours(
              _weeklyContractedHoursController.text,
            ),
            'has_fixed_weekly_schedule': _hasFixedWeeklySchedule,
            'senior': _senior,
            'default_shift_hours': _hasFixedWeeklySchedule
                ? null
                : _parseHours(_defaultShiftHoursController.text),
          })
          .eq('id', employeeId);

      if (_hasFixedWeeklySchedule) {
        await saveWeeklySchedule(
          clientId: widget.employee['client_id'] as String,
          employeeId: employeeId,
          days: _dayTemplates,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } on PostgrestException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore imprevisto, riprova.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName =
        '${widget.employee['first_name']} ${widget.employee['last_name']}';
    return Scaffold(
      appBar: AppBar(title: Text(fullName)),
      body: SafeArea(
        child: AppFormScaffold(
          formKey: _formKey,
          scrollable: true,
          crossAxisAlignment: CrossAxisAlignment.start,
          isLoading: _isLoading,
          onSubmit: _save,
          submitLabel: 'Salva',
          children: [
            TextFormField(
              controller: _weeklyContractedHoursController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Ore contrattuali settimanali',
              ),
              validator: _validateWeeklyContractedHours,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Orario fisso settimanale'),
              value: _hasFixedWeeklySchedule,
              onChanged: (value) =>
                  setState(() => _hasFixedWeeklySchedule = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Senior'),
              value: _senior,
              onChanged: (value) => setState(() => _senior = value),
            ),
            if (_hasFixedWeeklySchedule) ...[
              const SizedBox(height: 16),
              Text(
                'Template settimanale',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (_templatesLoading)
                const Center(child: CircularProgressIndicator())
              else
                WeeklyScheduleEditor(
                  days: _dayTemplates,
                  onChanged: () => setState(() {}),
                ),
            ] else ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _defaultShiftHoursController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Ore di default per turno',
                ),
                validator: _validateDefaultShiftHours,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
