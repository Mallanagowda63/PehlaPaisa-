import 'dart:math' as math;

import '../../../core/dates.dart';

/// The date range of a budget month. A cycle starts on the salary day and
/// ends the day before the next salary day.
///
/// A salary day that doesn't exist in a month (e.g. 31 in February) falls on
/// that month's last day.
class CycleRange {
  const CycleRange(this.start, this.end);

  /// First day (date only).
  final DateTime start;

  /// Last day, inclusive (date only).
  final DateTime end;

  /// `YYYY-MM` of the start date.
  String get id => monthId(start.year, start.month);

  int get totalDays => daysBetween(start, end) + 1;

  /// Fractional number of weeks, used for weekly budgets.
  double get weeks => totalDays / 7;

  /// Days remaining including today (0 once the cycle is over).
  int daysLeft(DateTime now) {
    final left = daysBetween(dateOnly(now), end) + 1;
    return left.clamp(0, totalDays);
  }

  bool contains(DateTime d) {
    final day = dateOnly(d);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  /// The salary-day anchor in a given month.
  static DateTime anchor(int year, int month, int salaryDay) {
    // DateTime normalizes month overflow (e.g. month 13 → January next year).
    final normalized = DateTime(year, month, 1);
    final day = math.min(
      salaryDay.clamp(1, 31),
      daysInMonth(normalized.year, normalized.month),
    );
    return DateTime(normalized.year, normalized.month, day);
  }

  /// The cycle that contains [date] for a user paid on [salaryDay].
  static CycleRange forDate(DateTime date, int salaryDay) {
    final today = dateOnly(date);
    final thisMonth = anchor(today.year, today.month, salaryDay);
    final start = today.isBefore(thisMonth)
        ? anchor(today.year, today.month - 1, salaryDay)
        : thisMonth;
    final nextStart = anchor(start.year, start.month + 1, salaryDay);
    final end = DateTime(nextStart.year, nextStart.month, nextStart.day - 1);
    return CycleRange(start, end);
  }

  /// The next salary date on or after [now] (today if today is salary day).
  /// A salary day missing from a month (e.g. 31 in Feb) falls on its last day.
  static DateTime nextSalaryDate(DateTime now, int salaryDay) {
    final today = dateOnly(now);
    final range = forDate(today, salaryDay);
    return range.start == today ? today : range.nextStart;
  }

  /// The first day of the cycle after this one.
  DateTime get nextStart => DateTime(end.year, end.month, end.day + 1);
}
