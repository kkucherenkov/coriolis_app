import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/join_session/join_session_cubit.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/join_session/join_session_state.dart';

/// Handles the invite-accept flow driven by an invite token.
///
/// States rendered:
/// - loading → spinner
/// - previewLoaded → session name + GM name + Join button
/// - revoked → "Invite is no longer valid" message
/// - alreadyMember → preview + "Go to session" button
/// - success → navigates to player session detail
/// - failure → error + retry button
class JoinSessionPage extends StatelessWidget {
  const JoinSessionPage({
    required this.token,
    required this.repository,
    super.key,
  });

  final String token;
  final PlayerSessionRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoinSessionCubit>(
      create: (_) => JoinSessionCubit(repository: repository)..load(token),
      child: _Body(token: token),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Session')),
      body: BlocConsumer<JoinSessionCubit, JoinSessionState>(
        listener: (context, state) {
          if (state.status == JoinSessionStatus.success) {
            final membership = state.joinedMembership;
            if (membership != null) {
              Navigator.pushReplacementNamed(
                context,
                '/app/player-sessions/detail',
                arguments: membership.gameSessionId,
              );
            }
          }
        },
        builder: (context, state) {
          return switch (state.status) {
            JoinSessionStatus.initial ||
            JoinSessionStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            JoinSessionStatus.revoked => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'This invite is no longer valid.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            JoinSessionStatus.failure => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Something went wrong'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          context.read<JoinSessionCubit>().load(token),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            JoinSessionStatus.alreadyMember => _PreviewCard(
                sessionName: state.preview?.sessionName ?? '',
                gmDisplayName: state.preview?.gmDisplayName ?? '',
                trailing: FilledButton(
                  onPressed: () {
                    // Re-fetch memberships to get the gameSessionId, then navigate.
                    // For now, the cubit holds no gameSessionId from the preview;
                    // we trigger accept (idempotent) to retrieve the membership.
                    context
                        .read<JoinSessionCubit>()
                        .accept(token);
                  },
                  child: const Text('Go to session'),
                ),
              ),
            JoinSessionStatus.previewLoaded => _PreviewCard(
                sessionName: state.preview?.sessionName ?? '',
                gmDisplayName: state.preview?.gmDisplayName ?? '',
                trailing: FilledButton(
                  onPressed: () =>
                      context.read<JoinSessionCubit>().accept(token),
                  child: const Text('Join'),
                ),
              ),
            JoinSessionStatus.success => const Center(
                child: CircularProgressIndicator(),
              ),
          };
        },
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.sessionName,
    required this.gmDisplayName,
    required this.trailing,
  });

  final String sessionName;
  final String gmDisplayName;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sessionName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text('GM: $gmDisplayName'),
            const SizedBox(height: 24),
            trailing,
          ],
        ),
      ),
    );
  }
}
