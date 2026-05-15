import 'package:flutter/material.dart';

import 'package:coriolis_companion/app/routes.dart';
import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';
import 'package:coriolis_companion/shared/di/injector.dart';

/// Dashboard home screen — the authenticated landing page.
///
/// Shows a Sessions section with a [SegmentedButton] switching between
/// "Running" (GM-owned sessions) and "Playing in" (joined as player).
///
/// Tapping the primary action card navigates to [AppRoutes.sessions].
/// Playing-in count is fixed to 0 until Stream B ships
/// `GET /me/memberships`.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

/// Controls which sessions scope is shown on the dashboard.
enum DashboardSessionsScope { running, playing }

class _DashboardPageState extends State<DashboardPage> {
  DashboardSessionsScope _scope = DashboardSessionsScope.running;
  int _playerCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPlayerCount();
  }

  Future<void> _loadPlayerCount() async {
    try {
      final repo = getIt<PlayerSessionRepository>();
      final memberships = await repo.getMyMemberships();
      final playerMemberships =
          memberships.where((m) => m.role == 'player').toList();
      if (mounted) setState(() => _playerCount = playerMemberships.length);
    } catch (_) {
      // Keep at 0 — non-fatal; count displayed when load succeeds.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Sessions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              SegmentedButton<DashboardSessionsScope>(
                segments: [
                  const ButtonSegment(
                    value: DashboardSessionsScope.running,
                    label: Text('Running'),
                    icon: Icon(Icons.play_circle_outline),
                  ),
                  ButtonSegment(
                    value: DashboardSessionsScope.playing,
                    label: Text('Playing in ($_playerCount)'),
                    icon: const Icon(Icons.people_outline),
                  ),
                ],
                selected: {_scope},
                onSelectionChanged: (selection) {
                  setState(() => _scope = selection.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SessionsScopeBody(scope: _scope),
        ],
      ),
    );
  }
}

// ── _SessionsScopeBody ────────────────────────────────────────────────────────

class _SessionsScopeBody extends StatelessWidget {
  const _SessionsScopeBody({required this.scope});

  final DashboardSessionsScope scope;

  @override
  Widget build(BuildContext context) {
    if (scope == DashboardSessionsScope.running) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.play_circle_outline),
          title: const Text('My sessions'),
          subtitle: const Text('View and manage your game sessions.'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.sessions),
        ),
      );
    }

    // Playing-in — navigates to the player sessions list (Stream B).
    return Card(
      child: ListTile(
        leading: const Icon(Icons.people_outline),
        title: const Text('Sessions I play in'),
        subtitle: const Text('View and manage sessions you joined as a player.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.playerSessions),
      ),
    );
  }
}
