import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/me/domain/me_profile.dart';
import 'package:coriolis_companion/features/me/domain/me_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_bloc.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_realtime_service.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat_dock/chat_dock_cubit.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat_dock/chat_dock_state.dart';
import 'package:coriolis_companion/features/sessions/presentation/widgets/chat/chat_panel.dart';
import 'package:coriolis_companion/features/sessions/domain/chat_presence_service.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockChatRepository extends Mock implements ChatRepository {}

class _MockChatRealtimeService extends Mock implements ChatRealtimeService {}

class _MockChatPresenceService extends Mock implements ChatPresenceService {}

/// A [ChatDockCubit] that can be pre-seeded without touching the network.
class _SeededChatDockCubit extends ChatDockCubit {
  _SeededChatDockCubit(ChatDockState seed, MeRepository repo)
      : super(repository: repo,
            debounceDuration: const Duration(milliseconds: 1)) {
    emit(seed);
  }

  @override
  Future<void> hydrate() async {}
}

void main() {
  late _MockMeRepository meRepo;
  late _MockChatRepository chatRepo;
  late _MockChatRealtimeService realtimeService;
  late _MockChatPresenceService presenceService;

  setUp(() {
    meRepo = _MockMeRepository();
    chatRepo = _MockChatRepository();
    realtimeService = _MockChatRealtimeService();
    presenceService = _MockChatPresenceService();
  });

  Widget _buildUnderTest({required ChatDockState dockState}) {
    final dockCubit = _SeededChatDockCubit(dockState, meRepo);
    final chatBloc = ChatBloc(
      repository: chatRepo,
      realtimeService: realtimeService,
      presenceService: presenceService,
    );

    return TranslationProvider(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ChatBloc>.value(value: chatBloc),
          BlocProvider<ChatDockCubit>.value(value: dockCubit),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BlocBuilder<ChatDockCubit, ChatDockState>(
              builder: (context, state) => ChatPanel(
                availableMembers: const [],
                myMembershipId: 'm-1',
                dockCollapsed: state.collapsed,
                onToggleDock: () => context.read<ChatDockCubit>().toggle(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('ChatPanel dock control', () {
    testWidgets(
      'shows collapse toggle bar when dockCollapsed is true',
      (tester) async {
        when(() => meRepo.getMe()).thenAnswer(
          (_) async => const MeProfile(
              id: 'u1', email: 'a@b.com', chatDockedCollapsed: true),
        );

        await tester.pumpWidget(
          _buildUnderTest(
            dockState: const ChatDockState(isLoading: false, collapsed: true),
          ),
        );
        await tester.pumpAndSettle();

        // The collapse-toggle bar is shown.
        expect(find.byKey(const Key('chat_dock_toggle')), findsOneWidget);
        // The message list is NOT rendered when collapsed.
        expect(find.byKey(const Key('message_list')), findsNothing);
      },
    );

    testWidgets(
      'shows collapse affordance inside panel when dockCollapsed is false',
      (tester) async {
        when(() => meRepo.getMe()).thenAnswer(
          (_) async => const MeProfile(
              id: 'u1', email: 'a@b.com', chatDockedCollapsed: false),
        );

        await tester.pumpWidget(
          _buildUnderTest(
            dockState: const ChatDockState(isLoading: false, collapsed: false),
          ),
        );
        await tester.pumpAndSettle();

        // The in-panel collapse toggle is visible.
        expect(find.byKey(const Key('chat_dock_collapse')), findsOneWidget);
        // The outer collapsed bar is NOT rendered.
        expect(find.byKey(const Key('chat_dock_toggle')), findsNothing);
      },
    );

    testWidgets(
      'tapping collapse toggle bar calls toggle on ChatDockCubit',
      (tester) async {
        when(() => meRepo.patchMe(chatDockedCollapsed: any(named: 'chatDockedCollapsed')))
            .thenAnswer(
          (_) async =>
              const MeProfile(id: 'u1', email: 'a@b.com'),
        );

        await tester.pumpWidget(
          _buildUnderTest(
            dockState: const ChatDockState(isLoading: false, collapsed: true),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the toggle bar → state flips to expanded.
        await tester.tap(find.byKey(const Key('chat_dock_toggle')));
        await tester.pumpAndSettle();

        // After toggle the outer bar is gone and the in-panel bar appears.
        expect(find.byKey(const Key('chat_dock_toggle')), findsNothing);
        expect(find.byKey(const Key('chat_dock_collapse')), findsOneWidget);
      },
    );
  });
}
