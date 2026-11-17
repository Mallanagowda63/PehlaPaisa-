import '../../../core/storage/repository.dart';
import 'goal.dart';

class GoalRepository extends CollectionRepository<Goal> {
  GoalRepository(super.store);

  /// Oldest first, so the list order is stable.
  @override
  List<Goal> getAll() =>
      super.getAll()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  Goal fromMap(Map<String, dynamic> map) => Goal.fromMap(map);

  @override
  String idOf(Goal item) => item.id;

  @override
  Map<String, dynamic> toMap(Goal item) => item.toMap();
}
