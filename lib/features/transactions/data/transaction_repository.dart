import '../../../core/storage/repository.dart';
import 'transaction.dart';

class TransactionRepository extends CollectionRepository<Transaction> {
  TransactionRepository(super.store);

  /// Newest first.
  @override
  List<Transaction> getAll() =>
      super.getAll()..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  List<Transaction> forCycle(String cycleId) =>
      getAll().where((t) => t.cycleId == cycleId).toList();

  List<Transaction> forJar(String jarId, {String? cycleId}) => getAll()
      .where(
        (t) =>
            (t.jarId == jarId || t.toJarId == jarId) &&
            (cycleId == null || t.cycleId == cycleId),
      )
      .toList();

  @override
  Transaction fromMap(Map<String, dynamic> map) => Transaction.fromMap(map);

  @override
  String idOf(Transaction item) => item.id;

  @override
  Map<String, dynamic> toMap(Transaction item) => item.toMap();
}
