import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'dart:async';

import 'package:coriolis_companion/features/auth/domain/auth_repository.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_cubit.dart';
import 'package:coriolis_companion/features/combat/presentation/widgets/active_combat_card.dart';
import 'package:coriolis_companion/features/sessions/domain/game_session.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/session_detail/session_detail_cubit.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/session_detail/session_detail_state.dart';
import 'package:coriolis_companion/shared/di/injector.dart';
import 'package:coriolis_companion/shared/realtime/session_realtime.dart';

/// Session detail page (Phase 4 Block 3 mobile).
///
/// Branches on `isGm` (current user matches `session.ownerId`). GM
/// gets `+1` / `-1` quick taps and the audit log tail; players see a
/// read-only DP card and the assigned-character list. Mobile drops
/// the web's free-form delta-with-reason form — at-table GMs run the
/// rich controls on a laptop, the phone is for quick adjustments.
class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionDetailCubit>(
          create: (_) => getIt<SessionDetailCubit>()..load(sessionId),
        ),
        BlocProvider<ActiveCombatCubit>(
          create: (_) => getIt<ActiveCombatCubit>()..load(sessionId),
        ),
      ],
      child: _SessionDetailBody(sessionId: sessionId),
    );
  }
}

class _SessionDetailBody extends StatefulWidget {
  const _SessionDetailBody({required this.sessionId});

  final String sessionId;

  @override
  State<_SessionDetailBody> createState() => _SessionDetailBodyState();
}

class _SessionDetailBodyState extends State<_SessionDetailBody> {
  String? _meId;
  StreamSubscription<RollPushedPayload>? _rollPushedSub;

  @override
  void initState() {
    super.initState();
    _resolveMe();
    // Subscribe to roll-pushed events from the cubit's realtime stream;
    // surface as a transient SnackBar. The subscription is canceled
    // on dispose so a navigated-away page doesn't keep posting toasts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<SessionDetailCubit>();
      _rollPushedSub = cubit.rollPushed.listen(_onRollPushed);
    });
  }

  @override
  void dispose() {
    _rollPushedSub?.cancel();
    super.dispose();
  }

  void _onRollPushed(RollPushedPayload payload) {
    if (!mounted) return;
    final hits = payload.hits;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Roll pushed: character ${payload.characterId.substring(0, 8)}… '
          'got $hits hit${hits == 1 ? '' : 's'}.',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _resolveMe() async {
    // `getSession` round-trips to the backend on every call; the auth
    // gate already verified there's a session for this view, so this
    // is the cheap path to recover the current user's id without a
    // dedicated /me composable. A `null` here defaults the page to
    // the player view, which is the safer option.
    final user = await getIt<AuthRepository>().getSession();
    if (!mounted) return;
    setState(() => _meId = user?.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session')),
      body: BlocBuilder<SessionDetailCubit, SessionDetailState>(
        builder: (ctx, state) {
          switch (state.status) {
            case SessionDetailStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case SessionDetailStatus.notFound:
              return _emptyState(
                ctx,
                heading: 'Session not found',
                body: 'It may have been deleted or you don\'t have access.',
              );
            case SessionDetailStatus.error:
              return _emptyState(
                ctx,
                heading: 'Couldn\'t load session',
                body: state.errorMessage ?? '',
              );
            case SessionDetailStatus.loaded:
              final session = state.session!;
              final isGm = _meId != null && _meId == session.ownerId;
              return _DetailContent(
                session: session,
                isGm: isGm,
                dpEvents: state.dpEvents,
                dpError: state.dpError,
                dpSubmitting: state.dpSubmitting,
              );
          }
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context, {required String heading, required String body}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(heading, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _DetailContent extends StatefulWidget {
  const _DetailContent({
    required this.session,
    required this.isGm,
    required this.dpEvents,
    required this.dpError,
    required this.dpSubmitting,
  });

  final GameSession session;
  final bool isGm;
  final List<DpEvent> dpEvents;
  final String? dpError;
  final bool dpSubmitting;

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  bool _kickedAuditLoad = false;

  @override
  void didUpdateWidget(covariant _DetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGm && !_kickedAuditLoad) {
      _kickedAuditLoad = true;
      // Audit log is GM-only on the server too — only fetch it when we
      // know the user is the owner. didUpdateWidget covers the case
      // where `isGm` flips true after the async `_resolveMe`.
      context.read<SessionDetailCubit>().loadDpEvents();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isGm) {
      _kickedAuditLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<SessionDetailCubit>().loadDpEvents();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      children: [
        _Header(name: s.name, description: s.description, isGm: widget.isGm),
        const SizedBox(height: 12),
        _DpCard(
          dpCount: s.dpCount,
          isGm: widget.isGm,
          submitting: widget.dpSubmitting,
          error: widget.dpError,
        ),
        const SizedBox(height: 12),
        ActiveCombatCard(sessionId: widget.session.id),
        const SizedBox(height: 12),
        _CharactersCard(characterIds: s.characterIds),
        if (widget.isGm) ...[
          const SizedBox(height: 12),
          _AuditCard(events: widget.dpEvents),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.description, required this.isGm});

  final String name;
  final String? description;
  final bool isGm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(name, style: Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(isGm ? 'GM owner' : 'Player view'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        if (description != null && description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(description!,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
      ],
    );
  }
}

class _DpCard extends StatelessWidget {
  const _DpCard({
    required this.dpCount,
    required this.isGm,
    required this.submitting,
    required this.error,
  });

  final int dpCount;
  final bool isGm;
  final bool submitting;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Darkness Points',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      letterSpacing: 1.2,
                    )),
            const SizedBox(height: 4),
            Text('$dpCount',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    )),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (isGm) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: submitting
                        ? null
                        : () => context
                            .read<SessionDetailCubit>()
                            .adjustDp(delta: -1),
                    icon: const Icon(Icons.remove),
                    label: const Text('−1'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: submitting
                        ? null
                        : () => context
                            .read<SessionDetailCubit>()
                            .adjustDp(delta: 1),
                    icon: const Icon(Icons.add),
                    label: const Text('+1'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CharactersCard extends StatelessWidget {
  const _CharactersCard({required this.characterIds});

  final List<String> characterIds;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Characters',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      letterSpacing: 1.2,
                    )),
            const SizedBox(height: 8),
            if (characterIds.isEmpty)
              Text(
                'No characters assigned yet.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              for (final id in characterIds)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• #$id',
                      style: const TextStyle(fontFamily: 'monospace')),
                ),
            // Note: assignment from mobile is deliberately a follow-up;
            // the GM uses the web UI for the heavy "set up the
            // session" workflow. This page is glance-and-tweak.
          ],
        ),
      ),
    );
  }
}

class _AuditCard extends StatelessWidget {
  const _AuditCard({required this.events});

  final List<DpEvent> events;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d · HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audit log',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      letterSpacing: 1.2,
                    )),
            const SizedBox(height: 8),
            if (events.isEmpty)
              Text(
                'No DP events yet.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              for (final e in events)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          (e.delta >= 0 ? '+' : '') + e.delta.toString(),
                          style: TextStyle(
                            color: e.delta >= 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.reason ?? _sourceLabel(e.source),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        fmt.format(e.createdAt.toLocal()),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  String _sourceLabel(String source) {
    switch (source) {
      case 'gm-manual':
        return 'GM';
      case 'roll-push':
        return 'Roll push';
      case 'system':
        return 'System';
      default:
        return source;
    }
  }
}
