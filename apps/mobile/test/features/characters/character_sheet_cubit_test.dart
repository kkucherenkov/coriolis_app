import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_mobile/features/characters/domain/character.dart';
import 'package:app_mobile/features/characters/domain/character_repository.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_state.dart';

class _MockCharacterRepository extends Mock implements CharacterRepository {}

final _now = DateTime(2026, 5, 8);

final _character = Character(
  id: 'c1',
  ownerId: 'u1',
  name: 'Kira Sol',
  concept: 'Pilot',
  createdAt: _now,
  updatedAt: _now,
);

final _updated = Character(
  id: 'c1',
  ownerId: 'u1',
  name: 'Kira Solaris',
  concept: 'Pilot',
  createdAt: _now,
  updatedAt: _now,
);

CharacterSheetCubit _buildCubit(_MockCharacterRepository repo) =>
    CharacterSheetCubit(
      repository: repo,
      // Very short debounce for tests — avoids fake-async complexity.
      debounceDuration: const Duration(milliseconds: 1),
      savedResetDuration: const Duration(milliseconds: 1),
    );

void main() {
  late _MockCharacterRepository repo;

  setUp(() {
    repo = _MockCharacterRepository();
  });

  group('CharacterSheetCubit', () {
    group('load', () {
      blocTest<CharacterSheetCubit, CharacterSheetState>(
        'emits isLoading=true → loaded character on success',
        build: () {
          when(() => repo.get('c1')).thenAnswer((_) async => _character);
          return _buildCubit(repo);
        },
        act: (cubit) => cubit.load('c1'),
        expect: () => [
          const CharacterSheetState(isLoading: true),
          CharacterSheetState(isLoading: false, character: _character),
        ],
      );

      blocTest<CharacterSheetCubit, CharacterSheetState>(
        'emits error state when get throws',
        build: () {
          when(() => repo.get('c1')).thenThrow(Exception('not found'));
          return _buildCubit(repo);
        },
        act: (cubit) => cubit.load('c1'),
        expect: () => [
          const CharacterSheetState(isLoading: true),
          isA<CharacterSheetState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('updateName (debounced)', () {
      blocTest<CharacterSheetCubit, CharacterSheetState>(
        'emits optimistic update, then saving → saved → idle after patch',
        build: () {
          when(() => repo.get('c1')).thenAnswer((_) async => _character);
          when(() => repo.update('c1', name: 'Kira Solaris', concept: null))
              .thenAnswer((_) async => _updated);
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('c1');
          cubit.updateName('Kira Solaris');
          // Wait for debounce + saved reset timers.
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        expect: () => [
          const CharacterSheetState(isLoading: true),
          // loaded
          CharacterSheetState(isLoading: false, character: _character),
          // optimistic update
          CharacterSheetState(
            isLoading: false,
            character: _character.copyWith(name: 'Kira Solaris'),
          ),
          // saving
          CharacterSheetState(
            isLoading: false,
            character: _character.copyWith(name: 'Kira Solaris'),
            saveStatus: CharacterSheetSaveStatus.saving,
          ),
          // saved (server response)
          CharacterSheetState(
            isLoading: false,
            character: _updated,
            saveStatus: CharacterSheetSaveStatus.saved,
          ),
          // idle after reset timer
          CharacterSheetState(
            isLoading: false,
            character: _updated,
            saveStatus: CharacterSheetSaveStatus.idle,
          ),
        ],
      );

      blocTest<CharacterSheetCubit, CharacterSheetState>(
        'emits error save status when patch throws',
        build: () {
          when(() => repo.get('c1')).thenAnswer((_) async => _character);
          when(() => repo.update('c1', name: any(named: 'name'), concept: any(named: 'concept')))
              .thenThrow(Exception('server error'));
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('c1');
          cubit.updateName('Kira Solaris');
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        verify: (cubit) {
          expect(cubit.state.saveStatus, CharacterSheetSaveStatus.error);
        },
      );
    });

    group('deleteCharacter', () {
      blocTest<CharacterSheetCubit, CharacterSheetState>(
        'emits saving while deleting',
        build: () {
          when(() => repo.get('c1')).thenAnswer((_) async => _character);
          when(() => repo.delete('c1')).thenAnswer((_) async {});
          return _buildCubit(repo);
        },
        act: (cubit) async {
          await cubit.load('c1');
          await cubit.deleteCharacter();
        },
        verify: (cubit) {
          // After successful delete the caller navigates away; cubit stays with
          // whatever was last emitted before close. Just confirm no error.
          expect(cubit.state.saveStatus, isNot(CharacterSheetSaveStatus.error));
        },
      );
    });
  });
}
