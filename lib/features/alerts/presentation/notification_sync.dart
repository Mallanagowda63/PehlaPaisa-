import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/state/repositories.dart';
import '../../../core/money.dart';
import '../../jars/presentation/jar_labels.dart';
import '../../settings/data/app_settings.dart';
import '../../settings/presentation/settings_controller.dart';
import '../data/notification_gateway.dart';
import '../domain/alert_engine.dart';

/// Keeps scheduled reminders in line with the user's data and settings, and
/// turns new in-app alerts into local notifications.
///
/// Reminders:
/// * Salary day → 9:00 AM on the next cycle's first day.
/// * Weekly check-in → Sunday 7:00 PM, with this week's spending so far.
/// * Daily reminder → at the user's chosen time (optional).
class NotificationSync {
  NotificationSync(this._ref);

  final Ref _ref;

  NotificationGateway get _gateway => _ref.read(notificationGatewayProvider);

  /// Re-schedules all repeating reminders.
  Future<void> syncSchedules() async {
    final settings = _ref.read(settingsProvider);
    final state = _ref.read(budgetProvider);
    final l = l10nFor(settings.language);
    final g = _gateway;
    final on = settings.notificationsEnabled && state.isOnboarded;

    final range = state.range;
    if (on && settings.salaryReminderEnabled && range != null) {
      final next = range.nextStart;
      await g.scheduleAt(
        id: NotificationIds.salaryDay,
        when: DateTime(next.year, next.month, next.day, 9),
        title: l.notifSalaryTitle,
        body: l.notifSalaryBody,
        channelName: l.notifChannel,
      );
    } else {
      await g.cancel(NotificationIds.salaryDay);
    }

    if (on && settings.weeklyCheckinEnabled) {
      final spent = AlertEngine.spentThisWeek(state.transactions, state.now);
      await g.scheduleWeekly(
        id: NotificationIds.weeklyCheckin,
        weekday: DateTime.sunday,
        hour: 19,
        minute: 0,
        title: l.notifWeeklyTitle,
        body: l.notifWeeklyBody(formatRupees(spent)),
        channelName: l.notifChannel,
      );
    } else {
      await g.cancel(NotificationIds.weeklyCheckin);
    }

    if (on && settings.dailyReminderEnabled) {
      await g.scheduleDaily(
        id: NotificationIds.dailyReminder,
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
        title: l.notifDailyTitle,
        body: l.notifDailyBody,
        channelName: l.notifChannel,
      );
    } else {
      await g.cancel(NotificationIds.dailyReminder);
    }
  }

  /// Sends a notification for each new low-glass / weekly food alert, at
  /// most once per glass per month.
  Future<void> dispatchAlerts() async {
    final settings = _ref.read(settingsProvider);
    final state = _ref.read(budgetProvider);
    final cycle = state.activeCycle;
    if (cycle == null ||
        !settings.notificationsEnabled ||
        !settings.lowBalanceAlertsEnabled) {
      return;
    }
    final l = l10nFor(settings.language);
    final family = state.profile?.livesWithFamily ?? false;
    final sent = settings.alertedKeys.toSet();
    final fresh = <String>[];
    var i = 0;
    for (final a in state.alerts) {
      if (a.kind == AlertKind.fillSalary) continue;
      final key = a.key(cycle.id);
      if (sent.contains(key)) continue;
      final jar = a.jarId == null ? null : state.jarById(a.jarId!);
      final name = jar == null
          ? ''
          : jarName(l, jar.type, jar.name, family: family);
      final body = a.kind == AlertKind.lowJar
          ? l.alertLow(name, a.percentEmpty, a.daysLeft)
          : l.alertFoodWeekly(formatRupees(a.spent), formatRupees(a.limit));
      await _gateway.showNow(
        id: NotificationIds.alertBase + i++,
        title: l.notifLowTitle,
        body: body,
        channelName: l.notifChannel,
      );
      fresh.add(key);
    }
    if (fresh.isEmpty) return;
    // Keep only this month's keys so the list never grows forever.
    final keep = [
      ...settings.alertedKeys.where((k) => k.startsWith('${cycle.id}:')),
      ...fresh,
    ];
    await _ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(alertedKeys: keep));
  }
}

bool _remindersChanged(AppSettings a, AppSettings b) =>
    a.notificationsEnabled != b.notificationsEnabled ||
    a.salaryReminderEnabled != b.salaryReminderEnabled ||
    a.weeklyCheckinEnabled != b.weeklyCheckinEnabled ||
    a.dailyReminderEnabled != b.dailyReminderEnabled ||
    a.reminderMinutes != b.reminderMinutes ||
    a.language != b.language;

/// Watching this provider (done in the root widget) re-syncs reminders
/// whenever budget data or settings change.
final notificationSyncProvider = Provider<NotificationSync>((ref) {
  final sync = NotificationSync(ref);
  ref.listen(budgetProvider, (_, _) => unawaited(sync.syncSchedules()));
  ref.listen<AppSettings>(settingsProvider, (prev, next) {
    // Only reschedule when something reminder-related changed.
    if (prev != null && !_remindersChanged(prev, next)) return;
    unawaited(sync.syncSchedules());
  });
  Future.microtask(sync.syncSchedules);
  return sync;
});
