import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Presence states for chat participants.
///
/// Mirrors the web `AppChatPresence` enum in
/// `packages/ui/src/components/AppChatPresenceDot/`.
enum AppChatPresence {
  /// Member has an active Centrifugo connection on this session channel.
  online,

  /// Member was recently active but is not currently connected.
  idle,

  /// Member has no active connection on this session channel.
  offline,
}

/// Small circular indicator showing a chat participant's presence state.
///
/// Diameter is always 8 px. A 2 px border is rendered in all states so that
/// the hit-box stays consistent — matching the web component's approach.
///
/// Colour routing:
/// - [AppChatPresence.online]  → [AppColors.brandBrass] fill
/// - [AppChatPresence.idle]    → [AppColors.textSecondary] fill
/// - [AppChatPresence.offline] → transparent fill, [AppColors.textSecondary] border
class AppChatPresenceDot extends StatelessWidget {
  const AppChatPresenceDot({
    super.key,
    required this.presence,
  });

  final AppChatPresence presence;

  static const double _diameter = 8.0;
  static const double _borderWidth = 2.0;

  Color get _fillColor => switch (presence) {
        AppChatPresence.online => AppColors.brandBrass,
        AppChatPresence.idle => AppColors.textSecondary,
        AppChatPresence.offline => const Color(0x00000000),
      };

  Color get _borderColor => switch (presence) {
        AppChatPresence.online => AppColors.brandBrass,
        AppChatPresence.idle => AppColors.textSecondary,
        AppChatPresence.offline => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: presence.name,
      child: SizedBox(
        width: _diameter,
        height: _diameter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _fillColor,
            border: Border.all(
              color: _borderColor,
              width: _borderWidth,
            ),
          ),
        ),
      ),
    );
  }
}
