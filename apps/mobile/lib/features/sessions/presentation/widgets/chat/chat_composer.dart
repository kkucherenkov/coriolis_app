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
                icon: const Icon(Icons.send),
                color: _canSend
                    ? AppColors.brandBrass
                    : AppColors.textSecondary,
                tooltip: 'Send',
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
