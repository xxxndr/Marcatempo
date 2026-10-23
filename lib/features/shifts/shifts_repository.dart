// Punto da cui l'app legge i turni: query filtrata per intervallo di date,
// mai uno stream su tutta la tabella (i turni restano per anni per il
// vincolo GDPR di conservazione, vedi notes/dev/refactor.md -> R10 per
// l'eventuale cache dei mesi già letti).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final shiftsRepositoryProvider = Provider<ShiftsRepository>(
  (ref) => ShiftsRepository(),
);

class ShiftsRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchForRange({
    required DateTime start,
    required DateTime end,
  }) async {
    return await _client
        .from('shifts')
        .select()
        .gte('start_at', start.toIso8601String())
        .lt('start_at', end.toIso8601String())
        .order('start_at');
  }
}
