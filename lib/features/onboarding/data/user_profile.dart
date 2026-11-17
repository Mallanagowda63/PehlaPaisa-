/// How the user earns: a fixed monthly salary or irregular gig income.
enum IncomeType { fixed, irregular }

/// The person using the app. There is exactly one profile per device.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.monthlyIncome,
    required this.salaryDay,
    required this.livesWithFamily,
    required this.incomeType,
    required this.language,
    required this.createdAt,
    required this.onboardingDone,
  });

  final String name;

  /// Expected monthly income in whole rupees (an estimate for irregular users).
  final int monthlyIncome;

  /// Day of month (1–31) on which a new budget cycle starts.
  final int salaryDay;
  final bool livesWithFamily;
  final IncomeType incomeType;

  /// `en` or `hi`.
  final String language;
  final DateTime createdAt;
  final bool onboardingDone;

  bool get isIrregular => incomeType == IncomeType.irregular;

  UserProfile copyWith({
    String? name,
    int? monthlyIncome,
    int? salaryDay,
    bool? livesWithFamily,
    IncomeType? incomeType,
    String? language,
    DateTime? createdAt,
    bool? onboardingDone,
  }) {
    return UserProfile(
      name: name ?? this.name,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      salaryDay: salaryDay ?? this.salaryDay,
      livesWithFamily: livesWithFamily ?? this.livesWithFamily,
      incomeType: incomeType ?? this.incomeType,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'monthlyIncome': monthlyIncome,
    'salaryDay': salaryDay,
    'livesWithFamily': livesWithFamily,
    'incomeType': incomeType.name,
    'language': language,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'onboardingDone': onboardingDone,
  };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    name: m['name'] as String? ?? '',
    monthlyIncome: (m['monthlyIncome'] as num?)?.toInt() ?? 0,
    salaryDay: (m['salaryDay'] as num?)?.toInt() ?? 1,
    livesWithFamily: m['livesWithFamily'] as bool? ?? false,
    incomeType: IncomeType.values.firstWhere(
      (e) => e.name == m['incomeType'],
      orElse: () => IncomeType.fixed,
    ),
    language: m['language'] as String? ?? 'en',
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (m['createdAt'] as num?)?.toInt() ?? 0,
    ),
    onboardingDone: m['onboardingDone'] as bool? ?? false,
  );
}
