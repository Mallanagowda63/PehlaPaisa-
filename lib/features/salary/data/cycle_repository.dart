import '../../../core/storage/repository.dart';
import 'month_cycle.dart';

class CycleRepository extends CollectionRepository<MonthCycle> {
  CycleRepository(super.store);

  /// Oldest first.
  @override
  List<MonthCycle> getAll() =>
      super.getAll()..sort((a, b) => a.startDate.compareTo(b.startDate));

  /// The open (current) cycle, if any.
  MonthCycle? active() {
    final open = getAll().where((c) => !c.closed).toList();
    return open.isEmpty ? null : open.last;
  }

  @override
  MonthCycle fromMap(Map<String, dynamic> map) => MonthCycle.fromMap(map);

  @override
  String idOf(MonthCycle item) => item.id;

  @override
  Map<String, dynamic> toMap(MonthCycle item) => item.toMap();
}
