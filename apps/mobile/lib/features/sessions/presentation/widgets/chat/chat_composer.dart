import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Maximum character length of a message body.
const int kChatMaxLength = 2000;

/// Composer input bar for sending chat messages.
///
/// - ⌘/Ctrl + Enter submits.
/// - Plain Enter does NOT submit.
/// - Shows a character counter; warn at maxLength-64, error at maxLength.
/// - Send button disabled when value is whitespace-only.
/// - [HapticFeedback.lightImpact] on send.
/// - When [isEditing] is true, a banner appears above the textfield with
///   the original message body as preview + a Cancel button. The Send
///   icon swaps to a check and the tooltip flips to [saveTooltip].
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.value,
    required this.onSubmit,
    required this.onChanged,
    this.placeholder = 'Message…',
    this.maxLength = kChatMaxLength,
    this.enabled = true,
    this.isEditing = false,
    this.editingPreview = '',
    this.editingLabel = 'Editing message',
    this.cancelEditLabel = 'Cancel',
    this.sendTooltip = 'Send',
    this.saveTooltip = 'Save',
    this.onCancelEdit,
  });

  final TextEditingController controller;

  /// Current composer value (kept in sync via [onChanged]).
  final String value;

  /// Called when the user submits (button press or ⌘/Ctrl+Enter).
  final VoidCallback onSubmit;

  final ValueChanged<String> onChanged;
  final String placeholder;
  final int maxLength;
  final bool enabled;

  /// When true, the editing banner is shown and the submit button uses the
  /// "Save" affordance (check icon + [saveTooltip]).
  final bool isEditing;

  /// Snapshot of the message body being edited, rendered inside the
  /// banner as a one-line preview.
  final String editingPreview;

  /// Banner heading (e.g. "Editing message" / "Редактирование сообщения").
  final String editingLabel;

  /// Label for the Cancel button inside the editing banner.
  final String cancelEditLabel;

  /// Tooltip for the submit button while composing a new message.
  final String sendTooltip;

  /// Tooltip for the submit button while editing.
  final String saveTooltip;

  /// Fires when the user taps Cancel in the banner. Required when
  /// [isEditing] is true.
  final VoidCallback? onCancelEdit;

  bool get _canSend => value.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final remaining = maxLength - value.length;
    final isWarn = remaining <= 64 && remaining > 0;
    final isError = remaining <= 0;

    final counterColor = isError
        ? Colors.red
        : isWarn
            ? Colors.orange
            : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDawn,
        border: Border(
          top: BorderSide(color: AppColors.brandBrassDeep, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEditing) _EditingBanner(
            label: editingLabel,
            preview: editingPreview,
            cancelLabel: cancelEditLabel,
            onCancel: onCancelEdit,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    if (event is! KeyDownEvent) return;
                    final isEnter =
                        event.logicalKey == LogicalKeyboardKey.enter ||
                        event.logicalKey == LogicalKeyboardKey.numpadEnter;
                    final isMeta = HardwareKeyboard.instance.isMetaPressed ||
                        HardwareKeyboard.instance.isControlPressed;
                    if (isEnter && isMeta && _canSend) {
                      _doSubmit();
                    }
                  },
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    enabled: enabled,
                    maxLines: 4,
                    minLines: 1,
                    maxLength: maxLength,
                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                    textInputAction: TextInputAction.newline,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s3,
                        vertical: AppSpacing.s2,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceNight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              IconButton(
                key: const Key('send_button'),
                onPressed: _canSend ? _doSubmit : null,
                icon: Icon(isEditing ? Icons.check : Icons.send),
                color: _canSend
                    ? AppColors.brandBrass
                    : AppColors.textSecondary,
                tooltip: isEditing ? saveTooltip : sendTooltip,
              ),
            ],
          ),
          if (isWarn || isError)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.s1,
                left: AppSpacing.s3,
              ),
              child: Text(
                key: const Key('char_counter'),
                '${value.length} / $maxLength',
                style: AppTypography.bodyXs.copyWith(color: counterColor),
              ),
            ),
        ],
      ),
    );
  }

  void _doSubmit() {
    HapticFeedback.lightImpact();
    onSubmit();
  }
}

/// One-line banner rendered above the textfield while editing a message.
///
/// Mirrors `AppChatComposer.vue` (`packages/ui/src/components/AppChatComposer`):
/// banner heading + truncated preview of the original body + Cancel button.
class _EditingBanner extends StatelessWidget {
  const _EditingBanner({
    required this.label,
    required this.preview,
    required this.cancelLabel,
    required this.onCancel,
  });

  final String label;
  final String preview;
  final String cancelLabel;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('editing_banner'),
      margin: const EdgeInsets.only(bottom: AppSpacing.s2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceNight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.brandBrassDeep,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.brandBrass,
                  ),
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    preview,
                    key: const Key('editing_banner_preview'),
                    style: AppTypography.bodyXs.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s2),
          TextButton(
            key: const Key('editing_banner_cancel'),
            onPressed: onCancel,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s2,
                vertical: AppSpacing.s1,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
            ),
            child: Text(
              cancelLabel,
              style: AppTypography.labelSm,
            ),
          ),
        ],
      ),
    );
  }
}
