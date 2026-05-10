import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';

/// Manages the six-step character creation wizard.
///
/// ## Draft persistence contract
///
/// - `start({id: null})` — creates a new `{ name: 'Untitled', status: draft }` via
///   [CharacterRepository.create] and stores the returned id. The caller should
///   replace the route to `/characters/new?id=<id>` so refreshing resumes.
///
/// - `start({id: <existing>})` — loads the character; if it is not a draft or
///   not owned the cubit emits an error state.
///
/// - `next()` / `back()` — patch the current step's data before advancing.
///
/// - `forge()` — PATCH `status: active` (via name + concept field presence)
///   then the caller navigates to the character sheet.
///
/// Each step advance calls [CharacterRepository.update] with the accumulated
/// [WizardDraft] fields so the server always has the latest draft.
class CharacterWizardCubit extends Cubit<CharacterWizardState> {
  CharacterWizardCubit({required CharacterRepository repository})
      : _repository = repository,
        super(const CharacterWizardState());

  final CharacterRepository _repository;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Initialise the wizard.
  ///
  /// Pass [id] to resume an existing draft, or omit to create a fresh one.
  Future<String?> start({String? id}) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      if (id != null) {
        // Resume flow: load existing draft.
        final character = await _repository.get(id);
        // If the character has no draft status field we treat any character
        // that can be fetched as resumable (spec v0.6.0 exposes status
        // through the concept field convention until the status field lands
        // in a future migration).
        final draft = _draftFromCharacter(character);
        emit(state.copyWith(
          isLoading: false,
          character: character,
          draft: draft,
          saveStatus: WizardSaveStatus.idle,
        ));
        return null; // id already known to caller
      } else {
        // New flow: create a placeholder draft.
        final character =
            await _repository.create(name: 'Untitled', status: 'draft');
        emit(state.copyWith(
          isLoading: false,
          character: character,
          saveStatus: WizardSaveStatus.idle,
        ));
        return character.id;
      }
    } on Object catch (e) {
      emit(state.copyWith(
        isLoading: false,
        saveStatus: WizardSaveStatus.error,
        lastError: e.toString(),
      ));
      return null;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  /// Advance to the next step, persisting the current step's data first.
  ///
  /// Returns `true` on success; `false` on save failure (stays on current step).
  Future<bool> next() async {
    if (state.step >= 6) return false;
    final saved = await _persistCurrentStep();
    if (!saved) return false;
    emit(state.copyWith(step: state.step + 1, saveStatus: WizardSaveStatus.idle));
    return true;
  }

  /// Go back one step without saving (draft fields are already local).
  void back() {
    if (state.step <= 1) return;
    emit(state.copyWith(step: state.step - 1, saveStatus: WizardSaveStatus.idle));
  }

  // ── Step 1 — Concept ──────────────────────────────────────────────────────

  void updateName(String value) =>
      emit(state.copyWith(draft: state.draft.copyWith(name: value)));

  void updateConcept(String value) =>
      emit(state.copyWith(draft: state.draft.copyWith(concept: value)));

  // ── Step 2 — People & Background ─────────────────────────────────────────

  void updateOrigin(String value) =>
      emit(state.copyWith(draft: state.draft.copyWith(origin: value)));

  void updateUpbringing(String value) =>
      emit(state.copyWith(draft: state.draft.copyWith(upbringing: value)));

  void updateAge(int value) =>
      emit(state.copyWith(draft: state.draft.copyWith(age: value)));

  // ── Step 3 — Icon ─────────────────────────────────────────────────────────

  void selectIcon(CoriolisIcon icon) =>
      emit(state.copyWith(draft: state.draft.copyWith(selectedIcon: icon)));

  // ── Step 4 — Attributes ───────────────────────────────────────────────────

  static const int _attrPointsTotal = 13;
  static const int _attrMin = 2;
  static const int _attrMax = 5;

  void updateAttribute(String key, int delta) {
    final d = state.draft;
    final current = switch (key) {
      'strength' => d.strength ?? 2,
      'agility' => d.agility ?? 2,
      'wits' => d.wits ?? 2,
      'empathy' => d.empathy ?? 2,
      _ => 2,
    };
    final newValue = (current + delta).clamp(_attrMin, _attrMax);
    final newDraft = switch (key) {
      'strength' => d.copyWith(strength: newValue),
      'agility' => d.copyWith(agility: newValue),
      'wits' => d.copyWith(wits: newValue),
      'empathy' => d.copyWith(empathy: newValue),
      _ => d,
    };
    // Guard the point pool: only allow the change if total ≤ budget.
    if (delta > 0 && newDraft.attributePointsSpent > _attrPointsTotal) return;
    emit(state.copyWith(draft: newDraft));
  }

  // ── Step 5 — Skills ───────────────────────────────────────────────────────

  /// ST3001 ch.2 table 2.4 — single skill-point pool sized by upbringing.
  static const Map<String, int> _skillBudget = {
    'plebeian': 8,
    'stationary': 10,
    'aristocrat': 12,
  };

  /// At creation, key skills (per concept) cap at 3, every other skill
  /// caps at 1. ST3001 ch.2.
  static const int _skillCreationKeyMax = 3;
  static const int _skillCreationNonKeyMax = 1;
  static const int _skillMin = 0;

  /// Concept → key skill keys. Mirrors `CONCEPT_KEYS` in the backend
  /// `apps/backend/src/modules/rules-engine/rules-engine.ts`.
  static const Map<String, Set<String>> _conceptKeySkills = {
    'artist': {'manipulation', 'culture', 'dexterity', 'observation', 'infiltration'},
    'networker': {'dataDjinn', 'culture', 'manipulation', 'observation', 'infiltration'},
    'fugitive': {'meleeCombat', 'infiltration', 'culture', 'mysticPowers', 'manipulation'},
    'negotiator': {'manipulation', 'culture', 'observation', 'command', 'infiltration'},
    'operative': {'meleeCombat', 'rangedCombat', 'infiltration', 'observation', 'manipulation'},
    'pilot': {'pilot', 'rangedCombat', 'technology', 'observation', 'dataDjinn'},
    'pioneer': {'survival', 'observation', 'technology', 'infiltration', 'science'},
    'preacher': {'culture', 'mysticPowers', 'manipulation', 'command', 'observation'},
    'scientist': {'science', 'culture', 'technology', 'medicurgy', 'dataDjinn'},
    'sailor': {'meleeCombat', 'force', 'technology', 'observation', 'pilot'},
    'soldier': {'rangedCombat', 'meleeCombat', 'force', 'command', 'observation'},
  };

  /// Default budget when [WizardDraft.upbringing] is not yet set.
  static const int _defaultSkillBudget = 10; // stationary

  int _skillBudgetFor(String? upbringing) =>
      _skillBudget[upbringing] ?? _defaultSkillBudget;

  int _maxRankFor(String key, String? concept) {
    final keys = _conceptKeySkills[concept] ?? const <String>{};
    return keys.contains(key) ? _skillCreationKeyMax : _skillCreationNonKeyMax;
  }

  void updateSkill(String key, int delta) {
    final d = state.draft;
    final maxVal = _maxRankFor(key, d.concept);
    final current = _skillValue(d, key);
    final newValue = (current + delta).clamp(_skillMin, maxVal);
    final newDraft = _withSkill(d, key, newValue);
    if (delta > 0 && newDraft.skillPointsSpent > _skillBudgetFor(d.upbringing)) {
      return;
    }
    emit(state.copyWith(draft: newDraft));
  }

  static int _skillValue(WizardDraft d, String key) => switch (key) {
        'dexterity' => d.dexterity ?? 0,
        'force' => d.force ?? 0,
        'infiltration' => d.infiltration ?? 0,
        'manipulation' => d.manipulation ?? 0,
        'meleeCombat' => d.meleeCombat ?? 0,
        'observation' => d.observation ?? 0,
        'rangedCombat' => d.rangedCombat ?? 0,
        'survival' => d.survival ?? 0,
        'command' => d.command ?? 0,
        'culture' => d.culture ?? 0,
        'dataDjinn' => d.dataDjinn ?? 0,
        'medicurgy' => d.medicurgy ?? 0,
        'mysticPowers' => d.mysticPowers ?? 0,
        'pilot' => d.pilot ?? 0,
        'science' => d.science ?? 0,
        'technology' => d.technology ?? 0,
        _ => 0,
      };

  static WizardDraft _withSkill(WizardDraft d, String key, int value) =>
      switch (key) {
        'dexterity' => d.copyWith(dexterity: value),
        'force' => d.copyWith(force: value),
        'infiltration' => d.copyWith(infiltration: value),
        'manipulation' => d.copyWith(manipulation: value),
        'meleeCombat' => d.copyWith(meleeCombat: value),
        'observation' => d.copyWith(observation: value),
        'rangedCombat' => d.copyWith(rangedCombat: value),
        'survival' => d.copyWith(survival: value),
        'command' => d.copyWith(command: value),
        'culture' => d.copyWith(culture: value),
        'dataDjinn' => d.copyWith(dataDjinn: value),
        'medicurgy' => d.copyWith(medicurgy: value),
        'mysticPowers' => d.copyWith(mysticPowers: value),
        'pilot' => d.copyWith(pilot: value),
        'science' => d.copyWith(science: value),
        'technology' => d.copyWith(technology: value),
        _ => d,
      };

  // ── Step 6 — Talents ──────────────────────────────────────────────────────

  void addPendingTalent(PendingTalent talent) {
    final current = List<PendingTalent>.from(state.draft.pendingTalents ?? []);
    if (current.length >= 3) return; // cap at 3 as per spec
    current.add(talent);
    emit(state.copyWith(draft: state.draft.copyWith(pendingTalents: current)));
  }

  void removePendingTalent(int index) {
    final current = List<PendingTalent>.from(state.draft.pendingTalents ?? []);
    if (index < 0 || index >= current.length) return;
    current.removeAt(index);
    emit(state.copyWith(draft: state.draft.copyWith(pendingTalents: current)));
  }

  // ── Forge ─────────────────────────────────────────────────────────────────

  /// Persist all remaining data and activate the character.
  ///
  /// Calls [CharacterRepository.update] with full draft data and
  /// `status: 'active'` to forge the draft into a playable character.
  /// Pending talents are then committed via dedicated repository calls.
  ///
  /// Returns the activated [Character] on success, or null on failure.
  Future<Character?> forge() async {
    final id = state.character?.id;
    if (id == null) return null;

    emit(state.copyWith(saveStatus: WizardSaveStatus.saving, clearError: true));
    try {
      // Persist all accumulated draft data.
      final d = state.draft;
      Character updated = await _repository.update(
        id,
        name: d.name?.trim().isEmpty == true ? 'Untitled' : d.name,
        concept: d.concept,
        attributes: CharacterAttributes(
          strength: d.strength ?? 2,
          agility: d.agility ?? 2,
          wits: d.wits ?? 2,
          empathy: d.empathy ?? 2,
        ),
        skills: CharacterSkills(
          dexterity: d.dexterity ?? 0,
          force: d.force ?? 0,
          infiltration: d.infiltration ?? 0,
          manipulation: d.manipulation ?? 0,
          meleeCombat: d.meleeCombat ?? 0,
          observation: d.observation ?? 0,
          rangedCombat: d.rangedCombat ?? 0,
          survival: d.survival ?? 0,
          command: d.command ?? 0,
          culture: d.culture ?? 0,
          dataDjinn: d.dataDjinn ?? 0,
          medicurgy: d.medicurgy ?? 0,
          mysticPowers: d.mysticPowers ?? 0,
          pilot: d.pilot ?? 0,
          science: d.science ?? 0,
          technology: d.technology ?? 0,
        ),
        status: 'active',
      );

      // Persist pending talents via discrete repository calls.
      for (final t in (d.pendingTalents ?? <PendingTalent>[])) {
        await _repository.addTalent(
          id,
          name: t.name,
          description: t.description,
        );
      }

      // Re-fetch to pick up any talent changes.
      updated = await _repository.get(id);

      emit(state.copyWith(
        character: updated,
        saveStatus: WizardSaveStatus.saved,
      ));
      return updated;
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: WizardSaveStatus.error,
        lastError: e.toString(),
      ));
      return null;
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  /// Persist the current step's local draft changes to the repository.
  ///
  /// Only sends the fields that belong to the current step so we don't
  /// overwrite later steps with defaults.
  Future<bool> _persistCurrentStep() async {
    final id = state.character?.id;
    if (id == null) return false;

    emit(state.copyWith(saveStatus: WizardSaveStatus.saving, clearError: true));
    try {
      final d = state.draft;
      switch (state.step) {
        case 1:
          await _repository.update(
            id,
            name: d.name?.trim().isEmpty == true ? 'Untitled' : d.name,
            concept: d.concept,
          );
        case 2:
          // origin / upbringing stored in concept until spec adds explicit fields.
          final conceptParts = [
            if (d.origin != null) 'origin:${d.origin}',
            if (d.upbringing != null) 'upbringing:${d.upbringing}',
            if (d.age != null) 'age:${d.age}',
          ].join('|');
          if (conceptParts.isNotEmpty) {
            await _repository.update(id, concept: conceptParts);
          }
        case 3:
          // icon stored in notes until spec adds explicit field.
          if (d.selectedIcon != null) {
            await _repository.update(id, notes: 'icon:${d.selectedIcon!.name}');
          }
        case 4:
          await _repository.update(
            id,
            attributes: CharacterAttributes(
              strength: d.strength ?? 2,
              agility: d.agility ?? 2,
              wits: d.wits ?? 2,
              empathy: d.empathy ?? 2,
            ),
          );
        case 5:
          await _repository.update(
            id,
            skills: CharacterSkills(
              dexterity: d.dexterity ?? 0,
              force: d.force ?? 0,
              infiltration: d.infiltration ?? 0,
              manipulation: d.manipulation ?? 0,
              meleeCombat: d.meleeCombat ?? 0,
              observation: d.observation ?? 0,
              rangedCombat: d.rangedCombat ?? 0,
              survival: d.survival ?? 0,
              command: d.command ?? 0,
              culture: d.culture ?? 0,
              dataDjinn: d.dataDjinn ?? 0,
              medicurgy: d.medicurgy ?? 0,
              mysticPowers: d.mysticPowers ?? 0,
              pilot: d.pilot ?? 0,
              science: d.science ?? 0,
              technology: d.technology ?? 0,
            ),
          );
        case 6:
          // Talents are committed on forge(); nothing to PATCH mid-step.
          break;
        default:
          break;
      }
      emit(state.copyWith(saveStatus: WizardSaveStatus.saved));
      return true;
    } on Object catch (e) {
      emit(state.copyWith(
        saveStatus: WizardSaveStatus.error,
        lastError: e.toString(),
      ));
      return false;
    }
  }

  /// Reconstruct local draft from an existing character (resume flow).
  static WizardDraft _draftFromCharacter(Character c) {
    return WizardDraft(
      name: c.name == 'Untitled' ? null : c.name,
      concept: c.concept,
      strength: c.attributes.strength,
      agility: c.attributes.agility,
      wits: c.attributes.wits,
      empathy: c.attributes.empathy,
      dexterity: c.skills.dexterity,
      force: c.skills.force,
      infiltration: c.skills.infiltration,
      manipulation: c.skills.manipulation,
      meleeCombat: c.skills.meleeCombat,
      observation: c.skills.observation,
      rangedCombat: c.skills.rangedCombat,
      survival: c.skills.survival,
      command: c.skills.command,
      culture: c.skills.culture,
      dataDjinn: c.skills.dataDjinn,
      medicurgy: c.skills.medicurgy,
      mysticPowers: c.skills.mysticPowers,
      pilot: c.skills.pilot,
      science: c.skills.science,
      technology: c.skills.technology,
      pendingTalents: c.talents
          .map((t) => PendingTalent(name: t.name, description: t.description))
          .toList(),
    );
  }
}
