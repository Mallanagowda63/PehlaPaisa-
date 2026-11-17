import 'package:flutter/material.dart';

/// A placeholder the size of a real ad, so layout tests (nav bar, small
/// screens, Hindi) still see an ad in each slot without the AdMob SDK.
///
/// [SampleAd.native] is a card (Report, Goals); [SampleAd.banner] is the
/// standard 320×50 strip (Share).
class SampleAd extends StatelessWidget {
  const SampleAd.native({super.key}) : _banner = false;
  const SampleAd.banner({super.key}) : _banner = true;

  final bool _banner;

  @override
  Widget build(BuildContext context) {
    return _banner ? _bannerAd(context) : _nativeAd(context);
  }

  Widget _adLabel(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFFFC857),
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      'Ad',
      style: TextStyle(
        color: Colors.black,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _icon(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4F8EF7), Color(0xFF8E5CF7)],
      ),
      borderRadius: BorderRadius.circular(size / 4),
    ),
    alignment: Alignment.center,
    child: Icon(Icons.apps, color: Colors.white, size: size * 0.55),
  );

  Widget _nativeAd(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      key: const Key('sample_ad_native'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _adLabel(context),
                const SizedBox(width: 8),
                Text('Sponsored', style: t.bodySmall?.copyWith(color: muted)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4F8EF7).withValues(alpha: 0.35),
                    const Color(0xFF8E5CF7).withValues(alpha: 0.35),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                'Ad image',
                style: t.titleMedium?.copyWith(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _icon(40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advertiser name',
                        style: t.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Short ad text goes here ★★★★☆',
                        style: t.bodySmall?.copyWith(color: muted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('Install'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerAd(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Container(
        key: const Key('sample_ad_banner'),
        constraints: const BoxConstraints(maxWidth: 468),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: muted.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            _adLabel(context),
            const SizedBox(width: 8),
            _icon(34),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advertiser name',
                    style: t.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Banner ad · 320×50',
                    style: t.bodySmall?.copyWith(color: muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Open')),
          ],
        ),
      ),
    );
  }
}
