import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Notification ids used by the app.
abstract final class NotificationIds {
  static const int salaryDay = 1;
  static const int weeklyCheckin = 2;
  static const int dailyReminder = 3;
  static const int welcome = 4;
  static const int test = 5;

  /// Immediate alerts use ids from here upward.
  static const int alertBase = 100;
}

/// Thin wrapper around local notifications so business code stays testable.
abstract class NotificationGateway {
  Future<void> init();

  /// Asks the OS for permission (Android 13+, iOS). Returns true if granted.
  Future<bool> requestPermission();

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String channelName,
  });

  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required String channelName,
  });

  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelName,
  });

  Future<void> scheduleWeekly({
    required int id,
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelName,
  });

  Future<void> cancel(int id);
}

/// Used in tests and on platforms without notification support.
class NoopNotificationGateway implements NotificationGateway {
  final List<String> shown = [];
  final Map<int, String> scheduled = {};

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String channelName,
  }) async => shown.add(body);

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required String channelName,
  }) async => scheduled[id] = body;

  @override
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelName,
  }) async => scheduled[id] = body;

  @override
  Future<void> scheduleWeekly({
    required int id,
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelName,
  }) async => scheduled[id] = body;

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);
}

/// Real implementation on Android/iOS using flutter_local_notifications.
///
/// All times are in Asia/Kolkata (the app's default zone); inexact alarms
/// are used so no exact-alarm permission is needed.
class LocalNotificationGateway implements NotificationGateway {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  Future<void>? _initializing;

  static const String _channelId = 'pehlapaisa_reminders';

  @override
  Future<void> init() => _initializing ??= _init();

  Future<void> _init() async {
    // Small 10-year database instead of all history: faster startup.
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    try {
      await _plugin.initialize(settings: settings);
      _ready = true;
    } catch (e) {
      debugPrint('Notifications unavailable: $e');
    }
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    if (!_ready) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  NotificationDetails _details(String channelName) => NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      channelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      color: const Color(0xFFFFC857),
    ),
    iOS: const DarwinNotificationDetails(),
  );

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String channelName,
  }) async {
    await init();
    if (!_ready) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(channelName),
    );
  }

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required String channelName,
  }) async {
    await init();
    if (!_ready) return;
    final at = tz.TZDateTime(
      tz.local,
      when.year,
      when.month,
      when.day,
      when.hour,
      when.minute,
    );
    if (at.isBefore(tz.TZDateTime.now(tz.local))) return;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: at,
      notificationDetails: _details(channelName),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
    );
  }

  tz.TZDateTime _next(int hour, int minute, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (!at.isAfter(now) || (weekday != null && at.weekday != weekday)) {
      at = at.add(const Duration(days: 1));
    }
    return at;
  }

  @override
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelName,
  }) async {
    await init();
    if (!_ready) return;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: _next(hour, minute),
      notificationDetails: _details(channelName),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      title: title,
      body: body,
    );
  }

  @override
  Future<void> scheduleWeekly({
    required int id,
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelName,
  }) async {
    await init();
    if (!_ready) return;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: _next(hour, minute, weekday: weekday),
      notificationDetails: _details(channelName),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      title: title,
      body: body,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await init();
    if (!_ready) return;
    await _plugin.cancel(id: id);
  }
}
