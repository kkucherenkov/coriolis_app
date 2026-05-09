import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_sheet/character_sheet_state.dart';

/// Manages the full character sheet screen state.
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

  // ── Pending patch fields (accumulated until the debounce fires) ──────────

  String? _pendingName;
  String? _pendingConcept;
  CharacterAttributes? _pendingAttributes;
  CharacterSkills? _pendingSkills;
  CharacterHp? _pendingHp;
  CharacterMp? _pendingMp;
  int? _pendingExperience;
  CharacterConditions? _pendingConditions;
  List<DomainCriticalInjury>? _pendingCriticalInjuries;
  String? _pendingNotes;

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

  // ── Identity edits ───────────────────────────────────────────────────────

  /// Debounced name update.
  void updateName(String value) {
    final current = state.character;
    if (current == null) return;
    emit(state.copyWith(character: current.copyWith(name: value)));
    _pendingName = value;
    _scheduleDebounce(current.id);
  }

  /// Debounced concept update.
  void updateConcept(String value) {
    final current = state.character;
    if (current == null) return;
    emit(state.copyWith(character: current.copyWith(concept: value)));
    _pendingConcept = value;
    _scheduleDebounce(current.id);
  }

  /// Debounced notes update.
  void updateNotes(String value) {
    final current = state.character;
    if (current == null) return;
    emit(state.copyWith(character: current.copyWith(notes: value)));
    _pendingNotes = value;
    _scheduleDebounce(current.id);
  }

  // ── Tab navigation ───────────────────────────────────────────────────────

  /// Switches the active tab without affecting any other state.
  void switchTab(CharacterSheetTab tab) {
    if (state.activeTab == tab) return;
    emit(state.copyWith(activeTab: tab));
  }

  // ── Attribute / Skill edits ──────────────────────────────────────────────

  /// Updates a single attribute by key name ('strength', 'agility', 'wits', 'empathy').
  /// Value is clamped to 1–5.
  void updateAttribute(String key, int value) {
    final current = state.character;
    if (current == null) return;
    final clamped = value.clamp(1, 5);
    final attrs = current.attributes;
    final updated = switch (key) {
      'strength' => attrs.copyWith(strength: clamped),
      'agility' => attrs.copyWith(agility: clamped),
      'wits' => attrs.copyWith(wits: clamped),
      'empathy' => attrs.copyWith(empathy: clamped),
      _ => attrs,
    };
    emit(state.copyWith(character: current.copyWith(attributes: updated)));
    _pendingAttributes = updated;
    _scheduleDebounce(current.id);
  }

  /// Updates a single skill by key name. Value is clamped to 0–5.
  void updateSkill(String key, int value) {
    final current = state.character;
    if (current == null) return;
    final clamped = value.clamp(0, 5);
    final skills = current.skills;
    final updated = switch (key) {
      'dexterity' => skills.copyWith(dexterity: clamped),
      'force' => skills.copyWith(force: clamped),
      'infiltration' => skills.copyWith(infiltration: clamped),
      'manipulation' => skills.copyWith(manipulation: clamped),
      'meleeCombat' => skills.copyWith(meleeCombat: clamped),
      'observation' => skills.copyWith(observation: clamped),
      'rangedCombat' => skills.copyWith(rangedCombat: clamped),
      'survival' => skills.copyWith(survival: clamped),
      'command' => skills.copyWith(command: clamped),
      'culture' => skills.copyWith(culture: clamped),
      'dataDjinn' => skills.copyWith(dataDjinn: clamped),
      'medicurgy' => skills.copyWith(medicurgy: clamped),
      'mysticPowers' => skills.copyWith(mysticPowers: clamped),
      'pilot' => skills.copyWith(pilot: clamped),
      'science' => skills.copyWith(science: clamped),
      'technology' => skills.copyWith(technology: clamped),
      _ => skills,
    };
    emit(state.copyWith(character: current.copyWith(skills: updated)));
    _pendingSkills = updated;
    _scheduleDebounce(current.id);
  }

  // ── Hero counters ────────────────────────────────────────────────────────

  /// Adjusts HP current by [delta], clamped to [0, max].
  void adjustHp(int delta) {
    final current = state.character;
    if (current == null) return;
    final next = (current.hp.current + delta).clamp(0, current.hp.max);
    final updated = current.hp.copyWith(current: next);
    emit(state.copyWith(character: current.copyWith(hp: updated)));
    _pendingHp = updated;
    _scheduleDebounce(current.id);
  }

  /// Adjusts MP current by [delta], clamped to [0, max].
  void adjustMp(int delta) {
    final current = state.character;
    if (current == null) return;
    final next = (current.mp.current + delta).clamp(0, current.mp.max);
    final updated = current.mp.copyWith(current: next);
    emit(state.copyWith(character: current.copyWith(mp: updated)));
    _pendingMp = updated;
    _scheduleDebounce(current.id);
  }

  // ── Conditions ───────────────────────────────────────────────────────────

  /// Toggles one of the four standard conditions.
  void toggleCondition(String key) {
    final current = state.character;
    if (current == null) return;
    final c = current.conditions;
    final updated = switch (key) {
      'exhausted' => c.copyWith(exhausted: !c.exhausted),
      'sleepless' => c.copyWith(sleepless: !c.sleepless),
      'thirsty' => c.copyWith(thirsty: !c.thirsty),
      'hungry' => c.copyWith(hungry: !c.hungry),
      _ => c,
    };
    emit(state.copyWith(character: current.copyWith(conditions: updated)));
    _pendingConditions = updated;
    _scheduleDebounce(current.id);
  }

  // ── Critical injuries ────────────────────────────────────────────────────

  /// Adds a critical injury with [name] (severity defaults to 'light').
  void addCriticalInjury(String name) {
    final current = state.character;
    if (current == null) return;
    final injury = DomainCriticalInjury(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      severity: 'light',
      effect: '',
      acquiredAt: DateTime.now(),
    );
    final updated = [...current.criticalInjuries, injury];
    emit(
        state.copyWith(character: current.copyWith(criticalInjuries: updated)));
    _pendingCriticalInjuries = updated;
    _scheduleDebounce(current.id);
  }

  /// Removes the critical injury at [index].
  void removeCriticalInjury(int index) {
    final current = state.character;
    if (current == null) return;
    final updated = [...current.criticalInjuries]..removeAt(index);
    emit(
        state.copyWith(character: current.copyWith(criticalInjuries: updated)));
    _pendingCriticalInjuries = updated;
    _scheduleDebounce(current.id);
  }

  // ── Talents ──────────────────────────────────────────────────────────────

  /// Adds a talent and immediately pushes to the repository (no debounce —
  /// nested-resource operations are discrete events, not keystrokes).
  Future<void> addTalent({
    required String name,
    required String description,
    int rank = 1,
  }) async {
    final current = state.character;
    if (current == null) return;
    emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.saving));
    try {
      final talent = await _repository.addTalent(
        current.id,
        name: name,
        description: description,
        rank: rank,
      );
      final updated = [...current.talents, talent];
      emit(state.copyWith(
        character: current.copyWith(talents: updated),
        saveStatus: CharacterSheetSaveStatus.saved,
      ));
      _startSavedResetTimer();
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: CharacterSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
    }
  }

  /// Updates an existing talent by [talentId].
  Future<void> updateTalent(
    String talentId, {
    String? name,
    String? description,
    int? rank,
  }) async {
    final current = state.character;
    if (current == null) return;
    emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.saving));
    try {
      final updated = await _repository.updateTalent(
        current.id,
        talentId,
        name: name,
        description: description,
        rank: rank,
      );
      final talents = current.talents
          .map((t) => t.id == talentId ? updated : t)
          .toList();
      emit(state.copyWith(
        character: current.copyWith(talents: talents),
        saveStatus: CharacterSheetSaveStatus.saved,
      ));
      _startSavedResetTimer();
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: CharacterSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
    }
  }

  /// Removes a talent by [talentId].
  Future<void> removeTalent(String talentId) async {
    final current = state.character;
    if (current == null) return;
    // Optimistic removal.
    final optimistic = current.talents.where((t) => t.id != talentId).toList();
    final previous = current;
    emit(state.copyWith(
      character: current.copyWith(talents: optimistic),
      saveStatus: CharacterSheetSaveStatus.saving,
    ));
    try {
      await _repository.removeTalent(current.id, talentId);
      emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.saved));
      _startSavedResetTimer();
    } on Object catch (e) {
      // Rollback.
      emit(state.copyWith(
        character: previous,
        saveStatus: CharacterSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
    }
  }

  // ── Inventory ────────────────────────────────────────────────────────────

  /// Adds an inventory item.
  Future<void> addItem(DomainItem draft) async {
    final current = state.character;
    if (current == null) return;
    emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.saving));
    try {
      final item = await _repository.addItem(current.id, draft);
      final updated = [...current.inventory, item];
      emit(state.copyWith(
        character: current.copyWith(inventory: updated),
        saveStatus: CharacterSheetSaveStatus.saved,
      ));
      _startSavedResetTimer();
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: CharacterSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
    }
  }

  /// Updates an inventory item by [itemId].
  Future<void> updateItem(String itemId, DomainItem patch) async {
    final current = state.character;
    if (current == null) return;
    emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.saving));
    try {
      final updated = await _repository.updateItem(current.id, itemId, patch);
      final inventory = current.inventory
          .map((i) => i.id == itemId ? updated : i)
          .toList();
      emit(state.copyWith(
        character: current.copyWith(inventory: inventory),
        saveStatus: CharacterSheetSaveStatus.saved,
      ));
      _startSavedResetTimer();
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: CharacterSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
    }
  }

  /// Removes an inventory item by [itemId]. Optimistic with rollback.
  Future<void> removeItem(String itemId) async {
    final current = state.character;
    if (current == null) return;
    final optimistic =
        current.inventory.where((i) => i.id != itemId).toList();
    final previous = current;
    emit(state.copyWith(
      character: current.copyWith(inventory: optimistic),
      saveStatus: CharacterSheetSaveStatus.saving,
    ));
    try {
      await _repository.removeItem(current.id, itemId);
      emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.saved));
      _startSavedResetTimer();
    } on Object catch (e) {
      emit(state.copyWith(
        character: previous,
        saveStatus: CharacterSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
    }
  }

  // ── Delete character ─────────────────────────────────────────────────────

  /// Permanently deletes the current character.
  Future<void> deleteCharacter() async {
    final id = state.character?.id;
    if (id == null) return;
    emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.saving));
    try {
      await _repository.delete(id);
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: CharacterSheetSaveStatus.error,
        saveErrorMessage: e.toString(),
      ));
    }
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  void _scheduleDebounce(String id) {
    _debounceTimer?.cancel();
    _savedResetTimer?.cancel();

    _debounceTimer = Timer(_debounceDuration, () async {
      // Snapshot and clear pending fields.
      final pName = _pendingName;
      final pConcept = _pendingConcept;
      final pAttrs = _pendingAttributes;
      final pSkills = _pendingSkills;
      final pHp = _pendingHp;
      final pMp = _pendingMp;
      final pExp = _pendingExperience;
      final pCond = _pendingConditions;
      final pCi = _pendingCriticalInjuries;
      final pNotes = _pendingNotes;
      _pendingName = null;
      _pendingConcept = null;
      _pendingAttributes = null;
      _pendingSkills = null;
      _pendingHp = null;
      _pendingMp = null;
      _pendingExperience = null;
      _pendingConditions = null;
      _pendingCriticalInjuries = null;
      _pendingNotes = null;

      emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.saving));
      try {
        final updated = await _repository.update(
          id,
          name: pName,
          concept: pConcept,
          attributes: pAttrs,
          skills: pSkills,
          hp: pHp,
          mp: pMp,
          experience: pExp,
          conditions: pCond,
          criticalInjuries: pCi,
          notes: pNotes,
        );
        emit(state.copyWith(
          character: updated,
          saveStatus: CharacterSheetSaveStatus.saved,
        ));
        _startSavedResetTimer();
      } on Object catch (e) {
        emit(state.copyWith(
          saveStatus: CharacterSheetSaveStatus.error,
          saveErrorMessage: e.toString(),
        ));
      }
    });
  }

  void _startSavedResetTimer() {
    _savedResetTimer?.cancel();
    _savedResetTimer = Timer(_savedResetDuration, () {
      if (!isClosed) {
        emit(state.copyWith(saveStatus: CharacterSheetSaveStatus.idle));
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
