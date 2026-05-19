import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';
import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_bloc.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_event.dart';
import 'package:coriolis_companion/features/sessions/domain/chat_presence_service.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_realtime_service.dart';
import 'package:coriolis_companion/features/sessions/presentation/widgets/chat/chat_panel.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Player session detail page with three bottom tabs:
/// 0 = Chat (most-touched — leftmost per design notes)
/// 1 = Encounter
/// 2 = Me
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
  int _selectedTab = 0;

  late final ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc(
      repository: GetIt.instance<ChatRepository>(),
      realtimeService: GetIt.instance<ChatRealtimeService>(),
      presenceService: GetIt.instance<ChatPresenceService>(),
    );
    _load();
  }

  @override
  void dispose() {
    _chatBloc.close();
    super.dispose();
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
        if (match != null) {
          _chatBloc.add(ChatHydrateRequested(
            gameSessionId: widget.gameSessionId,
            myMembershipId: match.membershipId,
          ));
        }
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

    return BlocProvider<ChatBloc>.value(
      value: _chatBloc,
      child: Scaffold(
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _selectedTab = index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              activeIcon: const Icon(Icons.chat_bubble),
              label: t.chat.tab.chat,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shield_outlined),
              activeIcon: const Icon(Icons.shield),
              label: t.chat.tab.encounter,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: t.chat.tab.me,
            ),
          ],
        ),
      ),
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

    switch (_selectedTab) {
      case 0:
        return ChatPanel(
          availableMembers: const [], // TODO: wire real member list.
          myMembershipId: _membership!.membershipId,
        );
      case 1:
        return const Center(
          child: Text('Encounter coming in Stream D'),
        );
      case 2:
        return const Center(
          child: Text('Me tab coming soon'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
