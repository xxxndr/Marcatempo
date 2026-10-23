// Unico punto da cui l'app parla con il backend a proposito dei dipendenti:
// nomi delle edge function, forma delle richieste e query dirette vivono
// qui, non sparsi nelle schermate. Le eccezioni sono propagate al chiamante,
// perché il messaggio da mostrare all'utente dipende dalla schermata.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final employeesRepositoryProvider = Provider<EmployeesRepository>(
  (ref) => EmployeesRepository(),
);

class EmployeesRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> watchAll() {
    return _client.from('employees').stream(primaryKey: ['id']).order(
      'last_name',
    );
  }

  Future<void> create({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    await _client.functions.invoke(
      'create-employee',
      body: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
  }

  Future<void> setActive({required String id, required bool active}) async {
    await _client.functions.invoke(
      'set-employee-active',
      body: {'id': id, 'active': active},
    );
  }

  Future<void> updateRole({required String id, required String role}) async {
    await _client.from('employees').update({'role': role}).eq('id', id);
  }
}
