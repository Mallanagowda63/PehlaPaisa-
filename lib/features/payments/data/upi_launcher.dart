import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// A UPI app installed on the phone that can receive a payment.
class UpiApp {
  const UpiApp(this.name, this.package, this.color, {this.iosScheme});

  final String name;

  /// Android package name.
  final String package;

  /// Colour for the app's initial in the "Pay with" list (no logos used).
  final Color color;

  /// iOS URL scheme (iOS apps can't be opened by package name). Null when
  /// the app has no known iOS scheme; it is then not listed on iPhone.
  final String? iosScheme;

  /// Opens the app itself on iOS (its home screen).
  Uri? get iosHomeUri => iosScheme == null ? null : Uri.parse('$iosScheme://');

  /// UPI apps PehlaPaisa can list (Android: AndroidManifest `<queries>`;
  /// iOS: `LSApplicationQueriesSchemes` in Info.plist).
  static const known = [
    UpiApp(
      'Google Pay',
      'com.google.android.apps.nbu.paisa.user',
      Color(0xFF4285F4),
      iosScheme: 'gpay',
    ),
    UpiApp(
      'PhonePe',
      'com.phonepe.app',
      Color(0xFF6739B7),
      iosScheme: 'phonepe',
    ),
    UpiApp('Paytm', 'net.one97.paytm', Color(0xFF00BAF2), iosScheme: 'paytmmp'),
    UpiApp('BHIM', 'in.org.npci.upiapp', Color(0xFFF58220)),
    UpiApp(
      'BHIM (Canara)',
      'com.canarabhim.upiapp.mobility',
      Color(0xFF00A3E0),
    ),
    UpiApp('Amazon Pay', 'in.amazon.mShop.android.shopping', Color(0xFFFF9900)),
    UpiApp('WhatsApp', 'com.whatsapp', Color(0xFF25D366)),
    UpiApp('CRED', 'com.dreamplug.androidapp', Color(0xFF8E8E93)),
    UpiApp('super.money', 'money.super.payments', Color(0xFF5B3CF5)),
    UpiApp('MyJio', 'com.jio.myjio', Color(0xFF0F3CC9)),
    UpiApp('Groww', 'com.nextbillion.groww', Color(0xFF00D09C)),
    UpiApp('Navi', 'com.naviapp', Color(0xFF1D7A5F)),
    UpiApp('MobiKwik', 'com.mobikwik_new', Color(0xFF2E6CE6)),
  ];
}

/// Talks to the phone's UPI apps. PehlaPaisa never moves money itself.
abstract class UpiLauncher {
  /// UPI apps installed on this phone that can open a payment.
  Future<List<UpiApp>> installedApps();

  /// Opens [app] on its home screen (like tapping its icon). The user scans
  /// the QR and pays there, so the UPI app treats it as a normal payment.
  Future<bool> openHome(UpiApp app);
}

/// Android: finds apps that handle `upi://` and opens them by package.
/// iOS: each app's own URL scheme.
class UrlUpiLauncher implements UpiLauncher {
  /// Native helper in MainActivity (Android `getLaunchIntentForPackage`).
  static const _apps = MethodChannel('pehlapaisa/apps');

  bool get _android => defaultTargetPlatform == TargetPlatform.android;
  bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  /// A `upi://pay` intent aimed at one app. Asking "can this app handle a
  /// UPI payment?" is what Android's chooser does, so detection is reliable.
  AndroidIntent _payIntent(UpiApp app, String data) => AndroidIntent(
    action: 'android.intent.action.VIEW',
    data: data,
    package: app.package,
  );

  @override
  Future<List<UpiApp>> installedApps() async {
    final found = <UpiApp>[];
    for (final app in UpiApp.known) {
      try {
        if (_android) {
          final ok =
              await _payIntent(
                app,
                'upi://pay?pa=test@upi&pn=Test',
              ).canResolveActivity() ??
              false;
          if (ok) found.add(app);
        } else if (_ios && app.iosHomeUri != null) {
          if (await canLaunchUrl(app.iosHomeUri!)) found.add(app);
        }
      } catch (e) {
        debugPrint('UPI app check failed for ${app.name}: $e');
      }
    }
    return found;
  }

  @override
  Future<bool> openHome(UpiApp app) async {
    try {
      if (_android) {
        return await _apps.invokeMethod<bool>('launch', {
              'package': app.package,
            }) ??
            false;
      }
      if (_ios && app.iosHomeUri != null) {
        return await launchUrl(
          app.iosHomeUri!,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      }
      return false;
    } catch (e) {
      debugPrint('Could not open ${app.name} home: $e');
      return false;
    }
  }
}

final upiLauncherProvider = Provider<UpiLauncher>((ref) => UrlUpiLauncher());
