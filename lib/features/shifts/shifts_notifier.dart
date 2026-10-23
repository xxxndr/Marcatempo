// Primo Notifier del progetto con stato condiviso tra più widget (notes/dev/refactor.md -> R6)
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../clients/clients_repository.dart';
import 'shift_time_utils.dart';
import 'shifts_repository.dart';

class ShiftsGridState {
  const ShiftsGridState({
    required this.windowStart,
    required this.rangeDays,
    required this.shifts,
  });

  final DateTime windowStart;
  final int rangeDays;
  final List<Map<String, dynamic>> shifts;

  DateTime get windowEnd => addDaysRome(windowStart, rangeDays);
}

final shiftsGridNotifierProvider =
    AsyncNotifierProvider<ShiftsGridNotifier, ShiftsGridState>(
      ShiftsGridNotifier.new,
    );

class ShiftsGridNotifier extends AsyncNotifier<ShiftsGridState> {
  int _offsetDays = 0;

  @override
  Future<ShiftsGridState> build() async {
    final client = await ref.read(clientsRepositoryProvider).fetchOwn();
    final rangeDays = client['grid_range_days'] as int;
    final windowStart = addDaysRome(startOfTodayRome(), _offsetDays);
    final shifts = await ref
        .read(shiftsRepositoryProvider)
        .fetchForRange(
          start: windowStart,
          end: addDaysRome(windowStart, rangeDays),
        );
    return ShiftsGridState(
      windowStart: windowStart,
      rangeDays: rangeDays,
      shifts: shifts,
    );
  }

  void nextWindow() {
    _offsetDays += state.value!.rangeDays;
    ref.invalidateSelf();
  }

  void previousWindow() {
    _offsetDays -= state.value!.rangeDays;
    ref.invalidateSelf();
  }
}
