/// Offline queue status banner.
///
/// Renders a full-width bar above the host scaffold's body while the mutation
/// queue has pending entries, is syncing, has just synced, or has failed.
///
/// **Hidden states:** `status == idle && pending == 0` — the banner collapses
/// to zero height via [AnimatedSize]. The pure "offline with empty queue" case
/// (device is offline, nothing pending) is intentionally not shown: the drainer
/// does not expose raw connectivity state to the UI, and showing a persistent
/// "you're offline" bar with no actionable count is noisy. Web parity covers
/// this with `navigator.onLine`; mobile will revisit if a connectivity notifier
/// is added to the drainer in a future block.
///
/// Mount this widget via `MaterialApp.builder` (see `main.dart`).
library;

import 'package:flutter/material.dart';

import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue_drainer.dart';

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

/// Displays a contextual status bar driven by [MutationQueueDrainer].
///
/// Pass the DI-resolved drainer singleton; the widget only reads
/// [MutationQueueDrainer.pending] and [MutationQueueDrainer.status] —
/// it never calls [MutationQueueDrainer.start] or [MutationQueueDrainer.dispose].
class OfflineQueueBanner extends StatelessWidget {
  const OfflineQueueBanner({required this.drainer, super.key});

  final MutationQueueDrainer drainer;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MutationQueueStatus>(
      valueListenable: drainer.status,
      builder: (context, status, _) {
        return ValueListenableBuilder<int>(
          valueListenable: drainer.pending,
          builder: (context, pending, _) {
            return _BannerContent(
              status: status,
              pending: pending,
              drainer: drainer,
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private implementation
// ---------------------------------------------------------------------------

enum _BannerTone { warning, info, success, error }

_BannerTone? _resolveTone(MutationQueueStatus status, int pending) {
  switch (status) {
    case MutationQueueStatus.idle:
      return pending > 0 ? _BannerTone.warning : null;
    case MutationQueueStatus.syncing:
      return _BannerTone.info;
    case MutationQueueStatus.synced:
      return _BannerTone.success;
    case MutationQueueStatus.error:
      return _BannerTone.error;
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({
    required this.status,
    required this.pending,
    required this.drainer,
  });

  final MutationQueueStatus status;
  final int pending;
  final MutationQueueDrainer drainer;

  @override
  Widget build(BuildContext context) {
    final tone = _resolveTone(status, pending);

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: tone == null
          ? const SizedBox.shrink()
          : _BannerBar(tone: tone, status: status, pending: pending, drainer: drainer),
    );
  }
}

class _BannerBar extends StatelessWidget {
  const _BannerBar({
    required this.tone,
    required this.status,
    required this.pending,
    required this.drainer,
  });

  final _BannerTone tone;
  final MutationQueueStatus status;
  final int pending;
  final MutationQueueDrainer drainer;

  Color _background(ColorScheme cs) => switch (tone) {
        _BannerTone.warning => cs.tertiaryContainer,
        _BannerTone.info => cs.secondaryContainer,
        _BannerTone.success => cs.primaryContainer,
        _BannerTone.error => cs.errorContainer,
      };

  Color _foreground(ColorScheme cs) => switch (tone) {
        _BannerTone.warning => cs.onTertiaryContainer,
        _BannerTone.info => cs.onSecondaryContainer,
        _BannerTone.success => cs.onPrimaryContainer,
        _BannerTone.error => cs.onErrorContainer,
      };

  String _message(BuildContext context) {
    final t = Translations.of(context);
    return switch (status) {
      MutationQueueStatus.idle => t.common.offline.pending(count: pending),
      MutationQueueStatus.syncing => t.common.offline.syncing,
      MutationQueueStatus.synced => t.common.offline.synced,
      MutationQueueStatus.error => t.common.offline.error(count: pending),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = _background(cs);
    final fg = _foreground(cs);
    final t = Translations.of(context);

    return Container(
      width: double.infinity,
      color: bg,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _message(context),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: fg),
                ),
              ),
              if (status == MutationQueueStatus.error)
                TextButton(
                  onPressed: drainer.drainNow,
                  style: TextButton.styleFrom(foregroundColor: fg),
                  child: Text(t.common.offline.retry),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
