import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Four-state invite-link manager for the GM session-detail page.
///
/// - [InviteState.none] — no invite link exists; shows a Generate CTA.
/// - [InviteState.active] — an invite is active; shows Copy / Rotate / Revoke.
/// - [InviteState.justGenerated] — link was just created; reveals the URL once.
/// - [InviteState.justRotated] — link was rotated; reveals the new URL once.
///
/// i18n via `AppLocalizations.invite*` is deferred to Stream B; this widget
/// uses hard-coded English strings matching the web `AppInviteManager`.
enum InviteState { none, active, justGenerated, justRotated }

class InviteManagerWidget extends StatelessWidget {
  const InviteManagerWidget({
    super.key,
    required this.state,
    required this.rotatedAt,
    required this.revealUrl,
    required this.onGenerate,
    required this.onRotate,
    required this.onRevoke,
    required this.onCopy,
    required this.onCloseReveal,
  });

  final InviteState state;

  /// Timestamp of the last rotation. Must be non-null when [state] is
  /// [InviteState.active].
  final DateTime? rotatedAt;

  /// Plaintext URL shown exactly once. Must be non-null when [state] is
  /// [InviteState.justGenerated] or [InviteState.justRotated].
  final String? revealUrl;

  final VoidCallback onGenerate;
  final VoidCallback onRotate;
  final VoidCallback onRevoke;

  /// Called when the user taps "Copy link" in the active state. The page
  /// re-triggers [rotateInvite] to expose the URL (mirrors web behaviour).
  final VoidCallback onCopy;
  final VoidCallback onCloseReveal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: switch (state) {
          InviteState.none => _NoneBody(onGenerate: onGenerate),
          InviteState.active => _ActiveBody(
              rotatedAt: rotatedAt!,
              onCopy: onCopy,
              onRotate: onRotate,
              onRevoke: onRevoke,
            ),
          InviteState.justGenerated || InviteState.justRotated => _RevealBody(
              url: revealUrl!,
              isRotated: state == InviteState.justRotated,
              onClose: onCloseReveal,
            ),
        },
      ),
    );
  }
}

// ── _NoneBody ────────────────────────────────────────────────────────────────

class _NoneBody extends StatelessWidget {
  const _NoneBody({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Generate a link your players can use to join this session and link their characters.',
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onGenerate,
          child: const Text('Generate invite link'),
        ),
      ],
    );
  }
}

// ── _ActiveBody ──────────────────────────────────────────────────────────────

class _ActiveBody extends StatelessWidget {
  const _ActiveBody({
    required this.rotatedAt,
    required this.onCopy,
    required this.onRotate,
    required this.onRevoke,
  });

  final DateTime rotatedAt;
  final VoidCallback onCopy;
  final VoidCallback onRotate;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active since ${rotatedAt.toIso8601String()}'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(onPressed: onCopy, child: const Text('Copy link')),
            OutlinedButton(onPressed: onRotate, child: const Text('Rotate')),
            TextButton(onPressed: onRevoke, child: const Text('Revoke')),
          ],
        ),
      ],
    );
  }
}

// ── _RevealBody ──────────────────────────────────────────────────────────────

class _RevealBody extends StatelessWidget {
  const _RevealBody({
    required this.url,
    required this.isRotated,
    required this.onClose,
  });

  final String url;
  final bool isRotated;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRotated ? 'Link rotated' : 'Your new invite link',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SelectableText(url, style: const TextStyle(fontFamily: 'monospace')),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
          },
          child: const Text('Copy'),
        ),
        const SizedBox(height: 8),
        const Text(
          'This URL appears once. If you lose it, rotate the invite to generate a new one.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: onClose,
            child: const Text("I've copied it — close"),
          ),
        ),
      ],
    );
  }
}
