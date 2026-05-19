import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Maximum number of whisper tabs shown before collapsing into overflow chip.
const int kMaxVisibleWhispers = 3;

/// Horizontal tab strip for chat conversations.
///
/// - Broadcast is always pinned first.
/// - Whispers beyond [kMaxVisibleWhispers] collapse into a "+N more" chip that
///   shows a [PopupMenuButton] on tap.
/// - `+` button calls [onAddWhisper].
/// - Each whisper tab renders an [AppChatPresenceDot] to the right of the label
///   when the partner's membershipId is in [onlineMembershipIds] (online) or
///   when it is not (offline). Broadcast tabs never render a dot.
///   Always rendering the dot (varying state, not existence) matches the web
///   component's approach — consistent hit-box and no layout shift on join/leave.
class ChatTabStrip extends StatelessWidget {
  const ChatTabStrip({
    super.key,
    required this.conversations,
    required this.activeKey,
    required this.openWhisperKeys,
    required this.onSelect,
    required this.onAddWhisper,
    this.onOverflowSelect,
    this.onlineMembershipIds = const <String>{},
  });

  final List<ChatConversationData> conversations;
  final String activeKey;
  final Set<String> openWhisperKeys;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddWhisper;
  final ValueChanged<String>? onOverflowSelect;

  /// Online membershipIds forwarded from [ChatReady.onlineMembershipIds].
  final Set<String> onlineMembershipIds;

  @override
  Widget build(BuildContext context) {
    final broadcast = conversations
        .where((c) => c.summary.conversationKey == 'broadcast')
        .toList();
    final whispers = conversations
        .where((c) => c.summary.conversationKey != 'broadcast')
        .toList();

    final visibleWhispers = whispers.take(kMaxVisibleWhispers).toList();
    final overflowWhispers = whispers.skip(kMaxVisibleWhispers).toList();

    return Container(
      height: 40,
      color: AppColors.surfaceDawn,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              key: const Key('tab_strip_list'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
              children: [
                ...broadcast.map((c) => _TabChip(
                      key: Key('tab_${c.summary.conversationKey}'),
                      label: t.chat.tabs.broadcast,
                      isActive: activeKey == c.summary.conversationKey,
                      unreadCount: c.unreadCount,
                      onTap: () => onSelect(c.summary.conversationKey),
                    )),
                ...visibleWhispers.map((c) {
                  final partnerId = c.summary.partnerMembershipId;
                  final presence = partnerId != null &&
                          onlineMembershipIds.contains(partnerId)
                      ? AppChatPresence.online
                      : AppChatPresence.offline;
                  return _TabChip(
                    key: Key('tab_${c.summary.conversationKey}'),
                    label: c.summary.partnerDisplayName ??
                        c.summary.partnerMembershipId ??
                        '?',
                    isActive: activeKey == c.summary.conversationKey,
                    unreadCount: c.unreadCount,
                    presence: presence,
                    onTap: () => onSelect(c.summary.conversationKey),
                  );
                }),
                if (overflowWhispers.isNotEmpty)
                  _OverflowChip(
                    key: const Key('overflow_chip'),
                    count: overflowWhispers.length,
                    conversations: overflowWhispers,
                    onSelect: (key) {
                      onSelect(key);
                      onOverflowSelect?.call(key);
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s2),
            child: GestureDetector(
              key: const Key('add_whisper_button'),
              onTap: onAddWhisper,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceNight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.brandBrassDeep),
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.brandBrass,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.unreadCount,
    required this.onTap,
    this.presence,
  });

  final String label;
  final bool isActive;
  final int unreadCount;
  final VoidCallback onTap;

  /// When non-null, an [AppChatPresenceDot] is rendered to the right of the
  /// label with a 4 px gap. Whisper tabs supply this; broadcast tab leaves it
  /// null so no dot is shown.
  final AppChatPresence? presence;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s1,
          vertical: AppSpacing.s1,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brandBrassDeep : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: isActive
              ? null
              : Border.all(color: AppColors.brandBrassShadow, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: isActive
                    ? AppColors.textOnBrass
                    : AppColors.textSecondary,
              ),
            ),
            if (presence != null) ...[
              const SizedBox(width: 4),
              AppChatPresenceDot(presence: presence!),
            ],
            if (unreadCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.stateCrimsonBright,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$unreadCount',
                  style: AppTypography.bodyXs.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverflowChip extends StatelessWidget {
  const _OverflowChip({
    super.key,
    required this.count,
    required this.conversations,
    required this.onSelect,
  });

  final int count;
  final List<ChatConversationData> conversations;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: t.chat.tabs.overflow(count: count),
      onSelected: onSelect,
      itemBuilder: (_) => conversations
          .map((c) => PopupMenuItem<String>(
                key: Key('overflow_item_${c.summary.conversationKey}'),
                value: c.summary.conversationKey,
                child: Text(
                  c.summary.partnerDisplayName ??
                      c.summary.partnerMembershipId ??
                      '?',
                ),
              ))
          .toList(),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s1,
          vertical: AppSpacing.s1,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.brandBrassShadow, width: 0.5),
        ),
        child: Text(
          t.chat.tabs.overflow(count: count),
          style: AppTypography.labelSm.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
