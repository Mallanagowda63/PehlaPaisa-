import 'package:flutter/foundation.dart';

/// Where an ad is shown in PehlaPaisa.
enum AdSlot {
  shelfBanner(native: false),
  shareBanner(native: false),
  reportNative(native: true),
  goalsNative(native: true);

  const AdSlot({required this.native});

  /// Native ad (card) vs banner (strip).
  final bool native;
}

/// AdMob ad unit IDs.
///
/// **To go live:** paste the IDs from AdMob (Apps → PehlaPaisa → Ad units)
/// into [_androidLive] / [_iosLive], and the App IDs into
/// `android/app/src/main/AndroidManifest.xml`
/// (`com.google.android.gms.ads.APPLICATION_ID`) and `ios/Runner/Info.plist`
/// (`GADApplicationIdentifier`).
///
/// Until then — and always in debug builds — Google's official **test** IDs
/// are used, so tapping an ad can never break AdMob's rules.
abstract final class AdIds {
  static const Map<AdSlot, String> _androidLive = {
    AdSlot.shelfBanner: 'ca-app-pub-1571944076824107/2007248943',
    AdSlot.shareBanner: 'ca-app-pub-1571944076824107/9694167274',
    AdSlot.reportNative: 'ca-app-pub-1571944076824107/6010732271',
    AdSlot.goalsNative: 'ca-app-pub-1571944076824107/5675031217',
  };

  static const Map<AdSlot, String> _iosLive = {
    AdSlot.shelfBanner: '',
    AdSlot.shareBanner: '',
    AdSlot.reportNative: '',
    AdSlot.goalsNative: '',
  };

  /// The developer's own phones: they always get test ads, even in the
  /// live app, so you can never click your own real ads by accident.
  /// Add a phone: run the app, look in logcat for
  /// `setTestDeviceIds(Arrays.asList("…"))` and paste that code here.
  static const testDevices = [
    '633BF4E5063F2E8FC022E11FDE5E0F00', // Realme RMX3943 (MD5 of Android ID)
    '8FC2AB355004732CA32FD87CB5E409AF', // Realme RMX3943 (UMP log)
  ];

  // Google's public test units:
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  static const _androidTestBanner = 'ca-app-pub-3940256099942544/9214589741';
  static const _androidTestNative = 'ca-app-pub-3940256099942544/2247696110';
  static const _iosTestBanner = 'ca-app-pub-3940256099942544/2435281174';
  static const _iosTestNative = 'ca-app-pub-3940256099942544/3986624511';

  static bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  /// Build with `--dart-define=PP_TEST_ADS=true` to see Google's test ads
  /// in a release build (e.g. on the developer's phone while the AdMob
  /// account is still waiting for approval). Store builds leave it off.
  static const _forceTestAds = bool.fromEnvironment('PP_TEST_ADS');

  /// True when this build shows Google's test ads.
  static bool isTest(AdSlot slot) {
    final live = (_ios ? _iosLive : _androidLive)[slot] ?? '';
    return kDebugMode || _forceTestAds || live.isEmpty;
  }

  /// The ad unit to request for [slot] on this platform.
  static String unitFor(AdSlot slot) {
    if (!isTest(slot)) return (_ios ? _iosLive : _androidLive)[slot]!;
    if (_ios) return slot.native ? _iosTestNative : _iosTestBanner;
    return slot.native ? _androidTestNative : _androidTestBanner;
  }
}
