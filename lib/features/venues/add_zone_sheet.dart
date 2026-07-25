import 'package:flutter/material.dart';

import '../../shared/widgets/prism_bottom_sheet.dart';
import '../../shared/widgets/prism_field.dart';
import '../../shared/widgets/prism_top_bar.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// S04-4 "Add a zone — name it, pick its player & hours". BottomSheet with
/// the **zone name field only** ("Back patio", accent border) + helper
/// "A zone is one area with its own speakers. Prism drives each zone on its
/// own." Cancel / "Add zone" (flex 1:2). Resolves with the zone name.
Future<String?> showAddZoneSheet(BuildContext context) {
  return showPrismSheet<String>(
    context,
    topBarHeight: PrismTopBar.height,
    sheet: const _AddZoneSheet(),
  );
}

class _AddZoneSheet extends StatefulWidget {
  const _AddZoneSheet();

  @override
  State<_AddZoneSheet> createState() => _AddZoneSheetState();
}

class _AddZoneSheetState extends State<_AddZoneSheet> {
  // Frame shows the field filled "Back patio" with accent border.
  final _name = TextEditingController(text: 'Back patio');

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return PrismBottomSheet(
      title: 'Add a zone',
      primaryLabel: 'Add zone',
      onPrimary: () => Navigator.of(context).pop(_name.text),
      onCancel: () => Navigator.of(context).pop(),
      children: [
        const SizedBox(height: 16),
        PrismField(
            label: 'Zone name', controller: _name, focusedOverride: true),
        const SizedBox(height: 9),
        Text(
          'A zone is one area with its own speakers. Prism drives each zone '
          'on its own.',
          style:
              PrismType.microHelper.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }
}
