// Template settimanale fisso per dipendente (Blocco 3.5, riusabile dal
// generatore turni del Blocco 10): modello, I/O su weekly_schedule_templates,
// validazione e widget a 7 righe (giorno → riposo/continuativo/spezzato +
// orari). Vedi product/app.md, sezione "Generazione automatica dei
// turni".
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum DayType { rest, continuous, split }

const dayNames = [
  'Lunedì',
  'Martedì',
  'Mercoledì',
  'Giovedì',
  'Venerdì',
  'Sabato',
  'Domenica',
];

class DayTemplate {
  DayTemplate({
    required this.dayOfWeek,
    required this.dayType,
    this.start1,
    this.end1,
    this.start2,
    this.end2,
  });

  final int dayOfWeek;
  DayType dayType;
  TimeOfDay? start1;
  TimeOfDay? end1;
  TimeOfDay? start2;
  TimeOfDay? end2;
}

DayType _dayTypeFromString(String value) => switch (value) {
  'continuous' => DayType.continuous,
  'split' => DayType.split,
  _ => DayType.rest,
};

String _dayTypeToString(DayType type) => switch (type) {
  DayType.rest => 'rest',
  DayType.continuous => 'continuous',
  DayType.split => 'split',
};

TimeOfDay? _parseTime(String? value) {
  if (value == null) return null;
  final parts = value.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

String _formatTimeForDb(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}:00';

int _timeMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

/// Carica il template esistente del dipendente, 7 righe sempre presenti
/// (giorni mancanti su weekly_schedule_templates = riposo di default).
Future<List<DayTemplate>> loadWeeklySchedule(String employeeId) async {
  final rows = await Supabase.instance.client
      .from('weekly_schedule_templates')
      .select()
      .eq('employee_id', employeeId);
  final byDay = {for (final row in rows) row['day_of_week'] as int: row};
  return List.generate(7, (day) {
    final row = byDay[day];
    if (row == null) return DayTemplate(dayOfWeek: day, dayType: DayType.rest);
    return DayTemplate(
      dayOfWeek: day,
      dayType: _dayTypeFromString(row['day_type'] as String),
      start1: _parseTime(row['start_time_1'] as String?),
      end1: _parseTime(row['end_time_1'] as String?),
      start2: _parseTime(row['start_time_2'] as String?),
      end2: _parseTime(row['end_time_2'] as String?),
    );
  });
}

/// Upsert delle 7 righe, coerente col vincolo unique(employee_id, day_of_week).
Future<void> saveWeeklySchedule({
  required String clientId,
  required String employeeId,
  required List<DayTemplate> days,
}) async {
  await Supabase.instance.client.from('weekly_schedule_templates').upsert(
    [
      for (final day in days)
        {
          'client_id': clientId,
          'employee_id': employeeId,
          'day_of_week': day.dayOfWeek,
          'day_type': _dayTypeToString(day.dayType),
          'start_time_1': day.dayType == DayType.rest
              ? null
              : _formatTimeForDb(day.start1!),
          'end_time_1': day.dayType == DayType.rest
              ? null
              : _formatTimeForDb(day.end1!),
          'start_time_2': day.dayType == DayType.split
              ? _formatTimeForDb(day.start2!)
              : null,
          'end_time_2': day.dayType == DayType.split
              ? _formatTimeForDb(day.end2!)
              : null,
        },
    ],
    onConflict: 'employee_id,day_of_week',
  );
}

/// Rispecchia il check constraint della tabella: continuativo/spezzato
/// richiedono orari coerenti (fine dopo inizio, seconda fascia dopo prima).
String? validateWeeklySchedule(List<DayTemplate> days) {
  for (final day in days) {
    switch (day.dayType) {
      case DayType.rest:
        break;
      case DayType.continuous:
        if (day.start1 == null || day.end1 == null) {
          return '${dayNames[day.dayOfWeek]}: orari mancanti';
        }
        if (_timeMinutes(day.end1!) <= _timeMinutes(day.start1!)) {
          return '${dayNames[day.dayOfWeek]}: fine prima dell\'inizio';
        }
      case DayType.split:
        if (day.start1 == null ||
            day.end1 == null ||
            day.start2 == null ||
            day.end2 == null) {
          return '${dayNames[day.dayOfWeek]}: orari mancanti';
        }
        if (_timeMinutes(day.end1!) <= _timeMinutes(day.start1!) ||
            _timeMinutes(day.end2!) <= _timeMinutes(day.start2!) ||
            _timeMinutes(day.start2!) <= _timeMinutes(day.end1!)) {
          return '${dayNames[day.dayOfWeek]}: orari non coerenti';
        }
    }
  }
  return null;
}

/// Editor a 7 righe. Muta gli oggetti DayTemplate passati (stessa lista
/// tenuta dal chiamante) e chiama [onChanged] per far ridisegnare.
class WeeklyScheduleEditor extends StatelessWidget {
  const WeeklyScheduleEditor({
    required this.days,
    required this.onChanged,
    super.key,
  });

  final List<DayTemplate> days;
  final VoidCallback onChanged;

  Widget _timeButton(
    BuildContext context, {
    required String label,
    required TimeOfDay? time,
    required ValueChanged<TimeOfDay> onPicked,
  }) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time ?? const TimeOfDay(hour: 9, minute: 0),
          );
          if (picked != null) onPicked(picked);
        },
        child: Text(time == null ? label : time.format(context)),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, DayTemplate day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 90, child: Text(dayNames[day.dayOfWeek])),
              Expanded(
                child: DropdownButton<DayType>(
                  isExpanded: true,
                  value: day.dayType,
                  items: const [
                    DropdownMenuItem(
                      value: DayType.rest,
                      child: Text('Riposo'),
                    ),
                    DropdownMenuItem(
                      value: DayType.continuous,
                      child: Text('Continuativo'),
                    ),
                    DropdownMenuItem(
                      value: DayType.split,
                      child: Text('Spezzato'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    day.dayType = value;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          if (day.dayType == DayType.continuous ||
              day.dayType == DayType.split)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  _timeButton(
                    context,
                    label: 'Inizio',
                    time: day.start1,
                    onPicked: (t) {
                      day.start1 = t;
                      onChanged();
                    },
                  ),
                  const SizedBox(width: 8),
                  _timeButton(
                    context,
                    label: 'Fine',
                    time: day.end1,
                    onPicked: (t) {
                      day.end1 = t;
                      onChanged();
                    },
                  ),
                ],
              ),
            ),
          if (day.dayType == DayType.split)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  _timeButton(
                    context,
                    label: 'Inizio 2',
                    time: day.start2,
                    onPicked: (t) {
                      day.start2 = t;
                      onChanged();
                    },
                  ),
                  const SizedBox(width: 8),
                  _timeButton(
                    context,
                    label: 'Fine 2',
                    time: day.end2,
                    onPicked: (t) {
                      day.end2 = t;
                      onChanged();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (final day in days) _buildDayRow(context, day)],
    );
  }
}
