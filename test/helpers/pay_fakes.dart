import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:pehla_paisa/features/payments/data/upi_launcher.dart';

/// Stands in for the phone's UPI apps: records which apps were opened.
class FakeUpiApp implements UpiLauncher {
  FakeUpiApp({this.installed = true});

  final bool installed;

  /// Apps opened on their home screen, in order.
  final List<String> homes = [];

  @override
  Future<bool> openHome(UpiApp app) async {
    if (!installed) return false;
    homes.add(app.name);
    return true;
  }

  @override
  Future<List<UpiApp>> installedApps() async => installed
      ? UpiApp.known
            .where((a) => a.name == 'Google Pay' || a.name == 'PhonePe')
            .toList()
      : const [];
}

List<Override> fakes(FakeUpiApp upi) => [
  upiLauncherProvider.overrideWithValue(upi),
];
