/// Theme preference stored as a plain string so it survives enum changes.
enum AppThemeMode { system, dark, light }

/// App-wide preferences.
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.dark,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.reminderMinutes = 21 * 60,
    this.dailyReminderEnabled = false,
    this.salaryReminderEnabled = true,
    this.weeklyCheckinEnabled = true,
    this.lowBalanceAlertsEnabled = true,
    this.showAmountsOnShare = false,
    this.alertedKeys = const [],
    this.dismissedAlerts = const [],
    this.reviewPromptCount = 0,
    this.lastReviewPromptAt,
  });

  final AppThemeMode themeMode;

  /// `en` or `hi`.
  final String language;

  /// Master switch for all local notifications.
  final bool notificationsEnabled;

  /// Daily reminder time as minutes after midnight (default 9:00 PM).
  final int reminderMinutes;
  final bool dailyReminderEnabled;
  final bool salaryReminderEnabled;
  final bool weeklyCheckinEnabled;
  final bool lowBalanceAlertsEnabled;

  /// Whether share cards may show rupee amounts. Off by default for privacy.
  final bool showAmountsOnShare;

  /// Low balance alerts already sent, as `cycleId:jarId:kind` keys, so we
  /// never notify twice for the same jar in the same month.
  final List<String> alertedKeys;

  /// Warnings the user closed with ✕ (alert keys, see BudgetAlert.key).
  final List<String> dismissedAlerts;

  /// How often the store's rating popup was requested, and when last.
  final int reviewPromptCount;
  final DateTime? lastReviewPromptAt;

  int get reminderHour => reminderMinutes ~/ 60;
  int get reminderMinute => reminderMinutes % 60;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
    int? reminderMinutes,
    bool? dailyReminderEnabled,
    bool? salaryReminderEnabled,
    bool? weeklyCheckinEnabled,
    bool? lowBalanceAlertsEnabled,
    bool? showAmountsOnShare,
    List<String>? alertedKeys,
    List<String>? dismissedAlerts,
    int? reviewPromptCount,
    DateTime? lastReviewPromptAt,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      salaryReminderEnabled:
          salaryReminderEnabled ?? this.salaryReminderEnabled,
      weeklyCheckinEnabled: weeklyCheckinEnabled ?? this.weeklyCheckinEnabled,
      lowBalanceAlertsEnabled:
          lowBalanceAlertsEnabled ?? this.lowBalanceAlertsEnabled,
      showAmountsOnShare: showAmountsOnShare ?? this.showAmountsOnShare,
      alertedKeys: alertedKeys ?? this.alertedKeys,
      dismissedAlerts: dismissedAlerts ?? this.dismissedAlerts,
      reviewPromptCount: reviewPromptCount ?? this.reviewPromptCount,
      lastReviewPromptAt: lastReviewPromptAt ?? this.lastReviewPromptAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'themeMode': themeMode.name,
    'language': language,
    'notificationsEnabled': notificationsEnabled,
    'reminderMinutes': reminderMinutes,
    'dailyReminderEnabled': dailyReminderEnabled,
    'salaryReminderEnabled': salaryReminderEnabled,
    'weeklyCheckinEnabled': weeklyCheckinEnabled,
    'lowBalanceAlertsEnabled': lowBalanceAlertsEnabled,
    'showAmountsOnShare': showAmountsOnShare,
    'alertedKeys': alertedKeys,
    'dismissedAlerts': dismissedAlerts,
    'reviewPromptCount': reviewPromptCount,
    'lastReviewPromptAt': lastReviewPromptAt?.millisecondsSinceEpoch,
  };

  factory AppSettings.fromMap(Map<String, dynamic> m) => AppSettings(
    themeMode: AppThemeMode.values.firstWhere(
      (e) => e.name == m['themeMode'],
      orElse: () => AppThemeMode.dark,
    ),
    language: m['language'] as String? ?? 'en',
    notificationsEnabled: m['notificationsEnabled'] as bool? ?? true,
    reminderMinutes: (m['reminderMinutes'] as num?)?.toInt() ?? 21 * 60,
    dailyReminderEnabled: m['dailyReminderEnabled'] as bool? ?? false,
    salaryReminderEnabled: m['salaryReminderEnabled'] as bool? ?? true,
    weeklyCheckinEnabled: m['weeklyCheckinEnabled'] as bool? ?? true,
    lowBalanceAlertsEnabled: m['lowBalanceAlertsEnabled'] as bool? ?? true,
    showAmountsOnShare: m['showAmountsOnShare'] as bool? ?? false,
    alertedKeys: (m['alertedKeys'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    dismissedAlerts: (m['dismissedAlerts'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    reviewPromptCount: (m['reviewPromptCount'] as num?)?.toInt() ?? 0,
    lastReviewPromptAt: m['lastReviewPromptAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            (m['lastReviewPromptAt'] as num).toInt(),
          ),
  );
}
