// Renders the Google Play feature graphic (1024×500) with the app's real
// glass artwork and fonts.
//
// Skipped unless PP_STORE_ASSETS is set to an output folder:
//   PP_STORE_ASSETS=build/store flutter test test/screenshots/store_assets_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OffsetLayer;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/app/theme.dart';
import 'package:pehla_paisa/core/constants.dart';
import 'package:pehla_paisa/core/widgets/shelf_background.dart';
import 'package:pehla_paisa/features/jars/presentation/widgets/glass_jar.dart';

final String? outDir = Platform.environment['PP_STORE_ASSETS'];

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
}

class FeatureGraphic extends StatelessWidget {
  const FeatureGraphic({super.key});

  Widget _glass(double level, Color color, String label, {double scale = 1}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassJar(
          level: level,
          color: color,
          glow: color,
          width: 96 * scale,
          height: 128 * scale,
          fillFromEmpty: false,
          animateLevel: false,
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: PPColors.offWhite,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1024,
      height: 500,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF151726), Color(0xFF0E0F14), Color(0xFF1E1A16)],
        ),
      ),
      child: Stack(
        children: [
          // Warm lamp glow behind the shelf.
          Positioned(
            right: 40,
            top: 40,
            child: Container(
              width: 480,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    PPColors.savingsAmber.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 56, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PehlaPaisa',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 64,
                          height: 1.05,
                          color: PPColors.offWhite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pehle bachao, phir kharcho',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 26,
                          color: PPColors.savingsAmber,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Save first on salary day.\nThen spend from simple glasses.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          height: 1.4,
                          color: PPColors.offWhite.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 430,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _glass(0.62, PPColors.jarBlue, 'Food'),
                          _glass(
                            0.9,
                            PPColors.savingsAmber,
                            'Savings',
                            scale: 1.3,
                          ),
                          _glass(0.4, PPColors.funPink, 'Fun'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const ShelfPlank(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets(
    'Play feature graphic 1024×500',
    skip: outDir == null,
    (tester) async {
      await _loadFonts();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1024, 500);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.dark),
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(1024, 500),
              disableAnimations: true,
            ),
            child: Material(child: FeatureGraphic()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      debugDisableShadows = false;
      tester.binding.renderViews.first.markNeedsPaint();
      await tester.pump();
      final layer =
          tester.binding.renderViews.first.debugLayer! as OffsetLayer;
      await tester.runAsync(() async {
        final ui.Image img = await layer.toImage(
          Offset.zero & const Size(1024, 500),
        );
        final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
        File('$outDir/feature_graphic_1024x500.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      debugDisableShadows = true;
      await tester.pump();
    },
  );
}
