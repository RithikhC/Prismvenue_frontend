import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models/user.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'prism_avatar.dart';

/// Avatar tap menu — §2.0: w216, r16, bg `surface`, border `borderStrong`,
/// shadow §1.7. Header row: 38 avatar + name 14/700 + role 11
/// `textSecondary`, padding 14, bottom border. "Sign out" row: 13.5/700
/// `red` with log-out icon, padding 10×11, r10.
class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key, required this.user, this.onSignOut});

  final User user;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PrismPalette>()!;
    return Container(
      width: 216,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.borderStrong),
        borderRadius: BorderRadius.circular(16),
        boxShadow: PrismPalette.accountMenuShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: palette.border)),
            ),
            child: Row(
              children: [
                PrismAvatar(
                    initials: user.initials, color: user.avatarColor, size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: PrismType.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: palette.textPrimary)),
                      Text(user.roleLabel,
                          style: PrismType.label.copyWith(
                              fontWeight: FontWeight.w400,
                              color: palette.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              onTap: onSignOut,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.logOut, size: 15, color: palette.red),
                    const SizedBox(width: 9),
                    Text('Sign out',
                        style: PrismType.bodySm.copyWith(
                            fontWeight: FontWeight.w700, color: palette.red)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
