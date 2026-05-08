import 'package:equatable/equatable.dart';

import 'package:app_mobile/features/characters/domain/character.dart';

/// Save-cycle status for the auto-save indicator.
enum CharacterSheetSaveStatus { idle, saving, saved, error }

/// State emitted by [CharacterSheetCubit].
class CharacterSheetState extends Equatable {
  const CharacterSheetState({
    this.isLoading = true,
    this.character,
    this.saveStatus = CharacterSheetSaveStatus.idle,
    this.errorMessage,
    this.saveErrorMessage,
  });

  final bool isLoading;
  final Character? character;
  final CharacterSheetSaveStatus saveStatus;

  /// Load-level error (e.g. 404 on initial GET).
  final String? errorMessage;

  /// Save-level error (e.g. network failure on PATCH).
  final String? saveErrorMessage;

  bool get isSaving => saveStatus == CharacterSheetSaveStatus.saving;
  bool get hasSaved => saveStatus == CharacterSheetSaveStatus.saved;
  bool get hasSaveError => saveStatus == CharacterSheetSaveStatus.error;

  CharacterSheetState copyWith({
    bool? isLoading,
    Character? character,
    CharacterSheetSaveStatus? saveStatus,
    String? errorMessage,
    String? saveErrorMessage,
  }) {
    return CharacterSheetState(
      isLoading: isLoading ?? this.isLoading,
      character: character ?? this.character,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage,
      saveErrorMessage: saveErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        character,
        saveStatus,
        errorMessage,
        saveErrorMessage,
      ];
}
