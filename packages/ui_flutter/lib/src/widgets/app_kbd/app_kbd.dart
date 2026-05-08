import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Visual size for [AppKbd].
enum AppKbdSize { sm, md }

/// Keyboard-shortcut pill.
///
/// Renders each key in [keys] as a rounded mono-font box, separated by `+`
/// labels.  Static and decorative — no interaction.
///
/// Example:
/// ```dart
/// AppKbd(keys: const ['Ctrl', 'K'])
/// AppKbd(keys: const ['⌘', 'Shift', 'P'], size: AppKbdSize.sm)
/// ```
class AppKbd extends StatelessWidget {
  const AppKbd({
    super.key,
    required this.keys,
    this.size = AppKbdSize.md,
  }) : assert(keys.length > 0, 'AppKbd requires at least one key');

  final List<String> keys;
  final AppKbdSize size;

  double get _fontSize => switch (size) {
        AppKbdSize.sm => 10.0,
        AppKbdSize.md => 12.0,
      };

  EdgeInsets get _keyPadding => switch (size) {
        AppKbdSize.sm =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: 2),
        AppKbdSize.md =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: 3),
      };

  double get _separatorFontSize => _fontSize - 1;

  @override
  Widget build(BuildContext context) {
    final keyStyle = TextStyle(
      fontFamily: AppFontFamily.mono,
      fontSize: _fontSize,
      fontWeight: AppFontWeight.medium,
      color: AppColors.brandBrass,
      height: 1.2,
    );

    final separatorStyle = TextStyle(
      fontFamily: AppFontFamily.body,
      fontSize: _separatorFontSize,
      fontWeight: AppFontWeight.regular,
      color: AppColors.textSecondary,
      height: 1.2,
    );

    final items = <Widget>[];
    for (var i = 0; i < keys.length; i++) {
      items.add(_KeyBox(label: keys[i], padding: _keyPadding, textStyle: keyStyle));
      if (i < keys.length - 1) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
            child: Text('+', style: separatorStyle),
          ),
        );
      }
    }

    return ExcludeSemantics(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: items,
      ),
    );
  }
}

class _KeyBox extends StatelessWidget {
  const _KeyBox({
    required this.label,
    required this.padding,
    required this.textStyle,
  });

  final String label;
  final EdgeInsets padding;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceNight,
        border: Border.all(color: AppColors.brandBrassShadow),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: const [
          BoxShadow(
            color: AppColors.brandBrassShadow,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(label, style: textStyle),
    );
  }
}
