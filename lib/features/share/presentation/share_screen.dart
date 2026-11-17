import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../growth/app_links.dart';
import '../../../app/l10n.dart';
import '../../ads/ads.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/state/budget_state.dart';
import '../../../core/money.dart';
import '../../../core/widgets/dialogs.dart';
import '../../badges/presentation/badge_texts.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/share_card_data.dart';
import 'share_card.dart';
import '../../../core/widgets/insets.dart';

/// Preview + share a progress card as an image (story or post).
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key, this.initial});

  final ShareCardData? initial;

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  late ShareCardData _data;
  ShareFormat _format = ShareFormat.story;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _data =
        widget.initial ??
        ShareCardData.streak(ref.read(budgetProvider).streak.current);
  }

  /// Card texts. Amounts only appear when [showAmounts] is on.
  ShareCardTexts _texts(AppLocalizations l, BudgetState s, bool showAmounts) {
    final income = s.profile?.monthlyIncome ?? 0;
    final savingsPercent = percentOf(s.monthlySavingsPlan, income);
    late String title;
    late String subtitle;
    switch (_data.kind) {
      case ShareCardKind.streak:
        title = l.shareStreakTitle(_data.streak == 0 ? 1 : _data.streak);
        subtitle = showAmounts
            ? l.homeTotalSaved(formatRupees(s.totalSaved))
            : l.shareSavedSub(savingsPercent);
      case ShareCardKind.saved:
        title = showAmounts
            ? l.shareSavedTitle(formatRupees(s.totalSaved))
            : l.shareSavedTitleHidden;
        subtitle = l.shareSavedSub(savingsPercent);
      case ShareCardKind.goal:
        title = l.shareGoalTitle('${_data.goalEmoji} ${_data.goalName}');
        subtitle = showAmounts
            ? l.shareGoalSub(formatRupees(_data.amount ?? 0))
            : l.shareGoalSubHidden;
      case ShareCardKind.badge:
        title = l.shareBadgeTitle(badgeName(l, _data.badge!));
        subtitle = badgeDescription(l, _data.badge!);
    }
    return ShareCardTexts(
      title: title,
      subtitle: subtitle,
      appName: l.appName,
      tagline: l.tagline,
      cta: AppLinks.isPlayStore ? l.shareCardOnPlay : l.shareCardFree,
    );
  }

  Future<void> _share(ShareCardTexts texts) async {
    final l = context.l10n;
    setState(() => _busy = true);
    try {
      final bytes = await ScreenshotController().captureFromWidget(
        ShareCard.standalone(data: _data, format: _format, texts: texts),
        pixelRatio: 3,
        targetSize: shareCardSize(_format),
        delay: const Duration(milliseconds: 200),
        context: context,
      );
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/pehlapaisa_${_data.kind.name}_${_format.name}.png',
      );
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: l.shareMessage(AppLinks.download),
        ),
      );
    } catch (_) {
      if (mounted) showSnack(context, l.shareFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = ref.watch(budgetProvider);
    final settings = ref.watch(settingsProvider);
    final texts = _texts(l, s, settings.showAmountsOnShare);
    final pickable =
        _data.kind == ShareCardKind.streak || _data.kind == ShareCardKind.saved;
    final size = shareCardSize(_format);

    return Scaffold(
      appBar: AppBar(title: Text(l.shareTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, safeBottom(context) + 32),
        children: [
          SegmentedButton<ShareFormat>(
            segments: [
              ButtonSegment(
                value: ShareFormat.story,
                label: Text(l.shareStory),
                icon: const Icon(Icons.stay_current_portrait),
              ),
              ButtonSegment(
                value: ShareFormat.post,
                label: Text(l.sharePost),
                icon: const Icon(Icons.crop_square),
              ),
            ],
            selected: {_format},
            onSelectionChanged: (v) => setState(() => _format = v.first),
          ),
          if (pickable) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l.shareCardStreak),
                  selected: _data.kind == ShareCardKind.streak,
                  onSelected: (_) => setState(
                    () => _data = ShareCardData.streak(s.streak.current),
                  ),
                ),
                ChoiceChip(
                  label: Text(l.shareCardSaved),
                  selected: _data.kind == ShareCardKind.saved,
                  onSelected: (_) =>
                      setState(() => _data = const ShareCardData.saved()),
                ),
              ],
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.shareShowAmounts),
            subtitle: Text(l.shareShowAmountsHint),
            value: settings.showAmountsOnShare,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .update((x) => x.copyWith(showAmountsOnShare: v)),
          ),
          const SizedBox(height: 8),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: _format == ShareFormat.story ? 460 : 320,
              ),
              child: AspectRatio(
                aspectRatio: size.width / size.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: FittedBox(
                    child: ShareCard(
                      data: _data,
                      format: _format,
                      texts: texts,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('share_button'),
            onPressed: _busy ? null : () => _share(texts),
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share),
            label: Text(l.shareButton),
          ),
          const SizedBox(height: 20),
          const AdSpot(AdSlot.shareBanner),
        ],
      ),
    );
  }
}
