import 'package:flutter/material.dart';

/// Brand palette from the PehlaPaisa design system.
abstract final class PPColors {
  static const Color night = Color(0xFF0E0F14);
  static const Color nightRaised = Color(0xFF171923);
  static const Color nightCard = Color(0xFF1D2030);
  static const Color savingsAmber = Color(0xFFFFC857);
  static const Color jarBlue = Color(0xFF7FA7E0);
  static const Color funPink = Color(0xFFE58FB8);
  static const Color funPurple = Color(0xFFB08FE5);
  static const Color success = Color(0xFF5FD39A);
  static const Color warning = Color(0xFFFF9F43);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color offWhite = Color(0xFFF2EFE9);
  static const Color mutedText = Color(0xFFA9A6B3);

  // Light theme counterparts: a warm "morning shelf".
  static const Color cream = Color(0xFFFBF6EE);
  static const Color creamCard = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF23212B);
  static const Color inkMuted = Color(0xFF6B6776);
  static const Color amberDeep = Color(0xFFE0A21B);
}

/// Business constants used across features.
abstract final class PPRules {
  /// Savings below this share of income needs an explicit confirmation.
  static const double minSavingsShare = 0.05;

  /// A jar below this fill ratio triggers a low balance alert…
  static const double lowJarRatio = 0.20;

  /// …but only when more than this many days remain in the cycle.
  static const int lowJarMinDaysLeft = 7;

  /// Days of consecutive expense logging for the Logger badge.
  static const int loggerStreakDays = 7;

  /// Savings share of income needed for the Bachat Champion badge.
  static const double bachatChampionShare = 0.25;

  /// Total saved needed for the Gullak Master badge.
  static const int gullakMasterTotal = 10000;

  /// Emergency fund suggestion = this many months of expenses.
  static const int emergencyFundMonths = 3;
}

/// Durations for the liquid animations (spec: 600–900 ms, easeOutCubic).
abstract final class PPMotion {
  static const Duration level = Duration(milliseconds: 800);
  static const Curve levelCurve = Curves.easeOutCubic;
  static const Duration pour = Duration(milliseconds: 1400);
  static const Duration pourSmall = Duration(milliseconds: 650);
}

/// App version shown on the About screen (keep in sync with pubspec.yaml).
const String appVersion = '1.4.0';
