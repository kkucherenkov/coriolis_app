import 'package:flutter/material.dart';

import 'package:coriolis_companion/app/routes.dart';

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
                segments: const [
                  ButtonSegment(
                    value: DashboardSessionsScope.running,
                    label: Text('Running'),
                    icon: Icon(Icons.play_circle_outline),
                  ),
                  ButtonSegment(
                    value: DashboardSessionsScope.playing,
                    // Playing-in count fixed to (0) until Stream B.
                    label: Text('Playing in (0)'),
                    icon: Icon(Icons.people_outline),
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

    // Playing-in — Stream B will replace this empty state with the
    // memberships list fetched from GET /me/memberships.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Not playing in any sessions yet',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Ask your GM for an invite link to join a session.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
