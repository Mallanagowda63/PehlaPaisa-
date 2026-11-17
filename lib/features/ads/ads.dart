import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

export 'ad_ids.dart' show AdSlot;

/// Starts Google Mobile Ads once, after asking for consent where the law
/// requires it (EEA / UK — Google's consent form, set up in AdMob under
/// Privacy & messaging). Budgeting never waits for this: if there is no
/// internet or consent is refused, ad slots simply stay empty.
class Ads {
  Ads._();
  static final instance = Ads._();

  /// True once ads may be requested.
  final ready = ValueNotifier<bool>(false);
  bool _started = false;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> start() async {
    if (_started || !_supported) return;
    _started = true;
    try {
      final consent = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          } finally {
            if (!consent.isCompleted) consent.complete();
          }
        },
        (_) {
          if (!consent.isCompleted) consent.complete();
        },
      );
      await consent.future;
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: AdIds.testDevices),
      );
      await MobileAds.instance.initialize();
      ready.value = true;
    } catch (e) {
      debugPrint('Ads could not start: $e');
    }
  }
}

/// Builds the widget for an ad slot. Tests replace it with a placeholder.
typedef AdSlotBuilder = Widget Function(BuildContext context, AdSlot slot);

final adSlotBuilderProvider = Provider<AdSlotBuilder>(
  (ref) =>
      (context, slot) => AdSlotView(slot: slot),
);

/// An ad in the screen: watches [adSlotBuilderProvider].
class AdSpot extends ConsumerWidget {
  const AdSpot(this.slot, {super.key});

  final AdSlot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(adSlotBuilderProvider)(context, slot);
}

/// A real AdMob banner or native ad. Takes no space until an ad has
/// loaded, and none at all if it fails (e.g. offline).
class AdSlotView extends StatefulWidget {
  const AdSlotView({super.key, required this.slot});

  final AdSlot slot;

  @override
  State<AdSlotView> createState() => _AdSlotViewState();
}

class _AdSlotViewState extends State<AdSlotView> {
  AdWithView? _ad;
  bool _loaded = false;
  double _bannerHeight = 0;
  double? _requestedWidth;
  bool _smallNative = false;

  @override
  void initState() {
    super.initState();
    Ads.instance.ready.addListener(_onReady);
  }

  @override
  void dispose() {
    Ads.instance.ready.removeListener(_onReady);
    _ad?.dispose();
    super.dispose();
  }

  void _onReady() {
    if (mounted) setState(() {});
  }

  void _load(double width) {
    if (_requestedWidth != null || !Ads.instance.ready.value) return;
    _requestedWidth = width;
    // Let the build finish before talking to the platform.
    scheduleMicrotask(() async {
      if (!mounted) return;
      if (widget.slot.native) {
        _loadNative(width);
      } else {
        await _loadBanner(width);
      }
    });
  }

  Future<void> _loadBanner(double width) async {
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      width.truncate(),
    );
    if (!mounted || size == null) return;
    final ad = BannerAd(
      adUnitId: AdIds.unitFor(widget.slot),
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _loaded = true;
              _bannerHeight = size.height.toDouble();
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ${widget.slot.name} failed: $error');
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  void _loadNative(double width) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    _smallNative = width < 320;
    NativeTemplateTextStyle text(Color color, {double? size}) =>
        NativeTemplateTextStyle(
          textColor: color,
          backgroundColor: Colors.transparent,
          size: size,
        );
    final ad = NativeAd(
      adUnitId: AdIds.unitFor(widget.slot),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: _smallNative ? TemplateType.small : TemplateType.medium,
        mainBackgroundColor: theme.cardTheme.color ?? cs.surfaceContainer,
        cornerRadius: 12,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: cs.onPrimary,
          backgroundColor: cs.primary,
          style: NativeTemplateFontStyle.bold,
          size: 15,
        ),
        primaryTextStyle: text(cs.onSurface, size: 16),
        secondaryTextStyle: text(cs.onSurfaceVariant, size: 14),
        tertiaryTextStyle: text(cs.onSurfaceVariant, size: 13),
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native ${widget.slot.name} failed: $error');
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        _load(c.maxWidth);
        final ad = _ad;
        if (!_loaded || ad == null) return const SizedBox.shrink();
        if (!widget.slot.native) {
          return Center(
            child: SizedBox(
              key: Key('ad_${widget.slot.name}'),
              width: (ad as BannerAd).size.width.toDouble(),
              height: _bannerHeight,
              child: AdWidget(ad: ad),
            ),
          );
        }
        return Center(
          child: ConstrainedBox(
            key: Key('ad_${widget.slot.name}'),
            constraints: _smallNative
                ? const BoxConstraints(
                    minWidth: 280,
                    maxWidth: 400,
                    minHeight: 90,
                    maxHeight: 120,
                  )
                : const BoxConstraints(
                    minWidth: 320,
                    maxWidth: 400,
                    minHeight: 320,
                    maxHeight: 360,
                  ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AdWidget(ad: ad),
            ),
          ),
        );
      },
    );
  }
}
