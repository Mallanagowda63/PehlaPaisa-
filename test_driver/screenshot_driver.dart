import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves screenshots taken by integration_test/store_screenshots_test.dart.
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final file = File('build/store/screenshots/$name.png')
      ..createSync(recursive: true);
    file.writeAsBytesSync(bytes);
    return true;
  },
);
