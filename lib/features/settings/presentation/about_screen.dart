import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/shelf_background.dart';
import '../../jars/presentation/widgets/glass_jar.dart';
import '../../../core/widgets/insets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;

    Widget section(String emoji, String title, String body) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$emoji  $title', style: t.titleSmall),
            const SizedBox(height: 6),
            Text(body),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
      body: ShelfBackground(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, safeBottom(context) + 32),
          children: [
            Center(
              child: ExcludeSemantics(
                child: GlassJar(
                  level: 0.8,
                  color: pp.savings,
                  width: 90,
                  height: 117,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.appName,
              style: t.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              l.tagline,
              style: t.titleMedium?.copyWith(color: pp.savings),
              textAlign: TextAlign.center,
            ),
            Text(
              l.aboutVersion(appVersion),
              style: t.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            section('🫙', l.appName, l.aboutBody),
            const SizedBox(height: 10),
            section('🔒', l.aboutPrivacyTitle, l.aboutPrivacy),
            const SizedBox(height: 10),
            section('ℹ️', l.aboutDisclaimerTitle, l.aboutDisclaimer),
            const SizedBox(height: 16),
            Text(
              l.aboutMadeWith,
              style: t.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
