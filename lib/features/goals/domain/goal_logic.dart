import '../../../core/constants.dart';
import '../../../core/dates.dart';
import '../../../core/money.dart';
import '../data/goal.dart';

/// Result of moving money into a goal.
class DepositResult {
  const DepositResult(this.goal, this.moved, this.justCompleted);

  final Goal goal;

  /// Amount actually moved (clamped by availability and the goal's need).
  final int moved;

  /// The goal reached 100% with this deposit.
  final bool justCompleted;
}

/// Goal rules (spec §4.6).
abstract final class GoalLogic {
  /// Suggested Emergency Fund: 3 × monthly expenses (income − savings).
  static int suggestedEmergencyFund({
    required int monthlyIncome,
    required int monthlySavings,
  }) {
    final expenses = (monthlyIncome - monthlySavings).clamp(0, monthlyIncome);
    return roundTo10(expenses * PPRules.emergencyFundMonths);
  }

  /// Months needed to save [remaining] at [monthlyRate].
  /// Returns 0 if already reached, null if the rate is zero.
  static int? monthsToReach({
    required int remaining,
    required int monthlyRate,
  }) {
    if (remaining <= 0) return 0;
    if (monthlyRate <= 0) return null;
    return (remaining / monthlyRate).ceil();
  }

  /// Monthly amount needed to reach the goal by [targetDate].
  static int? requiredMonthly({
    required int remaining,
    required DateTime targetDate,
    required DateTime now,
  }) {
    if (remaining <= 0) return 0;
    final days = daysBetween(now, targetDate);
    if (days <= 0) return null;
    final months = (days / 30.44).ceil().clamp(1, 1200);
    return (remaining / months).ceil();
  }

  /// Moves up to [amount] of free savings ([available]) into [goal].
  static DepositResult deposit({
    required Goal goal,
    required int amount,
    required int available,
    required DateTime now,
  }) {
    final need = goal.remaining;
    var moved = amount;
    if (moved > available) moved = available;
    if (moved > need) moved = need;
    if (moved <= 0) return DepositResult(goal, 0, false);
    final saved = goal.savedAmount + moved;
    final done = saved >= goal.targetAmount;
    final wasDone = goal.completedAt != null;
    return DepositResult(
      goal.copyWith(
        savedAmount: saved,
        completedAt: done && !wasDone ? now : null,
      ),
      moved,
      done && !wasDone,
    );
  }

  /// Takes money out of a goal back into free savings.
  static Goal withdraw(Goal goal, int amount) {
    final take = amount.clamp(0, goal.savedAmount);
    final saved = goal.savedAmount - take;
    return goal.copyWith(
      savedAmount: saved,
      clearCompletedAt: saved < goal.targetAmount,
    );
  }
}
