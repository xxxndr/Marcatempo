// Punto da cui l'app legge/scrive le impostazioni a livello di cliente
// (locale): oggi solo grid_range_days, altri campi arriveranno (es. orario
// di apertura/chiusura, Blocco 10.2). Niente insert/delete qui: le righe
// clients le crea solo la piattaforma via service_role.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>(
  (ref) => ClientsRepository(),
);

class ClientsRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<Map<String, dynamic>> fetchOwn() async {
    return await _client.from('clients').select().single();
  }

  Future<void> setGridRangeDays(int days) async {
    await _client.rpc('set_client_grid_range_days', params: {'days': days});
  }
}
