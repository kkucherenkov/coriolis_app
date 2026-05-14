import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';

/// Draft-data collected step-by-step before the character is activated.
///
/// All fields except [mutant] are nullable so the wizard can persist partial
/// progress without requiring every step to be complete. [mutant] defaults to
/// `false` to mirror the backend `CharacterCreate` default.
///
/// Domain semantics (post-T-WIZARD-MOBILE-DOMAIN-ALIGN, block 2026-05-15):
///
/// - [concept] is the **canonical Concept enum value** (e.g. `pilot`,
///   `scientist`), not a freeform phrase. The wizard's old free-text
///   "concept phrase" no longer round-trips to the API — the canonical
///   reorder block will add a dedicated Concept-picker step.
/// - [origin] is the **free-text** narrative description from
///   `Character.origin` (max 200 chars).
/// - [upbringing] is one of `plebeian | stationary | aristocrat`.
/// - [iconId] is one of the nine canonical kebab-case Icon ids
///   (`lady-of-tears | traveler | messenger | merchant | dancer | gambler |
///   judge | faceless-one | deckhand`).
/// - [role] is one of the canonical 33 Role enum values.
/// - [crewConcept] is one of the five crew archetypes.
/// - [mutantLineage] is one of `zirba | shingura | nerida`.
class WizardDraft extends Equatable {
  const WizardDraft({
    // Step 1 — Biography (name)
    this.name,
    // Step 2 — People & Background
    this.origin,
    this.upbringing,
    this.age,
    // Step 3 — Icon
    this.iconId,
    // Step 4 — Attributes
    this.strength,
    this.agility,
    this.wits,
    this.empathy,
    // Step 5 — Skills
    this.dexterity,
    this.force,
    this.infiltration,
    this.manipulation,
    this.meleeCombat,
    this.observation,
    this.rangedCombat,
    this.survival,
    this.command,
    this.culture,
    this.dataDjinn,
    this.medicurgy,
    this.mysticPowers,
    this.pilot,
    this.science,
    this.technology,
    // Step 6 — Talents
    this.pendingTalents,
    // Reorder-block additions (data plumbing only — UI lands in
    // T-WIZARD-MOBILE-REORDER):
    this.concept,
    this.role,
    this.crewConcept,
    this.mutant = false,
    this.mutantLineage,
  });

  // Step 1
  final String? name;
  // Step 2
  final String? origin;
  final String? upbringing;
  final int? age;
  // Step 3
  final String? iconId;
  // Step 4
  final int? strength;
  final int? agility;
  final int? wits;
  final int? empathy;
  // Step 5
  final int? dexterity;
  final int? force;
  final int? infiltration;
  final int? manipulation;
  final int? meleeCombat;
  final int? observation;
  final int? rangedCombat;
  final int? survival;
  final int? command;
  final int? culture;
  final int? dataDjinn;
  final int? medicurgy;
  final int? mysticPowers;
  final int? pilot;
  final int? science;
  final int? technology;
  // Step 6
  final List<PendingTalent>? pendingTalents;
  // Reorder-block additions
  final String? concept;
  final String? role;
  final String? crewConcept;
  final bool mutant;
  final String? mutantLineage;

  // ── Derived point-pool helpers ───────────────────────────────────────────

  /// Total attribute points allocated across the four attributes.
  int get attributePointsSpent =>
      (strength ?? 2) + (agility ?? 2) + (wits ?? 2) + (empathy ?? 2);

  /// Total skill points allocated across all 16 skills (single shared
  /// pool sized by upbringing — ST3001 ch.2 table 2.4).
  int get skillPointsSpent =>
      (dexterity ?? 0) +
      (force ?? 0) +
      (infiltration ?? 0) +
      (manipulation ?? 0) +
      (meleeCombat ?? 0) +
      (observation ?? 0) +
      (rangedCombat ?? 0) +
      (survival ?? 0) +
      (command ?? 0) +
      (culture ?? 0) +
      (dataDjinn ?? 0) +
      (medicurgy ?? 0) +
      (mysticPowers ?? 0) +
      (pilot ?? 0) +
      (science ?? 0) +
      (technology ?? 0);

  WizardDraft copyWith({
    String? name,
    String? origin,
    String? upbringing,
    int? age,
    String? iconId,
    int? strength,
    int? agility,
    int? wits,
    int? empathy,
    int? dexterity,
    int? force,
    int? infiltration,
    int? manipulation,
    int? meleeCombat,
    int? observation,
    int? rangedCombat,
    int? survival,
    int? command,
    int? culture,
    int? dataDjinn,
    int? medicurgy,
    int? mysticPowers,
    int? pilot,
    int? science,
    int? technology,
    List<PendingTalent>? pendingTalents,
    String? concept,
    String? role,
    String? crewConcept,
    bool? mutant,
    String? mutantLineage,
    bool clearMutantLineage = false,
  }) {
    return WizardDraft(
      name: name ?? this.name,
      origin: origin ?? this.origin,
      upbringing: upbringing ?? this.upbringing,
      age: age ?? this.age,
      iconId: iconId ?? this.iconId,
      strength: strength ?? this.strength,
      agility: agility ?? this.agility,
      wits: wits ?? this.wits,
      empathy: empathy ?? this.empathy,
      dexterity: dexterity ?? this.dexterity,
      force: force ?? this.force,
      infiltration: infiltration ?? this.infiltration,
      manipulation: manipulation ?? this.manipulation,
      meleeCombat: meleeCombat ?? this.meleeCombat,
      observation: observation ?? this.observation,
      rangedCombat: rangedCombat ?? this.rangedCombat,
      survival: survival ?? this.survival,
      command: command ?? this.command,
      culture: culture ?? this.culture,
      dataDjinn: dataDjinn ?? this.dataDjinn,
      medicurgy: medicurgy ?? this.medicurgy,
      mysticPowers: mysticPowers ?? this.mysticPowers,
      pilot: pilot ?? this.pilot,
      science: science ?? this.science,
      technology: technology ?? this.technology,
      pendingTalents: pendingTalents ?? this.pendingTalents,
      concept: concept ?? this.concept,
      role: role ?? this.role,
      crewConcept: crewConcept ?? this.crewConcept,
      mutant: mutant ?? this.mutant,
      mutantLineage:
          clearMutantLineage ? null : (mutantLineage ?? this.mutantLineage),
    );
  }

  @override
  List<Object?> get props => [
        name, origin, upbringing, age,
        iconId,
        strength, agility, wits, empathy,
        dexterity, force, infiltration, manipulation,
        meleeCombat, observation, rangedCombat, survival,
        command, culture, dataDjinn, medicurgy,
        mysticPowers, pilot, science, technology,
        pendingTalents,
        concept, role, crewConcept, mutant, mutantLineage,
      ];
}

/// A talent being assembled before saving to the repository.
class PendingTalent extends Equatable {
  const PendingTalent({
    required this.name,
    required this.description,
    this.iconAffinity,
  });

  final String name;
  final String description;
  final String? iconAffinity;

  @override
  List<Object?> get props => [name, description, iconAffinity];
}

/// Save-cycle status for wizard step transitions.
enum WizardSaveStatus { idle, saving, saved, error }

/// State emitted by [CharacterWizardCubit].
class CharacterWizardState extends Equatable {
  const CharacterWizardState({
    this.step = 1,
    this.draft = const WizardDraft(),
    this.character,
    this.isLoading = false,
    this.saveStatus = WizardSaveStatus.idle,
    this.lastError,
  });

  /// Current wizard step (1..6).
  final int step;

  /// Locally accumulated edits (not yet persisted).
  final WizardDraft draft;

  /// The server-side Character record (created on step-1 first advance).
  final Character? character;

  /// True while the cubit is loading or saving to the repository.
  final bool isLoading;

  /// Current save/load status.
  final WizardSaveStatus saveStatus;

  /// Non-null when [saveStatus] == [WizardSaveStatus.error].
  final String? lastError;

  bool get isSaving => saveStatus == WizardSaveStatus.saving;
  bool get hasError => saveStatus == WizardSaveStatus.error;

  CharacterWizardState copyWith({
    int? step,
    WizardDraft? draft,
    Character? character,
    bool? isLoading,
    WizardSaveStatus? saveStatus,
    String? lastError,
    bool clearError = false,
    bool clearCharacter = false,
  }) {
    return CharacterWizardState(
      step: step ?? this.step,
      draft: draft ?? this.draft,
      character: clearCharacter ? null : (character ?? this.character),
      isLoading: isLoading ?? this.isLoading,
      saveStatus: saveStatus ?? this.saveStatus,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  @override
  List<Object?> get props => [
        step,
        draft,
        character,
        isLoading,
        saveStatus,
        lastError,
      ];
}
