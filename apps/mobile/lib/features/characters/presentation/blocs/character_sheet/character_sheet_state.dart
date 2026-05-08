import 'package:equatable/equatable.dart';

import 'package:app_mobile/features/characters/domain/character.dart';

/// Save-cycle status mirroring the web `useAutoSave` enum.
enum CharacterSheetSaveStatus { idle, saving, saved, error }

/// Active tab on the character sheet.
enum CharacterSheetTab { stats, gear, talents, notes }

/// State emitted by [CharacterSheetCubit].
class CharacterSheetState extends Equatable {
  const CharacterSheetState({
    this.isLoading = true,
    this.character,
    this.saveStatus = CharacterSheetSaveStatus.idle,
    this.activeTab = CharacterSheetTab.stats,
    this.errorMessage,
    this.saveErrorMessage,
  });

  final bool isLoading;
  final Character? character;
  final CharacterSheetSaveStatus saveStatus;
  final CharacterSheetTab activeTab;

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
    CharacterSheetTab? activeTab,
    String? errorMessage,
    String? saveErrorMessage,
  }) {
    return CharacterSheetState(
      isLoading: isLoading ?? this.isLoading,
      character: character ?? this.character,
      saveStatus: saveStatus ?? this.saveStatus,
      activeTab: activeTab ?? this.activeTab,
      errorMessage: errorMessage,
      saveErrorMessage: saveErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        character,
        saveStatus,
        activeTab,
        errorMessage,
        saveErrorMessage,
      ];
}
