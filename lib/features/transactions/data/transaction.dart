/// What kind of money movement a [Transaction] records.
enum TransactionType { expense, income, transfer }

/// A single money movement.
///
/// * expense  – money spent from [jarId].
/// * income   – money received (irregular income entry / salary). [jarId] is
///              empty because income is split across all glasses.
/// * transfer – money moved from [jarId] to [toJarId] (borrowing between
///              glasses) or to [goalId] (saving towards a goal).
class Transaction {
  const Transaction({
    required this.id,
    required this.jarId,
    required this.amount,
    required this.note,
    required this.dateTime,
    required this.type,
    required this.cycleId,
    this.toJarId,
    this.goalId,
  });

  final String id;
  final String jarId;

  /// Always positive, in whole rupees.
  final int amount;
  final String note;
  final DateTime dateTime;
  final TransactionType type;

  /// The month cycle this belongs to (e.g. `2026-03`).
  final String cycleId;
  final String? toJarId;
  final String? goalId;

  bool get isExpense => type == TransactionType.expense;

  Transaction copyWith({int? amount, String? note, DateTime? dateTime}) {
    return Transaction(
      id: id,
      jarId: jarId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
      type: type,
      cycleId: cycleId,
      toJarId: toJarId,
      goalId: goalId,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'jarId': jarId,
    'amount': amount,
    'note': note,
    'dateTime': dateTime.millisecondsSinceEpoch,
    'type': type.name,
    'cycleId': cycleId,
    'toJarId': toJarId,
    'goalId': goalId,
  };

  factory Transaction.fromMap(Map<String, dynamic> m) => Transaction(
    id: m['id'] as String,
    jarId: m['jarId'] as String? ?? '',
    amount: (m['amount'] as num?)?.toInt() ?? 0,
    note: m['note'] as String? ?? '',
    dateTime: DateTime.fromMillisecondsSinceEpoch(
      (m['dateTime'] as num?)?.toInt() ?? 0,
    ),
    type: TransactionType.values.firstWhere(
      (e) => e.name == m['type'],
      orElse: () => TransactionType.expense,
    ),
    cycleId: m['cycleId'] as String? ?? '',
    toJarId: m['toJarId'] as String?,
    goalId: m['goalId'] as String?,
  );
}
