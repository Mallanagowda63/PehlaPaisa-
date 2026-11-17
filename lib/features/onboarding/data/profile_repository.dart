import '../../../core/storage/repository.dart';
import 'user_profile.dart';

class ProfileRepository extends SingletonRepository<UserProfile> {
  ProfileRepository(super.store);

  @override
  UserProfile fromMap(Map<String, dynamic> map) => UserProfile.fromMap(map);

  @override
  Map<String, dynamic> toMap(UserProfile item) => item.toMap();
}
