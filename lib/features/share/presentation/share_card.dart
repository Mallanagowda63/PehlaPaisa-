import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/constants.dart';
import '../../badges/data/badge.dart';
import '../../jars/presentation/widgets/glass_jar.dart';
import '../domain/share_card_data.dart';

/// Logical size of each card; captured at 3× → 1080×1920 or 1080×1080.
Size shareCardSize(ShareFormat f) =>
    f == ShareFormat.story ? const Size(360, 640) : const Size(360, 360);

/// Pre-resolved texts so the card can be rendered off-screen without
/// needing localizations in its own tree.
class ShareCardTexts {
  const ShareCardTexts({
    required this.title,
    required this.subtitle,
    required this.appName,
    required this.tagline,
  });

  final String title;
  final String subtitle;
  final String appName;
  final String tagline;
}

/// A beautiful, self-contained progress card: glass visual, the stat, the
/// app name and tagline. Never shows amounts unless they're in [texts]
/// (the caller decides based on the "show amounts" toggle).
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.data,
    required this.format,
    required this.texts,
  });

  final ShareCardData data;
  final ShareFormat format;
  final ShareCardTexts texts;

  /// Wraps the card with everything needed to paint it off-screen.
  static Widget standalone({
    required ShareCardData data,
    required ShareFormat format,
    required ShareCardTexts texts,
  }) {
    return MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Theme(
        data: buildTheme(Brightness.dark),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ShareCard(data: data, format: format, texts: texts),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = shareCardSize(format);
    final story = format == ShareFormat.story;
    final heroColor = data.kind == ShareCardKind.goal
        ? PPColors.success
        : PPColors.savingsAmber;

    TextStyle style(double size, FontWeight w, Color c) => TextStyle(
      fontFamily: PPFonts.heading,
      fontFamilyFallback: PPFonts.fallback,
      fontSize: size,
      fontWeight: w,
      color: c,
      height: 1.25,
      decoration: TextDecoration.none,
    );

    Widget hero() {
      final glass = GlassJar(
        level: data.kind == ShareCardKind.goal ? 1 : 0.85,
        color: heroColor,
        width: story ? 120 : 76,
        height: story ? 156 : 99,
        fillFromEmpty: false,
        animateLevel: false,
      );
      final emoji = switch (data.kind) {
        ShareCardKind.streak => '🔥',
        ShareCardKind.saved => '🪙',
        ShareCardKind.goal => data.goalEmoji ?? '🎯',
        ShareCardKind.badge => null,
      };
      if (data.kind == ShareCardKind.badge) {
        return Container(
          width: story ? 140 : 90,
          height: story ? 140 : 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PPColors.savingsAmber.withValues(alpha: 0.2),
            boxShadow: [
              BoxShadow(
                color: PPColors.savingsAmber.withValues(alpha: 0.5),
                blurRadius: 40,
              ),
            ],
          ),
          child: Text(
            badgeEmoji[data.badge] ?? '🏅',
            style: TextStyle(fontSize: story ? 72 : 46),
          ),
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji!, style: TextStyle(fontSize: story ? 40 : 26)),
          SizedBox(height: story ? 8 : 4),
          glass,
          Container(
            width: story ? 170 : 110,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: const Color(0xFF6B4B33),
              boxShadow: const [
                BoxShadow(color: Color(0x88FFB347), blurRadius: 18),
              ],
            ),
          ),
        ],
      );
    }

    return MediaQuery.withNoTextScaling(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B1E33), PPColors.night],
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 0.9,
                colors: [
                  heroColor.withValues(alpha: 0.22),
                  heroColor.withValues(alpha: 0),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(story ? 28 : 20),
              child: Column(
                children: [
                  Text(
                    texts.appName,
                    style: style(
                      story ? 22 : 16,
                      FontWeight.w700,
                      PPColors.savingsAmber,
                    ),
                  ),
                  const Spacer(),
                  hero(),
                  SizedBox(height: story ? 28 : 12),
                  Text(
                    texts.title,
                    textAlign: TextAlign.center,
                    style: style(
                      story ? 26 : 19,
                      FontWeight.w700,
                      PPColors.offWhite,
                    ),
                  ),
                  SizedBox(height: story ? 10 : 4),
                  Text(
                    texts.subtitle,
                    textAlign: TextAlign.center,
                    style: style(
                      story ? 16 : 12,
                      FontWeight.w500,
                      PPColors.mutedText,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    texts.tagline,
                    style: style(
                      story ? 15 : 12,
                      FontWeight.w600,
                      PPColors.savingsAmber.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
