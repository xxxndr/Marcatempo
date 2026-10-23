// Confini della griglia calcolati sempre in Europe/Rome (mai sul fuso del
// dispositivo, che può essere diverso, vedi notes/product/app.md ->
// turni_notturni_e_ora_legale), poi convertiti in UTC per interrogare
// Postgres (colonne timestamptz, vedi notes/dev/decisions.md ->
// timezone_database_postgres_utc).
import 'package:timezone/timezone.dart' as tz;

final tz.Location europeRome = tz.getLocation('Europe/Rome');

DateTime startOfTodayRome() {
  final now = tz.TZDateTime.now(europeRome);
  return tz.TZDateTime(europeRome, now.year, now.month, now.day).toUtc();
}

DateTime addDaysRome(DateTime utcMoment, int days) {
  final rome = tz.TZDateTime.from(utcMoment, europeRome);
  return tz.TZDateTime(
    europeRome,
    rome.year,
    rome.month,
    rome.day + days,
  ).toUtc();
}
