import '../../badges/data/badge.dart';

enum ShareCardKind { streak, saved, goal, badge }

enum ShareFormat { story, post }

/// What a share card shows. Amounts are only rendered when the user turns on
/// "show amounts".
class ShareCardData {
  const ShareCardData._(
    this.kind, {
    this.streak = 0,
    this.goalName,
    this.goalEmoji,
    this.amount,
    this.badge,
  });

  const ShareCardData.streak(int months)
    : this._(ShareCardKind.streak, streak: months);

  const ShareCardData.saved() : this._(ShareCardKind.saved);

  const ShareCardData.goal({
    required String name,
    required String emoji,
    required int amount,
  }) : this._(
         ShareCardKind.goal,
         goalName: name,
         goalEmoji: emoji,
         amount: amount,
       );

  const ShareCardData.badge(BadgeKey key)
    : this._(ShareCardKind.badge, badge: key);

  final ShareCardKind kind;
  final int streak;
  final String? goalName;
  final String? goalEmoji;
  final int? amount;
  final BadgeKey? badge;
}
