import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../app/state/repositories.dart';
import '../settings/data/app_settings.dart';
import '../settings/presentation/settings_controller.dart';

/// When to show the store's "Rate this app" popup: only after a happy
/// moment (a celebration), never in the first days, at most [maxAsks]
/// times, and at least [gap] apart. Google and Apple add their own limits
/// on top (the popup may simply not appear).
abstract final class ReviewPolicy {
  static const minDaysOfUse = 3;
  static const maxAsks = 3;
  static const gap = Duration(days: 90);

  static bool shouldAsk({
    required AppSettings settings,
    required DateTime now,
    required DateTime? firstUse,
  }) {
    if (firstUse == null) return false;
    if (now.difference(firstUse).inDays < minDaysOfUse) return false;
    if (settings.reviewPromptCount >= maxAsks) return false;
    final last = settings.lastReviewPromptAt;
    if (last != null && now.difference(last) < gap) return false;
    return true;
  }
}

/// Shows the platform's in-app review popup. Replaced by a fake in tests.
abstract class ReviewGateway {
  Future<void> request();
}

class StoreReviewGateway implements ReviewGateway {
  @override
  Future<void> request() async {
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) await review.requestReview();
    } catch (e) {
      debugPrint('In-app review unavailable: $e');
    }
  }
}

final reviewGatewayProvider = Provider<ReviewGateway>(
  (ref) => StoreReviewGateway(),
);

/// Asks for a rating if [ReviewPolicy] allows it, and remembers the ask.
Future<void> maybeAskForReview(Ref ref) async {
  final settings = ref.read(settingsProvider);
  final now = ref.read(clockProvider)();
  final profile = ref.read(repositoriesProvider).profile.read();
  if (!ReviewPolicy.shouldAsk(
    settings: settings,
    now: now,
    firstUse: profile?.createdAt,
  )) {
    return;
  }
  await ref
      .read(settingsProvider.notifier)
      .update(
        (s) => s.copyWith(
          reviewPromptCount: s.reviewPromptCount + 1,
          lastReviewPromptAt: now,
        ),
      );
  await ref.read(reviewGatewayProvider).request();
}

/// Lets widgets (which hold a WidgetRef) trigger [maybeAskForReview].
final reviewPrompterProvider = Provider<Future<void> Function()>(
  (ref) =>
      () => maybeAskForReview(ref),
);
