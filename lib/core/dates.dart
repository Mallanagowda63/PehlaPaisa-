/// Date helpers shared by the domain layer. All functions are pure.
library;

/// Strips the time part of [d].
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Number of days in [month] of [year].
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Whole calendar days from [a] to [b] (ignores time of day, DST safe).
int daysBetween(DateTime a, DateTime b) {
  final ua = DateTime.utc(a.year, a.month, a.day);
  final ub = DateTime.utc(b.year, b.month, b.day);
  return ub.difference(ua).inDays;
}

/// A stable sortable id for a month, e.g. `2026-03`.
String monthId(int year, int month) =>
    '$year-${month.toString().padLeft(2, '0')}';

/// Index useful to test whether two months are adjacent.
int monthIndex(int year, int month) => year * 12 + (month - 1);

/// Parses a [monthId] back into its month index.
int monthIndexFromId(String id) {
  final parts = id.split('-');
  return monthIndex(int.parse(parts[0]), int.parse(parts[1]));
}

/// The Monday that starts the week containing [d].
DateTime startOfWeek(DateTime d) {
  final day = dateOnly(d);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

/// True when [a] and [b] fall on the same calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
