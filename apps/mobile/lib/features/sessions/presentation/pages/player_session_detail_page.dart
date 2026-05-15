import 'package:flutter/material.dart';

import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';
import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';

/// Minimal player session detail page.
///
/// Resolves the session name from the membership list (no dedicated
/// "get session detail" endpoint exists for mobile yet). Encounter
/// content will be wired up in Stream D.
class PlayerSessionDetailPage extends StatefulWidget {
  const PlayerSessionDetailPage({
    required this.gameSessionId,
    required this.repository,
    super.key,
  });

  final String gameSessionId;
  final PlayerSessionRepository repository;

  @override
  State<PlayerSessionDetailPage> createState() =>
      _PlayerSessionDetailPageState();
}

class _PlayerSessionDetailPageState extends State<PlayerSessionDetailPage> {
  PlayerMembership? _membership;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final memberships = await widget.repository.getMyMemberships();
      final match = memberships
          .where((m) => m.gameSessionId == widget.gameSessionId)
          .firstOrNull;
      if (mounted) {
        setState(() {
          _membership = match;
          _loading = false;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _leaveSession() async {
    final m = _membership;
    if (m == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave session?'),
        content: Text(
          'You are about to leave "${m.sessionName}". '
          'You can rejoin via invite link.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.repository.leaveSession(m.membershipId, m.gameSessionId);
      if (mounted) Navigator.pop(context);
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionName = _membership?.sessionName ?? 'Session';

    return Scaffold(
      appBar: AppBar(
        title: Text(sessionName),
        actions: [
          if (_membership != null)
            TextButton(
              onPressed: _leaveSession,
              child: const Text('Leave'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_membership == null) {
      return const Center(child: Text('Session not found'));
    }

    return const Center(
      // Placeholder — encounter content arrives in Stream D.
      child: Text('Encounter coming in Stream D'),
    );
  }
}
