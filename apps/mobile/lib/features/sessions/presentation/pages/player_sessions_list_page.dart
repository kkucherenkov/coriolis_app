import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';
import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_cubit.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_state.dart';

/// Lists all active memberships for the authenticated user (both GM and player
/// roles). Tapping a card navigates to the player session detail page.
///
/// DI: the [PlayerSessionRepository] is injected via constructor so the page
/// can be widget-tested without a full DI container.
class PlayerSessionsListPage extends StatelessWidget {
  const PlayerSessionsListPage({
    required this.repository,
    super.key,
  });

  final PlayerSessionRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayerSessionsListCubit>(
      create: (_) =>
          PlayerSessionsListCubit(repository: repository)..load(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Sessions')),
      body: BlocBuilder<PlayerSessionsListCubit, PlayerSessionsListState>(
        builder: (context, state) {
          return switch (state.status) {
            PlayerSessionsStatus.initial ||
            PlayerSessionsStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            PlayerSessionsStatus.failure => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Something went wrong'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          context.read<PlayerSessionsListCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            PlayerSessionsStatus.success
                when state.memberships.isEmpty =>
              const Center(child: Text('No active sessions')),
            PlayerSessionsStatus.success => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.memberships.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (_, i) =>
                    _MembershipCard(membership: state.memberships[i]),
              ),
          };
        },
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.membership});

  final PlayerMembership membership;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(membership.sessionName),
        subtitle: Text(membership.role.toUpperCase()),
        trailing: membership.characterName != null
            ? Text(membership.characterName!)
            : null,
        onTap: () => Navigator.pushNamed(
          context,
          '/app/player-sessions/detail',
          arguments: membership.gameSessionId,
        ),
      ),
    );
  }
}
