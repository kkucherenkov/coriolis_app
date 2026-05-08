import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Avatar sizes matching common usage in the Coriolis UI.
enum AppAvatarSize {
  /// 24px — inline/nav usage.
  xs,

  /// 32px — list row usage.
  sm,

  /// 40px — default.
  md,

  /// 56px — sheet header compact.
  lg,

  /// 80px — sheet header full.
  xl,
}

/// Color tone for the initials fallback background.
enum AppAvatarTone { brass, mystic, crimson, darkness }

/// Avatar shape.
enum AppAvatarShape { circle, square }

/// Avatar widget — initials fallback with optional network image.
///
/// Cyrillic-safe initials algorithm: takes the first grapheme cluster from
/// each word in [name] (up to two), uppercases them. Works for both Latin
/// ("John Doe" → "JD") and Cyrillic ("Иван Петров" → "ИП").
///
/// Image loading uses the standard Flutter [Image.network]. If the image fails
/// to load, the widget falls back to the initials view automatically.
///
/// [imageUrl] is optional. When `null` or on error, initials are shown.
class AppAvatar extends StatefulWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = AppAvatarSize.md,
    this.tone = AppAvatarTone.brass,
    this.shape = AppAvatarShape.circle,
  });

  final String name;
  final String? imageUrl;
  final AppAvatarSize size;
  final AppAvatarTone tone;
  final AppAvatarShape shape;

  @override
  State<AppAvatar> createState() => _AppAvatarState();
}

class _AppAvatarState extends State<AppAvatar> {
  bool _imageError = false;

  void _onImageError(Object error, StackTrace? stack) {
    if (mounted) setState(() => _imageError = true);
  }

  @override
  void didUpdateWidget(AppAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageError = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diameter = _diameter(widget.size);
    final showImage = widget.imageUrl != null && !_imageError;
    final borderRadius = widget.shape == AppAvatarShape.circle
        ? BorderRadius.circular(AppRadius.pill)
        : BorderRadius.circular(AppRadius.md);

    Widget content;
    if (showImage) {
      content = Image.network(
        widget.imageUrl!,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        errorBuilder: (_, err, stack) {
          _onImageError(err, stack);
          return _initials(diameter);
        },
      );
    } else {
      content = _initials(diameter);
    }

    return Semantics(
      label: widget.name,
      image: showImage,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(width: diameter, height: diameter, child: content),
      ),
    );
  }

  Widget _initials(double size) {
    final text = _extractInitials(widget.name);
    final bg = _bgColor(widget.tone);
    final fg = _fgColor(widget.tone);
    final fontSize = (size * 0.4).clamp(10.0, 28.0);

    return Container(
      color: bg,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppFontFamily.body,
            fontSize: fontSize,
            fontWeight: AppFontWeight.semibold,
            color: fg,
            height: 1,
          ),
        ),
      ),
    );
  }

  static double _diameter(AppAvatarSize size) => switch (size) {
        AppAvatarSize.xs => 24.0,
        AppAvatarSize.sm => 32.0,
        AppAvatarSize.md => 40.0,
        AppAvatarSize.lg => 56.0,
        AppAvatarSize.xl => 80.0,
      };

  static Color _bgColor(AppAvatarTone tone) => switch (tone) {
        AppAvatarTone.brass => AppColors.brandBrassDeep,
        AppAvatarTone.mystic => AppColors.stateMysticTeal,
        AppAvatarTone.crimson => AppColors.stateCrimson,
        AppAvatarTone.darkness => AppColors.stateDarkness,
      };

  static Color _fgColor(AppAvatarTone tone) => switch (tone) {
        AppAvatarTone.brass => AppColors.textOnBrass,
        _ => AppColors.textPrimary,
      };

  /// Cyrillic-safe initials: split on whitespace, take first grapheme cluster
  /// of up to two words, uppercase.
  static String _extractInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final words = trimmed.split(RegExp(r'\s+'));
    final chars = words.take(2).map((w) {
      // Use String.characters equivalent via runes — safe for Cyrillic/emoji.
      final runes = w.runes.toList();
      if (runes.isEmpty) return '';
      return String.fromCharCode(runes.first).toUpperCase();
    }).where((s) => s.isNotEmpty).toList();
    return chars.isEmpty ? '?' : chars.join();
  }
}
