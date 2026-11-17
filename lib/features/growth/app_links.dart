import 'package:flutter/foundation.dart';

/// Public links used when sharing or inviting friends.
abstract final class AppLinks {
  static const playStore =
      'https://play.google.com/store/apps/details?id=com.pehlapaisa.app';

  /// The app's website (privacy policy, app-ads.txt). Used on iPhone until
  /// the App Store listing exists.
  static const website = 'https://mallanagowda63.github.io';

  static bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  /// Where a friend can get the app.
  static String get download => _ios ? website : playStore;

  /// Whether [download] points at Google Play.
  static bool get isPlayStore => !_ios;
}
