import '../../../core/storage/repository.dart';
import 'jar.dart';

class JarRepository extends CollectionRepository<Jar> {
  JarRepository(super.store);

  /// Jars in shelf order (Savings first).
  @override
  List<Jar> getAll() =>
      super.getAll()..sort((a, b) => a.order.compareTo(b.order));

  Jar? byType(JarType type) {
    for (final j in getAll()) {
      if (j.type == type) return j;
    }
    return null;
  }

  @override
  Jar fromMap(Map<String, dynamic> map) => Jar.fromMap(map);

  @override
  String idOf(Jar item) => item.id;

  @override
  Map<String, dynamic> toMap(Jar item) => item.toMap();
}
