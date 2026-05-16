import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:coriolis_companion/i18n/strings.g.dart';

/// Visual variant of a chat message bubble, mirroring the web `AppChatMessage`
/// four-variant contract.
enum ChatMessageVariant {
  /// Right-aligned, author's own broadcast message.
  broadcastAuthor,

  /// Left-aligned, other member's broadcast message with avatar + name.
  broadcastOther,

  /// Whisper: border + lock icon, distinct accent color.
  whisper,

  /// System message: centered italic, no bubble.
  system,
}

/// A single chat message row.
///
/// Long-press opens a bottom sheet with contextual actions
/// (Edit / Delete / Block) gated by [ownByMe] / [canEdit] / [canDelete] /
/// [canBlock] props.
class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    super.key,
    required this.messageId,
    required this.variant,
    required this.body,
    this.authorName,
    this.isEdited = false,
    this.isDeleted = false,
    this.ownByMe = false,
    this.canEdit = false,
    this.canDelete = false,
    this.canBlock = false,
    this.onDelete,
    this.onEdit,
    this.onBlock,
  });

  final String messageId;
  final ChatMessageVariant variant;
  final String body;
  final String? authorName;
  final bool isEdited;
  final bool isDeleted;
  final bool ownByMe;
  final bool canEdit;
  final bool canDelete;
  final bool canBlock;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onBlock;

  @override
  Widget build(BuildContext context) {
    if (variant == ChatMessageVariant.system) {
      return _SystemRow(body: body);
    }

    return GestureDetector(
      onLongPress: () => _showActionSheet(context),
      child: _buildBubbleRow(context),
    );
  }

  Widget _buildBubbleRow(BuildContext context) {
    final isAuthor = variant == ChatMessageVariant.broadcastAuthor;
    final isWhisper = variant == ChatMessageVariant.whisper;

    const bubbleAuthorColor = AppColors.chatBubbleAuthorBg;
    const bubbleOtherColor = AppColors.chatBubbleOtherBg;
    final bubbleColor = isAuthor ? bubbleAuthorColor : bubbleOtherColor;

    final border = isWhisper
        ? Border.all(color: AppColors.chatWhisperAccent, width: 1.0)
        : null;

    const textColor = AppColors.textPrimary;
    const deletedColor = AppColors.textSecondary;

    final bubbleContent = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.75,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: border,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWhisper) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock,
                  size: 12,
                  color: AppColors.chatWhisperAccent,
                ),
                const SizedBox(width: 4),
                if (authorName != null)
                  Text(
                    authorName!,
                    style: AppTypography.bodyXs.copyWith(
                      color: AppColors.chatWhisperAccent,
                      fontWeight: AppFontWeight.semibold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
          ] else if (variant == ChatMessageVariant.broadcastOther &&
              authorName != null) ...[
            Text(
              authorName!,
              style: AppTypography.bodyXs.copyWith(
                color: AppColors.brandBrass,
                fontWeight: AppFontWeight.semibold,
              ),
            ),
            const SizedBox(height: 2),
          ],
          isDeleted
              ? Text(
                  t.chat.message.deleted,
                  style: AppTypography.bodySm.copyWith(
                    color: deletedColor,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Text(
                  body,
                  style: AppTypography.bodySm.copyWith(color: textColor),
                ),
          if (isEdited && !isDeleted) ...[
            const SizedBox(height: 2),
            Text(
              t.chat.message.edited,
              style: AppTypography.bodyXs.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s1,
      ),
      child: Row(
        mainAxisAlignment: isAuthor
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isAuthor)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s2),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.brandBrassDeep,
                child: Text(
                  (authorName?.isNotEmpty == true)
                      ? authorName![0].toUpperCase()
                      : '?',
                  style: AppTypography.bodyXs.copyWith(
                    color: AppColors.textOnBrass,
                  ),
                ),
              ),
            ),
          bubbleContent,
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    if (!canEdit && !canDelete && !canBlock) return;
    HapticFeedback.selectionClick();

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(t.chat.message.menu.edit),
                onTap: () {
                  Navigator.pop(ctx);
                  onEdit?.call();
                },
              ),
            if (canDelete)
              ListTile(
                key: const Key('action_delete'),
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  t.chat.message.menu.delete,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete?.call();
                },
              ),
            if (canBlock)
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: Text(t.chat.message.menu.block),
                onTap: () {
                  Navigator.pop(ctx);
                  onBlock?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SystemRow extends StatelessWidget {
  const _SystemRow({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s1,
      ),
      child: Center(
        child: Text(
          body,
          textAlign: TextAlign.center,
          style: AppTypography.bodyXs.copyWith(
            color: AppColors.chatSystemFg,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
