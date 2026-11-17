import '../data/badge.dart';

enum CelebrationKind { badge, goal, streak, savingsFilled }

/// Something worth confetti. Queued by the controller, shown by the UI.
class Celebration {
  const Celebration._(
    this.kind, {
    this.badge,
    this.goalName,
    this.goalEmoji,
    this.amount,
    this.streak,
  });

  const Celebration.badge(BadgeKey key)
    : this._(CelebrationKind.badge, badge: key);

  const Celebration.goal({
    required String name,
    required String emoji,
    required int amount,
  }) : this._(
         CelebrationKind.goal,
         goalName: name,
         goalEmoji: emoji,
         amount: amount,
       );

  const Celebration.streak(int months)
    : this._(CelebrationKind.streak, streak: months);

  const Celebration.savingsFilled(int amount)
    : this._(CelebrationKind.savingsFilled, amount: amount);

  final CelebrationKind kind;
  final BadgeKey? badge;
  final String? goalName;
  final String? goalEmoji;
  final int? amount;
  final int? streak;
}
