// Renders every main screen with real fonts and saves PNGs.
//
// Skipped unless PP_SCREENSHOTS is set to an output folder:
//   PP_SCREENSHOTS=build/screenshots flutter test test/screenshots
//
// Uses the debug demo data (₹10,000 income, 6 months) so charts and badges
// are populated. Emoji render as boxes here (no emoji font in tests).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OffsetLayer;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/app/state/repositories.dart';
import 'package:pehla_paisa/features/settings/data/app_settings.dart';

import '../helpers/demo_repos.dart';

import '../widget/harness.dart';

final String? outDir = Platform.environment['PP_SCREENSHOTS'];

Future<void> _loadFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final f in files) {
      loader.addFont(rootBundle.load(f));
    }
    await loader.load();
  }

  const weights = [400, 500, 600, 700];
  await family('Poppins', [
    for (final w in weights) 'assets/fonts/Poppins-$w.ttf',
  ]);
  await family('Inter', [for (final w in weights) 'assets/fonts/Inter-$w.ttf']);
  await family('NotoSansDevanagari', [
    for (final w in weights) 'assets/fonts/NotoSansDevanagari-$w.ttf',
  ]);
  // Material icons from the Flutter SDK cache.
  final sdk =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final icons = File(
    '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(
          ByteData.view(Uint8List.fromList(icons.readAsBytesSync()).buffer),
        ),
      );
    await loader.load();
  }
}

Future<void> _snap(WidgetTester tester, String name) async {
  // Draw real elevation shadows (flutter_test disables them by default),
  // then restore the flag before the test ends.
  debugDisableShadows = false;
  tester.binding.renderViews.first.markNeedsPaint();
  await tester.pump();
  final view = tester.binding.renderViews.first;
  final layer = view.debugLayer! as OffsetLayer;
  final size = tester.view.physicalSize;
  await tester.runAsync(() async {
    final ui.Image img = await layer.toImage(Offset.zero & size);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$outDir/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
  debugDisableShadows = true;
  await tester.pump();
}

void main() {
  final skip = outDir == null ? 'Set PP_SCREENSHOTS to capture' : null;

  setUpAll(() async {
    if (outDir != null) await _loadFonts();
  });

  const screens = {
    'home': '/home',
    'goals': '/goals',
    'report': '/report',
    'badges': '/badges',
    'settings': '/settings',
    'jar_food': '/jar/jar_food',
  };

  for (final theme in [AppThemeMode.dark, AppThemeMode.light]) {
    for (final e in screens.entries) {
      testWidgets('${e.key} ${theme.name}', skip: skip != null, (tester) async {
        final repos = await demoRepos(theme: theme);
        await pumpApp(tester, repos: repos, location: e.value);
        await _snap(tester, '${e.key}_${theme.name}');
      });
    }
  }

  testWidgets('home hindi', skip: skip != null, (tester) async {
    final repos = await demoRepos(language: 'hi');
    await pumpApp(tester, repos: repos, location: '/home');
    await _snap(tester, 'home_hindi');
  });

  testWidgets('home large screen', skip: skip != null, (tester) async {
    final repos = await demoRepos();
    await pumpApp(
      tester,
      repos: repos,
      location: '/home',
      size: const Size(800, 1280),
    );
    await _snap(tester, 'home_large');
  });

  testWidgets('onboarding intro + split', skip: skip != null, (tester) async {
    await pumpApp(
      tester,
      repos: Repositories.inMemory(),
      location: '/onboarding',
    );
    await _snap(tester, 'onboarding_intro');
    await tester.tap(find.byKey(const Key('onb_next')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('onb_name')), 'Asha');
    await tester.tap(find.byKey(const Key('onb_next')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('onb_income')), '12000');
    await tester.pumpAndSettle();
    await _snap(tester, 'onboarding_income');
    await tester.tap(find.byKey(const Key('onb_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onb_family_yes')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('onb_next')));
    await tester.pumpAndSettle();
    await _snap(tester, 'onboarding_split');
    await tester.tap(find.byKey(const Key('onb_finish')));
    await tester.pumpAndSettle();
    await _snap(tester, 'salary_day');
  });

  testWidgets('add expense sheet + share', skip: skip != null, (tester) async {
    final repos = await demoRepos();
    await pumpApp(tester, repos: repos, location: '/home');
    await tester.tap(find.byKey(const Key('home_add_expense')));
    await tester.pumpAndSettle();
    for (final d in ['4', '5', '0']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await _snap(tester, 'add_expense');
  });

  testWidgets('share screen', skip: skip != null, (tester) async {
    final repos = await demoRepos();
    await pumpApp(tester, repos: repos, location: '/share');
    await _snap(tester, 'share');
  });
}
