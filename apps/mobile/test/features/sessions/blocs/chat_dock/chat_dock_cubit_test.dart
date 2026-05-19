import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/me/domain/me_profile.dart';
import 'package:coriolis_companion/features/me/domain/me_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat_dock/chat_dock_cubit.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat_dock/chat_dock_state.dart';

class _MockMeRepository extends Mock implements MeRepository {}

const _kDebounce = Duration(milliseconds: 1);

ChatDockCubit _buildCubit(_MockMeRepository repo) => ChatDockCubit(
      repository: repo,
      debounceDuration: _kDebounce,
    );

MeProfile _profile({bool chatDockedCollapsed = false}) => MeProfile(
      id: 'u1',
      email: 'test@example.com',
      chatDockedCollapsed: chatDockedCollapsed,
    );

void main() {
  late _MockMeRepository repo;

  setUp(() {
    repo = _MockMeRepository();
  });

  group('ChatDockCubit', () {
    group('initial state', () {
      test('starts with isLoading: true and collapsed: false', () {
        final cubit = _buildCubit(repo);
        expect(cubit.state, const ChatDockState(isLoading: true, collapsed: false));
        cubit.close();
      });
    });

    group('hydrate', () {
      blocTest<ChatDockCubit, ChatDockState>(
        'emits loading then collapsed=false when server returns false',
        build: () {
          when(() => repo.getMe())
              .thenAnswer((_) async => _profile(chatDockedCollapsed: false));
          return _buildCubit(repo);
        },
        act: (cubit) => cubit.hydrate(),
        expect: () => [
          const ChatDockState(isLoading: true, collapsed: false),
          const ChatDockState(isLoading: false, collapsed: false),
        ],
      );

      blocTest<ChatDockCubit, ChatDockState>(
        'emits collapsed=true when server returns true',
        build: () {
          when(() => repo.getMe())
              .thenAnswer((_) async => _profile(chatDockedCollapsed: true));
          return _buildCubit(repo);
        },
        act: (cubit) => cubit.hydrate(),
        expect: () => [
          const ChatDockState(isLoading: true, collapsed: false),
          const ChatDockState(isLoading: false, collapsed: true),
        ],
      );

      blocTest<ChatDockCubit, ChatDockState>(
        'defaults to collapsed=false when getMe fails (offline-safe hydrate)',
        build: () {
          when(() => repo.getMe()).thenThrow(Exception('network error'));
          return _buildCubit(repo);
        },
        act: (cubit) => cubit.hydrate(),
        expect: () => [
          const ChatDockState(isLoading: true, collapsed: false),
          const ChatDockState(isLoading: false, collapsed: false),
        ],
        verify: (_) => verify(() => repo.getMe()).called(1),
      );
    });

    group('toggle + debounced write', () {
      blocTest<ChatDockCubit, ChatDockState>(
        'flips collapsed optimistically on first toggle',
        build: () {
          when(() => repo.getMe())
              .thenAnswer((_) async => _profile(chatDockedCollapsed: false));
          when(() => repo.patchMe(chatDockedCollapsed: any(named: 'chatDockedCollapsed')))
              .thenAnswer((_) async => _profile(chatDockedCollapsed: true));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.hydrate();
          cubit.toggle();
          await Future<void>.delayed(const Duration(milliseconds: 10));
        },
        verify: (cubit) {
          expect(cubit.state.collapsed, isTrue);
          verify(() => repo.patchMe(chatDockedCollapsed: true)).called(1);
        },
      );

      test(
          'rapid toggles coalesce — patchMe called once with the final value',
          () {
        fakeAsync((clock) {
          when(() => repo.getMe())
              .thenAnswer((_) async => _profile(chatDockedCollapsed: false));
          when(() =>
                  repo.patchMe(chatDockedCollapsed: any(named: 'chatDockedCollapsed')))
              .thenAnswer((_) async => _profile());

          final cubit = _buildCubit(repo);

          // Simulate rapid toggling (5 times).
          cubit.toggle(); // false → true
          cubit.toggle(); // true → false
          cubit.toggle(); // false → true
          cubit.toggle(); // true → false
          cubit.toggle(); // false → true

          // Advance past debounce (1ms in tests).
          clock.elapse(const Duration(milliseconds: 10));

          // Only one PATCH should be sent with the final value (true).
          verify(() => repo.patchMe(chatDockedCollapsed: true)).called(1);
          verifyNever(() => repo.patchMe(chatDockedCollapsed: false));
          cubit.close();
        });
      });

      blocTest<ChatDockCubit, ChatDockState>(
        'offline-safe toggle — user-facing state stays updated even when PATCH fails',
        build: () {
          when(() => repo.getMe())
              .thenAnswer((_) async => _profile(chatDockedCollapsed: false));
          when(() =>
                  repo.patchMe(chatDockedCollapsed: any(named: 'chatDockedCollapsed')))
              .thenThrow(Exception('network error'));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.hydrate();
          cubit.toggle();
          await Future<void>.delayed(const Duration(milliseconds: 10));
        },
        verify: (cubit) {
          // PATCH failed but user-facing state still shows collapsed.
          expect(cubit.state.collapsed, isTrue);
        },
      );
    });
  });
}
