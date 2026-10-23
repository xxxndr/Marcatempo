// Schermata Admin: lista dei dipendenti del proprio locale, lettura in
// tempo reale via stream Supabase. RLS (employees_select_admin_manager)
// filtra già per client_id, nessun filtro esplicito lato client.
// Chi ha lasciato il locale si disattiva, non si cancella: nessun pulsante
// di eliminazione è esposto qui (vedi product/app.md, sezione "Creazione
// ed eliminazione profilo dipendente (Edge Function)").
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'create_employee_page.dart';
import 'edit_employee_page.dart';
import 'employees_repository.dart';

Future<void> _setEmployeeActive(
  BuildContext context,
  EmployeesRepository repository,
  String id,
  String fullName,
  bool active,
) async {
  if (!active) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disattivare il dipendente?'),
        content: Text(
          '$fullName non potrà più accedere all\'app. '
          'Turni, timbrature e assenze già registrati restano consultabili.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disattiva'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
  }

  try {
    await repository.setActive(id: id, active: active);
  } on FunctionsHttpException catch (e) {
    if (!context.mounted) return;
    final message = switch (e.status) {
      403 => 'Non hai i permessi per modificare questo dipendente.',
      404 => 'Dipendente non trovato.',
      409 => 'Non puoi disattivare il tuo stesso account.',
      _ => 'Errore imprevisto, riprova.',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class EmployeesPage extends ConsumerStatefulWidget {
  const EmployeesPage({super.key});

  @override
  ConsumerState<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends ConsumerState<EmployeesPage> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(employeesRepositoryProvider);
    final stream = repository.watchAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dipendenti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateEmployeePage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            value: _showInactive,
            onChanged: (value) => setState(() => _showInactive = value),
            title: const Text('Mostra disattivati'),
            dense: true,
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final employees = snapshot.data!
                    .where((e) => _showInactive || e['active'] as bool)
                    .toList();
                if (employees.isEmpty) {
                  return const Center(
                    child: Text('Nessun dipendente registrato'),
                  );
                }
                return ListView.separated(
                  itemCount: employees.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    final id = employee['id'] as String;
                    final active = employee['active'] as bool;
                    final fullName =
                        '${employee['first_name']} ${employee['last_name']}';
                    return ListTile(
                      title: Text(fullName),
                      subtitle: active ? null : const Text('Disattivato'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditEmployeePage(employee: employee),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: employee['role'] as String,
                            items: const [
                              DropdownMenuItem(
                                value: 'employee',
                                child: Text('Employee'),
                              ),
                              DropdownMenuItem(
                                value: 'manager',
                                child: Text('Manager'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: active
                                ? (newRole) async {
                                    if (newRole == null) return;
                                    await repository.updateRole(
                                      id: id,
                                      role: newRole,
                                    );
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: Icon(
                              active ? Icons.person_off_outlined : Icons.undo,
                            ),
                            tooltip: active ? 'Disattiva' : 'Riattiva',
                            onPressed: () => _setEmployeeActive(
                              context,
                              repository,
                              id,
                              fullName,
                              !active,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
