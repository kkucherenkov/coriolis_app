import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_mobile/features/characters/domain/character_repository.dart';
import 'package:app_mobile/features/characters/domain/character_summary.dart';
import 'package:app_mobile/features/characters/presentation/blocs/characters_list/characters_list_cubit.dart';
import 'package:app_mobile/features/characters/presentation/blocs/characters_list/characters_list_state.dart';

class _MockCharacterRepository extends Mock implements CharacterRepository {}

const _summaries = [
  CharacterSummary(id: 'c1', name: 'Kira Sol', concept: 'Pilot'),
  CharacterSummary(id: 'c2', name: 'Marak', concept: null),
];

void main() {
  late _MockCharacterRepository repo;

  setUp(() {
    repo = _MockCharacterRepository();
  });

  group('CharactersListCubit', () {
    group('init', () {
      blocTest<CharactersListCubit, CharactersListState>(
        'emits loading → loaded when repository returns items',
        build: () {
          when(() => repo.list(limit: 20))
              .thenAnswer((_) async => _summaries);
          return CharactersListCubit(repo);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          const CharactersListState(status: CharactersListStatus.loading),
          const CharactersListState(
            status: CharactersListStatus.loaded,
            characters: _summaries,
          ),
        ],
      );

      blocTest<CharactersListCubit, CharactersListState>(
        'emits loading → empty when repository returns empty list',
        build: () {
          when(() => repo.list(limit: 20)).thenAnswer((_) async => []);
          return CharactersListCubit(repo);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          const CharactersListState(status: CharactersListStatus.loading),
          const CharactersListState(
            status: CharactersListStatus.empty,
            characters: [],
          ),
        ],
      );

      blocTest<CharactersListCubit, CharactersListState>(
        'emits loading → error when repository throws',
        build: () {
          when(() => repo.list(limit: 20)).thenThrow(Exception('network'));
          return CharactersListCubit(repo);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          const CharactersListState(status: CharactersListStatus.loading),
          isA<CharactersListState>()
              .having((s) => s.status, 'status', CharactersListStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('refresh', () {
      blocTest<CharactersListCubit, CharactersListState>(
        'reloads the list and emits loaded state',
        build: () {
          when(() => repo.list(limit: 20))
              .thenAnswer((_) async => _summaries);
          return CharactersListCubit(repo);
        },
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const CharactersListState(status: CharactersListStatus.loading),
          const CharactersListState(
            status: CharactersListStatus.loaded,
            characters: _summaries,
          ),
        ],
      );
    });
  });
}
