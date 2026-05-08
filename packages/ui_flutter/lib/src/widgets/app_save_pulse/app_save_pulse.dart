import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// The lifecycle state of a save operation, mirroring the web `useAutoSave` enum.
enum AppSavePulseState { idle, saving, saved, error }

/// 8×8 animated dot that communicates auto-save status.
///
/// - `idle`  — dim brass dot.
/// - `saving` — brass dot that pulses via scale + opacity tween.
///   Falls back to opacity-only when `MediaQuery.disableAnimations` is true.
/// - `saved`  — solid brass dot; auto-fades to idle after [savedDuration]
///   (parent resets [state] to [AppSavePulseState.idle]).
/// - `error`  — solid crimson dot, no animation.
///
/// The parent drives lifecycle transitions by updating [state]. This widget
/// does not schedule its own `saved → idle` timer — that is intentional:
/// ownership stays with the cubit, matching the web `useAutoSave` contract.
class AppSavePulse extends StatefulWidget {
  const AppSavePulse({
    super.key,
    required this.state,
    this.size = 8.0,
    this.semanticLabel,
  });

  final AppSavePulseState state;

  /// Dot diameter in logical pixels (default 8).
  final double size;

  /// Overrides the default accessibility label for the current state.
  final String? semanticLabel;

  @override
  State<AppSavePulse> createState() => _AppSavePulseState();
}

class _AppSavePulseState extends State<AppSavePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = Tween<double>(begin: 0.75, end: 1.25).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: AppOpacity.muted, end: AppOpacity.o100).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _syncAnimation();
  }

  @override
  void didUpdateWidget(AppSavePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.state == AppSavePulseState.saving) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _dotColor => switch (widget.state) {
        AppSavePulseState.idle => AppColors.brandBrassDeep,
        AppSavePulseState.saving => AppColors.brandBrass,
        AppSavePulseState.saved => AppColors.brandBrass,
        AppSavePulseState.error => AppColors.stateCrimsonBright,
      };

  String get _defaultLabel => switch (widget.state) {
        AppSavePulseState.idle => 'Save status: idle',
        AppSavePulseState.saving => 'Saving…',
        AppSavePulseState.saved => 'Saved',
        AppSavePulseState.error => 'Save error',
      };

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final label = widget.semanticLabel ?? _defaultLabel;

    Widget dot = SizedBox(
      width: widget.size,
      height: widget.size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _dotColor,
          shape: BoxShape.circle,
        ),
      ),
    );

    if (widget.state == AppSavePulseState.saving) {
      if (disableAnimations) {
        // Reduced-motion: opacity fade only.
        dot = FadeTransition(opacity: _opacity, child: dot);
      } else {
        // Full animation: scale + opacity.
        dot = FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(scale: _scale, child: dot),
        );
      }
    }

    return Semantics(
      label: label,
      child: dot,
    );
  }
}
