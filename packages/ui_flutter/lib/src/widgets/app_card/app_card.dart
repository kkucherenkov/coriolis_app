import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Card container variants.
enum AppCardVariant { defaultVariant, featured }

/// Coriolis-branded card container.
///
/// - [defaultVariant]: `--surface-night` background, `--brand-brass-deep` 1px border.
/// - [featured]: 1px `--brand-brass` border with `AppShadows.brassBevel`
///   (bevel effect from DESIGN §5.4).
///
/// Optional [header] and [footer] slot widgets, plus [child] content.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.defaultVariant,
    this.header,
    this.footer,
    this.padding,
  });

  final Widget child;
  final AppCardVariant variant;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;

  bool get _featured => variant == AppCardVariant.featured;

  Color get _borderColor => _featured ? AppColors.brandBrass : AppColors.brandBrassDeep;

  List<BoxShadow> get _shadows =>
      _featured ? AppShadows.brassBevel : const [];

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        const EdgeInsets.all(AppSpacing.s4);

    return AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppEasing.standard,
      decoration: BoxDecoration(
        color: AppColors.surfaceNight,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: _shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md - 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header != null) ...[
              _CardSection(
                child: header!,
                bottomBorder: true,
                borderColor: _borderColor,
              ),
            ],
            Padding(
              padding: effectivePadding,
              child: child,
            ),
            if (footer != null) ...[
              _CardSection(
                child: footer!,
                topBorder: true,
                borderColor: _borderColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({
    required this.child,
    required this.borderColor,
    this.topBorder = false,
    this.bottomBorder = false,
  });

  final Widget child;
  final Color borderColor;
  final bool topBorder;
  final bool bottomBorder;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: topBorder ? BorderSide(color: borderColor) : BorderSide.none,
          bottom: bottomBorder ? BorderSide(color: borderColor) : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s3,
        ),
        child: child,
      ),
    );
  }
}
