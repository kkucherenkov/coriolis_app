import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_mobile/features/characters/domain/character.dart';
import 'package:app_mobile/features/characters/domain/character_repository.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_state.dart';

/// Manages the character sheet screen state.
///
/// Debounce strategy: a [Timer] is cancelled and restarted on each edit call.
/// After 500ms of inactivity the pending patch is sent to the repository.
/// On success the `saved` status resets to `idle` after 1500ms (mirroring web).
///
/// The cubit is registered as a factory in DI; each detail page gets a fresh
/// instance. `close()` cancels any in-flight debounce timer.
class CharacterSheetCubit extends Cubit<CharacterSheetState> {
  CharacterSheetCubit({
    required CharacterRepository repository,
    Duration debounceDuration = const Duration(milliseconds: 500),
    Duration savedResetDuration = const Duration(milliseconds: 1500),
  })  : _repository = repository,
        _debounceDuration = debounceDuration,
        _savedResetDuration = savedResetDuration,
        super(const CharacterSheetState());

  final CharacterRepository _repository;
  final Duration _debounceDuration;
  final Duration _savedResetDuration;

  Timer? _debounceTimer;
  Timer? _savedResetTimer;

  // ── Load ─────────────────────────────────────────────────────────────────

  /// Load the character identified by [id]. Emits `isLoading=true` first.
  Future<void> load(String id) async {
    emit(const CharacterSheetState(isLoading: true));
    try {
      final character = await _repository.get(id);
      emit(CharacterSheetState(isLoading: false, character: character));
    } on Object catch (e) {
      emit(CharacterSheetState(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ── Edits (debounced) ────────────────────────────────────────────────────

  /// Debounced name update. The patch fires 500ms after the last call.
  void updateName(String value) {
    final current = state.character;
    if (current == null) return;
    // Optimistically update local state so the field stays responsive.
    emit(state.copyWith(character: current.copyWith(name: value)));
    _schedulePatch(current.id, name: value);
  }

  /// Debounced concept update. The patch fires 500ms after the last call.
  void updateConcept(String value) {
    final current = state.character;
    if (current == null) return;
    emit(state.copyWith(character: current.copyWith(concept: value)));
    _schedulePatch(current.id, concept: value);
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  /// Permanently deletes the current character. Emits `saving` while in-flight.
  Future<void> deleteCharacter() async {
    final id = state.character?.id;
    if (id == null) return;
    emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.saving));
    try {
      await _repository.delete(id);
      // Caller navigates away; no further state needed.
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: CharacterSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
    }
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  /// Snapshot the intended patch fields and (re)start the debounce timer.
  ///
  /// We capture the values at the time of the call so that if the user types
  /// quickly we always send the latest name *and* concept together, not a
  /// stale partial patch.
  String? _pendingName;
  String? _pendingConcept;

  void _schedulePatch(String id, {String? name, String? concept}) {
    if (name != null) _pendingName = name;
    if (concept != null) _pendingConcept = concept;

    _debounceTimer?.cancel();
    _savedResetTimer?.cancel();

    _debounceTimer = Timer(_debounceDuration, () async {
      final pName = _pendingName;
      final pConcept = _pendingConcept;
      _pendingName = null;
      _pendingConcept = null;

      emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.saving));
      try {
        final updated = await _repository.update(
          id,
          name: pName,
          concept: pConcept,
        );
        emit(state.copyWith(
          character: updated,
          saveStatus: CharacterSheetSaveStatus.saved,
        ));
        _savedResetTimer = Timer(_savedResetDuration, () {
          if (!isClosed) {
            emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.idle));
          }
        });
      } on Object catch (e) {
        emit(state.copyWith(
          saveStatus: CharacterSheetSaveStatus.error,
          saveErrorMessage: e.toString(),
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _savedResetTimer?.cancel();
    return super.close();
  }
}
