import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/features/growth/app_links.dart';
import 'package:pehla_paisa/features/growth/review_prompt.dart';
import 'package:pehla_paisa/features/settings/data/app_settings.dart';

void main() {
  final firstUse = DateTime(2026, 11, 1);

  group('ReviewPolicy', () {
    bool ask(AppSettings s, DateTime now, {DateTime? first}) =>
        ReviewPolicy.shouldAsk(
          settings: s,
          now: now,
          firstUse: first ?? firstUse,
        );

    test('never in the first 3 days of use', () {
      expect(ask(const AppSettings(), DateTime(2026, 11, 3)), isFalse);
      expect(ask(const AppSettings(), DateTime(2026, 11, 4)), isTrue);
    });

    test('never without a profile (before onboarding)', () {
      expect(
        ReviewPolicy.shouldAsk(
          settings: const AppSettings(),
          now: DateTime(2026, 12, 1),
          firstUse: null,
        ),
        isFalse,
      );
    });

    test('at least 90 days between asks', () {
      final asked = AppSettings(
        reviewPromptCount: 1,
        lastReviewPromptAt: DateTime(2026, 11, 10),
      );
      expect(ask(asked, DateTime(2027, 2, 7)), isFalse); // 89 days
      expect(ask(asked, DateTime(2027, 2, 8)), isTrue); // 90 days
    });

    test('at most 3 asks ever', () {
      final s = AppSettings(
        reviewPromptCount: 3,
        lastReviewPromptAt: DateTime(2025, 1, 1),
      );
      expect(ask(s, DateTime(2027, 1, 1)), isFalse);
    });
  });

  test('review history survives a save and load', () {
    final s = AppSettings(
      reviewPromptCount: 2,
      lastReviewPromptAt: DateTime(2026, 11, 17, 9, 30),
    );
    final back = AppSettings.fromMap(s.toMap());
    expect(back.reviewPromptCount, 2);
    expect(back.lastReviewPromptAt, DateTime(2026, 11, 17, 9, 30));
    // Settings saved by older versions load with no history.
    final old = AppSettings.fromMap(const {'language': 'hi'});
    expect(old.reviewPromptCount, 0);
    expect(old.lastReviewPromptAt, isNull);
  });

  test('Play Store link points at this app', () {
    expect(AppLinks.playStore, endsWith('id=com.pehlapaisa.app'));
  });
}
