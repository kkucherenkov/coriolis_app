import 'package:equatable/equatable.dart';

import 'package:app_mobile/features/characters/domain/character_summary.dart';

/// Status of the characters list screen.
enum CharactersListStatus { loading, empty, loaded, error }

/// State emitted by [CharactersListCubit].
///
/// Manual immutable — no `freezed` needed; the shape is simple and matches
/// the auth state pattern already in use.
class CharactersListState extends Equatable {
  const CharactersListState({
    this.status = CharactersListStatus.loading,
    this.characters = const [],
    this.errorMessage,
  });

  final CharactersListStatus status;
  final List<CharacterSummary> characters;
  final String? errorMessage;

  bool get isLoading => status == CharactersListStatus.loading;
  bool get isEmpty => status == CharactersListStatus.empty;
  bool get isLoaded => status == CharactersListStatus.loaded;
  bool get isError => status == CharactersListStatus.error;

  CharactersListState copyWith({
    CharactersListStatus? status,
    List<CharacterSummary>? characters,
    String? errorMessage,
  }) {
    return CharactersListState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, characters, errorMessage];
}
