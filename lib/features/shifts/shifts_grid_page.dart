// Griglia turni: sola visualizzazione, il drag-and-drop è il Blocco 4.2
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../employees/employees_repository.dart';
import 'shift_time_utils.dart';
import 'shifts_notifier.dart';

class ShiftsGridPage extends ConsumerWidget {
  const ShiftsGridPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridState = ref.watch(shiftsGridNotifierProvider);
    final notifier = ref.read(shiftsGridNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Turni')),
      body: gridState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Errore: $error')),
        data: (state) => Column(
          children: [
            _WindowHeader(state: state, notifier: notifier),
            const Divider(height: 1),
            Expanded(child: _Grid(state: state)),
          ],
        ),
      ),
    );
  }
}

class _WindowHeader extends StatelessWidget {
  const _WindowHeader({required this.state, required this.notifier});

  final ShiftsGridState state;
  final ShiftsGridNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final start = tz.TZDateTime.from(state.windowStart, europeRome);
    final end = tz.TZDateTime.from(
      state.windowEnd.subtract(const Duration(days: 1)),
      europeRome,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: notifier.previousWindow,
          ),
          Text(
            '${_formatDay(start)} - ${_formatDay(end)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: notifier.nextWindow,
          ),
        ],
      ),
    );
  }

  String _formatDay(tz.TZDateTime day) =>
      '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}';
}

class _Grid extends ConsumerWidget {
  const _Grid({required this.state});

  final ShiftsGridState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesStream = ref.watch(employeesRepositoryProvider).watchAll();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: employeesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final employees = snapshot.data!
            .where((e) => e['active'] as bool)
            .toList();
        if (employees.isEmpty) {
          return const Center(child: Text('Nessun dipendente attivo'));
        }

        final days = List.generate(
          state.rangeDays,
          (i) => tz.TZDateTime.from(
            addDaysRome(state.windowStart, i),
            europeRome,
          ),
        );

        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Dipendente')),
                for (final day in days)
                  DataColumn(
                    label: Text(
                      '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}',
                    ),
                  ),
              ],
              rows: [
                for (final employee in employees)
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '${employee['first_name']} ${employee['last_name']}',
                        ),
                      ),
                      for (final day in days)
                        DataCell(
                          Text(_shiftsOn(employee['id'] as String, day)),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _shiftsOn(String employeeId, tz.TZDateTime day) {
    final matches = state.shifts.where((shift) {
      if (shift['employee_id'] != employeeId) return false;
      final start = tz.TZDateTime.from(
        DateTime.parse(shift['start_at'] as String),
        europeRome,
      );
      return start.year == day.year &&
          start.month == day.month &&
          start.day == day.day;
    });
    return matches.map((shift) {
      final start = tz.TZDateTime.from(
        DateTime.parse(shift['start_at'] as String),
        europeRome,
      );
      final end = tz.TZDateTime.from(
        DateTime.parse(shift['end_at'] as String),
        europeRome,
      );
      return '${_formatTime(start)}-${_formatTime(end)}';
    }).join('\n');
  }

  String _formatTime(tz.TZDateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
