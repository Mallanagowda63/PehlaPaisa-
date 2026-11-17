import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/app/app.dart';
import 'package:pehla_paisa/app/state/repositories.dart';
import 'package:pehla_paisa/features/badges/data/badge.dart';
import 'package:pehla_paisa/features/badges/domain/celebration.dart';
import 'package:pehla_paisa/features/badges/presentation/celebration_queue.dart';
import 'package:pehla_paisa/features/growth/review_prompt.dart';

import 'harness.dart';

class FakeReview implements ReviewGateway {
  int asked = 0;

  @override
  Future<void> request() async => asked++;
}

/// Captures what the app hands to the phone's share sheet.
List<String> spyShares(WidgetTester tester) {
  final texts = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/share'),
    (call) async {
      texts.add(((call.arguments as Map)['text'] ?? '') as String);
      return 'dev.fluttercommunity.plus/share/success';
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      null,
    ),
  );
  return texts;
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(PehlaPaisaApp)));

Future<void> celebrate(WidgetTester tester, BadgeKey badge) async {
  containerOf(
    tester,
  ).read(celebrationQueueProvider.notifier).push(Celebration.badge(badge));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('celebrate_continue')), findsOneWidget);
  await tester.tap(find.byKey(const Key('celebrate_continue')));
  await tester.pumpAndSettle();
}

void main() {
  late Repositories repos;
  setUp(() async => repos = await seededRepos());

  testWidgets('Invite a friend shares a Hinglish message with the Play link', (
    tester,
  ) async {
    await pumpApp(tester, repos: repos, location: '/settings');
    final shared = spyShares(tester);
    await dismissCelebrations(tester);
    final invite = find.byKey(const Key('settings_invite'));
    await tester.scrollUntilVisible(invite, 200);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(invite);
    await tester.pumpAndSettle();
    expect(shared, hasLength(1));
    expect(shared.single, contains('Salary aate hi pehle bachao'));
    expect(
      shared.single,
      contains(
        'https://play.google.com/store/apps/details?id=com.pehlapaisa.app',
      ),
    );
  });

  testWidgets('Hindi invite message', (tester) async {
    await pumpApp(
      tester,
      repos: await seededRepos(language: 'hi'),
      location: '/settings',
    );
    final shared = spyShares(tester);
    await dismissCelebrations(tester);
    final invite = find.byKey(const Key('settings_invite'));
    await tester.scrollUntilVisible(invite, 200);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(invite);
    await tester.pumpAndSettle();
    expect(shared.single, contains('पहले बचाओ'));
    expect(shared.single, contains('com.pehlapaisa.app'));
  });

  testWidgets('share card says where to get the app', (tester) async {
    await pumpApp(tester, repos: repos, location: '/share');
    expect(find.text('Free on Google Play'), findsOneWidget);
  });

  testWidgets(
    'after a celebration the rating popup is requested once, then not again '
    'for 90 days',
    (tester) async {
      final review = FakeReview();
      await pumpApp(
        tester,
        repos: repos,
        location: '/home',
        overrides: [reviewGatewayProvider.overrideWithValue(review)],
      );
      await dismissCelebrations(tester);
      final before = review.asked;

      await celebrate(tester, BadgeKey.streak3);
      expect(review.asked, before + 1);
      expect(repos.settings.readOrDefault().reviewPromptCount, before + 1);

      await celebrate(tester, BadgeKey.streak6);
      expect(review.asked, before + 1, reason: 'within 90 days');
    },
  );

  testWidgets('no rating popup in the first days of use', (tester) async {
    final review = FakeReview();
    final fresh = await seededRepos();
    final p = fresh.profile.read()!;
    await fresh.profile.write(p.copyWith(createdAt: testNow));
    await pumpApp(
      tester,
      repos: fresh,
      location: '/home',
      overrides: [reviewGatewayProvider.overrideWithValue(review)],
    );
    await dismissCelebrations(tester);
    await celebrate(tester, BadgeKey.streak3);
    expect(review.asked, 0);
  });
}
