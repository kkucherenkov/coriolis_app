import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'package:coriolis_companion/i18n/strings.g.dart';

/// A member entry shown in the picker.
class WhisperPickerMember {
  const WhisperPickerMember({
    required this.membershipId,
    required this.displayName,
    this.characterName,
  });

  final String membershipId;
  final String displayName;
  final String? characterName;
}

/// Bottom sheet for selecting a whisper recipient.
///
/// Blocked members are filtered out client-side before reaching this widget.
/// Tap a member row calls [onPick].
class WhisperPickerSheet extends StatelessWidget {
  const WhisperPickerSheet({
    super.key,
    required this.members,
    required this.onPick,
  });

  /// Pre-filtered list — blocked members must be excluded by the caller.
  final List<WhisperPickerMember> members;
  final ValueChanged<WhisperPickerMember> onPick;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s4,
              AppSpacing.s4,
              AppSpacing.s4,
              AppSpacing.s2,
            ),
            child: Text(
              t.chat.whisper_picker.title,
              style: AppTypography.displaySm.copyWith(
                color: AppColors.brandBrassLight,
              ),
            ),
          ),
          if (members.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s4),
              child: Text(
                t.chat.whisper_picker.empty,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            ListView.builder(
              key: const Key('whisper_picker_list'),
              shrinkWrap: true,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  key: Key('member_${member.membershipId}'),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.brandBrassDeep,
                    child: Text(
                      member.displayName[0].toUpperCase(),
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textOnBrass,
                      ),
                    ),
                  ),
                  title: Text(
                    member.displayName,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: member.characterName != null
                      ? Text(
                          member.characterName!,
                          style: AppTypography.bodyXs.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onPick(member);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Helper to show the picker as a modal bottom sheet.
Future<void> showWhisperPickerSheet({
  required BuildContext context,
  required List<WhisperPickerMember> members,
  required ValueChanged<WhisperPickerMember> onPick,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => WhisperPickerSheet(members: members, onPick: onPick),
    );
