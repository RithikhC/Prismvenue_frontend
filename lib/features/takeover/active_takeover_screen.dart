import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/session.dart';
import '../../app/venue_header.dart';
import '../../data/repositories/playback_repo.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/prism_top_bar.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../theme/moods.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'confirm_return_dialog.dart';
import 'extend_sheet.dart';

/// S02-2 "Active takeover — Prism is holding the room; return now or extend".
/// Amber banner (bg amber@12%, border amber@34%, r13, h56) "Your audio is
/// playing · started 2:12 pm"; centered countdown 64/800 amber; bottom row
/// Extend (secondary) → S02-4 / "Return to Prism now" (primary) → S02-3.
class ActiveTakeoverScreen extends ConsumerWidget {
  const ActiveTakeoverScreen({super.key});

  /// "started 2:12 pm" — h:mm lowercase am/pm.
  static String _startedLabel(DateTime t) {
    final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h12:$m ${t.hour < 12 ? 'am' : 'pm'}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final header = ref.watch(venueHeaderProvider);
    final takeover = ref.watch(takeoverStateProvider).value;
    if (user == null || takeover == null || !takeover.active) {
      return const SizedBox.shrink(); // TakeoverScreen switches back
    }
    final palette = Theme.of(context).extension<PrismPalette>()!;

    return Scaffold(
      body: Column(
        children: [
          PrismTopBar(
            title: header.title,
            subtitle: header.subtitle,
            statusDot: header.statusDot,
            user: user,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 56,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: palette.amber.withValues(alpha: .12),
                      border: Border.all(
                          color: palette.amber.withValues(alpha: .34)),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      'Your audio is playing · started '
                      '${_startedLabel(takeover.startedAt!)}',
                      style: PrismType.bodySm.copyWith(color: palette.amber),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        takeover.countdownLabel,
                        style: PrismType.numeralHuge
                            .copyWith(color: palette.amber),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Extend',
                          onTap: () => showExtendSheet(context, ref),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Return to Prism now',
                          onTap: () => _confirmReturn(context, ref),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReturn(BuildContext context, WidgetRef ref) async {
    final moodId =
        ref.read(nowPlayingProvider).value?.moodId ?? 'afternoon-lift';
    final confirmed =
        await showConfirmReturnDialog(context, currentMood: moodById(moodId));
    if (confirmed == true) {
      await ref.read(playbackRepoProvider).endTakeover();
      if (context.mounted) context.go('/floor'); // §4: confirm-return → floor
    }
  }
}
