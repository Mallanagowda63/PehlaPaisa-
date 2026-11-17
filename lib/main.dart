import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/state/repositories.dart';
import 'features/ads/ads.dart';
import 'features/alerts/data/notification_gateway.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Everything lives on the device: Hive boxes in the app documents folder.
  await Hive.initFlutter();
  final repos = await Repositories.openHive();

  // Notifications are initialised after the first frame so they never
  // delay opening the app.
  final notifications = LocalNotificationGateway();

  runApp(
    ProviderScope(
      overrides: [
        repositoriesProvider.overrideWithValue(repos),
        notificationGatewayProvider.overrideWithValue(notifications),
      ],
      child: const PehlaPaisaApp(),
    ),
  );
  unawaited(notifications.init());
  // Ads start after the first frame too, and never block budgeting.
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(Ads.instance.start()),
  );
}
