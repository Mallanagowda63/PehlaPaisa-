// Checks, on the real phone, that PehlaPaisa finds the installed UPI apps
// and can open one on its home screen. No payment is started.
//
//   flutter test integration_test/upi_apps_test.dart -d <device-id>
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pehla_paisa/features/payments/data/upi_launcher.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('finds UPI apps and opens one on its home screen',
      (tester) async {
    final launcher = UrlUpiLauncher();
    final apps = await launcher.installedApps();
    debugPrint('UPI apps found: ${apps.map((a) => a.name).join(', ')}');
    expect(apps, isNotEmpty);

    final phonePe = apps.firstWhere(
      (a) => a.name == 'PhonePe',
      orElse: () => apps.first,
    );
    final opened = await launcher.openHome(phonePe);
    debugPrint('Opened ${phonePe.name} home screen: $opened');
    expect(opened, isTrue);
    await Future<void>.delayed(const Duration(seconds: 4));
  });
}
