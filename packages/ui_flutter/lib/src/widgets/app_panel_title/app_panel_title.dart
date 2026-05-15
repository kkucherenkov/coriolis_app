import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';
import '../app_swash/app_swash.dart';

/// Visual size for [AppPanelTitle] — controls font-size and paired swash width.
enum AppPanelTitleSize { sm, md, lg }

/// Forum heading + paired calligraphic swash. Mirrors `@app/ui` `AppPanelTitle`.
///
/// Used as the single source of truth for panel headers across sheets, ship
/// sheet, wizard, dashboard, and GM session screens.
///
/// Typography: Forum at 16 / 22 / 28 logical px (sm / md / lg) with the
/// project's display tracking (0.04em). The 16 / 22 / 28 scale follows the
/// handoff and does not align 1-for-1 with the `AppTypography.display*` roles
/// (20 / 28 / 36), so the family / weight / colour come from tokens while
/// font-size is a documented per-component constant.
class AppPanelTitle extends StatelessWidget {
  const AppPanelTitle({
    super.key,
    required this.text,
    this.size = AppPanelTitleSize.md,
    this.semanticsLabel,
  });

  /// Heading text.
  final String text;

  /// Visual size — controls font-size and swash width.
  final AppPanelTitleSize size;

  /// Optional override for the heading semantics label (defaults to [text]).
  final String? semanticsLabel;

  double get _fontSize => switch (size) {
        AppPanelTitleSize.sm => 16.0,
        AppPanelTitleSize.md => 22.0,
        AppPanelTitleSize.lg => 28.0,
      };

  double get _swashWidth => switch (size) {
        AppPanelTitleSize.sm => 70.0,
        AppPanelTitleSize.md => 70.0,
        AppPanelTitleSize.lg => 110.0,
      };

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: AppFontFamily.display,
      fontSize: _fontSize,
      fontWeight: AppFontWeight.regular,
      height: 1.2,
      letterSpacing: 0.04 * _fontSize,
      color: AppColors.brandBrassLight,
    );

    return Semantics(
      header: true,
      label: semanticsLabel ?? text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: style),
          const SizedBox(height: AppSpacing.s1),
          AppSwash(width: _swashWidth),
        ],
      ),
    );
  }
}
