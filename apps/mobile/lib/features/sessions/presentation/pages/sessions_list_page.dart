import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/app/routes.dart';
import 'package:coriolis_companion/features/sessions/domain/game_session.dart';
import 'package:coriolis_companion/features/sessions/domain/session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/sessions_list/sessions_list_cubit.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/sessions_list/sessions_list_state.dart';
import 'package:coriolis_companion/shared/di/injector.dart';

/// Sessions index — tabbed (active / archived) list with per-row Open
/// + Archive toggle and a + button to create. Mobile-first compact
/// layout: one card per session, badges for DP count and assigned
/// character count.
class SessionsListPage extends StatelessWidget {
  const SessionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionsListCubit>(
      create: (_) => getIt<SessionsListCubit>()..load(),
      child: const _SessionsListBody(),
    );
  }
}

class _SessionsListBody extends StatelessWidget {
  const _SessionsListBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Sessions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: BlocBuilder<SessionsListCubit, SessionsListState>(
            builder: (ctx, state) {
              return Row(
                children: [
                  for (final tab in const [
                    ('active', 'Active'),
                    ('archived', 'Archived'),
                  ])
                    Expanded(
                      child: InkWell(
                        onTap: () => ctx.read<SessionsListCubit>().setFilter(tab.$1),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: state.statusFilter == tab.$1
                                    ? Theme.of(ctx).colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            tab.$2,
                            style: TextStyle(
                              color: state.statusFilter == tab.$1
                                  ? Theme.of(ctx).colorScheme.primary
                                  : Theme.of(ctx).colorScheme.onSurfaceVariant,
                              fontWeight: state.statusFilter == tab.$1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<SessionsListCubit, SessionsListState>(
        buildWhen: (a, b) => a.statusFilter != b.statusFilter,
        builder: (ctx, state) {
          if (state.statusFilter != 'active') return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _openCreateSheet(ctx),
            icon: const Icon(Icons.add),
            label: const Text('New session'),
          );
        },
      ),
      body: BlocBuilder<SessionsListCubit, SessionsListState>(
        builder: (ctx, state) {
          switch (state.status) {
            case SessionsListStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case SessionsListStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage ?? 'Couldn\'t load sessions.'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => ctx.read<SessionsListCubit>().load(),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              );
            case SessionsListStatus.empty:
              return _EmptyState(filter: state.statusFilter);
            case SessionsListStatus.loaded:
              return RefreshIndicator(
                onRefresh: () => ctx.read<SessionsListCubit>().load(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.sessions.length,
                  itemBuilder: (lvCtx, i) => _SessionCard(session: state.sessions[i]),
                ),
              );
          }
        },
      ),
    );
  }

  Future<void> _openCreateSheet(BuildContext context) async {
    final cubit = context.read<SessionsListCubit>();
    final created = await showModalBottomSheet<GameSession?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetCtx) => _CreateSessionSheet(parentContext: context),
    );
    if (created != null) {
      // Take the GM straight to the detail so they can assign characters.
      if (context.mounted) {
        await Navigator.of(context).pushNamed(
          AppRoutes.sessionDetail,
          arguments: created.id,
        );
        await cubit.load();
      }
    }
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final isActive = session.status == 'active';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        title: Text(session.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (session.description != null && session.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  session.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                Chip(
                  label: Text('${session.dpCount} DP'),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(
                    '${session.characterIds.length} '
                    '${session.characterIds.length == 1 ? "character" : "characters"}',
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            final cubit = context.read<SessionsListCubit>();
            if (action == 'archive') cubit.archive(session.id);
            if (action == 'unarchive') cubit.unarchive(session.id);
          },
          itemBuilder: (_) => [
            if (isActive)
              const PopupMenuItem(value: 'archive', child: Text('Archive'))
            else
              const PopupMenuItem(value: 'unarchive', child: Text('Unarchive')),
          ],
        ),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.sessionDetail,
          arguments: session.id,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final String filter;

  @override
  Widget build(BuildContext context) {
    final isActive = filter == 'active';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.casino_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              isActive ? 'No active sessions yet' : 'No archived sessions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              isActive
                  ? 'Create one with the + button to start tracking DP.'
                  : 'Sessions you archive land here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateSessionSheet extends StatefulWidget {
  const _CreateSessionSheet({required this.parentContext});

  /// We grab the parent's BlocProvider context so the create call lands
  /// on the same `SessionsListCubit` instance the page already wired
  /// up — the sheet itself is mounted by `showModalBottomSheet` and
  /// has a separate ancestor.
  final BuildContext parentContext;

  @override
  State<_CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends State<_CreateSessionSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('New session', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          TextField(
            controller: _nameController,
            maxLength: 80,
            decoration: const InputDecoration(
              labelText: 'Session name',
              hintText: 'e.g. Crimson Run',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _busy ? null : _onCreate,
                child: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = getIt<SessionRepository>();
      final result = await repo.create(
        name: name,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(result);
    } on Object catch (e) {
      setState(() {
        _busy = false;
        _error = e.toString();
      });
    }
  }
}
