import 'package:flutter/material.dart';

/// Renders a Coriolis dice strip — one tile per die, value-coded by colour.
///
/// Values of 6 are highlighted in the brand brass tone (a "hit"); values of
/// 1 are dimmed in the danger tone (a "bane"). Indices passed in
/// `pushedIndices` get a dotted border to indicate the die was rerolled
/// during a push but didn't convert. This visual contract mirrors
/// `@app/ui`'s `AppDiePool` on the web side.
class RollResultStrip extends StatelessWidget {
  const RollResultStrip({
    super.key,
    required this.dice,
    this.pushedIndices = const [],
  });

  final List<int> dice;
  final List<int> pushedIndices;

  @override
  Widget build(BuildContext context) {
    final pushedSet = pushedIndices.toSet();
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < dice.length; i++)
          _DieTile(
            value: dice[i],
            pushed: pushedSet.contains(i),
            colorScheme: scheme,
          ),
      ],
    );
  }
}

class _DieTile extends StatelessWidget {
  const _DieTile({
    required this.value,
    required this.pushed,
    required this.colorScheme,
  });

  final int value;
  final bool pushed;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    if (value == 6) {
      background = colorScheme.primaryContainer;
      foreground = colorScheme.onPrimaryContainer;
    } else if (value == 1) {
      background = colorScheme.errorContainer;
      foreground = colorScheme.onErrorContainer;
    } else {
      background = colorScheme.surfaceContainerHighest;
      foreground = colorScheme.onSurface;
    }

    final faded = pushed && value != 6;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: background.withValues(alpha: faded ? 0.4 : 1),
        borderRadius: BorderRadius.circular(6),
        border: pushed
            ? Border.all(
                color: colorScheme.outline,
                width: 1,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          color: foreground.withValues(alpha: faded ? 0.6 : 1),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
