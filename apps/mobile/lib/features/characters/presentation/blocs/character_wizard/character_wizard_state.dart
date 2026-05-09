import 'package:equatable/equatable.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';

/// The Nine Icons of the Third Horizon.
///
/// Each value maps to a canonical glyph name used in the domain and i18n.
enum CoriolisIcon {
  theJudiciary,
  theTraveler,
  theMessenger,
  theLegionnaire,
  theNurse,
  theMerchant,
  theSymbiont,
  theFaceless,
  theChained,
}

/// Draft-data collected step-by-step before the character is activated.
///
/// All fields are nullable so the wizard can persist partial progress
/// without requiring every step to be complete.
class WizardDraft extends Equatable {
  const WizardDraft({
    // Step 1 — Concept
    this.name,
    this.concept,
    // Step 2 — People & Background
    this.origin,
    this.upbringing,
    this.age,
    // Step 3 — Icon
    this.selectedIcon,
    // Step 4 — Attributes (store as a map key→value for easy per-step mutation)
    this.strength,
    this.agility,
    this.wits,
    this.empathy,
    // Step 5 — Skills (same)
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
  });

  // Step 1
  final String? name;
  final String? concept;
  // Step 2
  final String? origin;
  final String? upbringing;
  final int? age;
  // Step 3
  final CoriolisIcon? selectedIcon;
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

  // ── Derived point-pool helpers ───────────────────────────────────────────

  /// Total attribute points allocated across the four attributes.
  int get attributePointsSpent =>
      (strength ?? 2) + (agility ?? 2) + (wits ?? 2) + (empathy ?? 2);

  /// General skill points allocated (sum of 8 general skills).
  int get generalSkillPointsSpent =>
      (dexterity ?? 0) +
      (force ?? 0) +
      (infiltration ?? 0) +
      (manipulation ?? 0) +
      (meleeCombat ?? 0) +
      (observation ?? 0) +
      (rangedCombat ?? 0) +
      (survival ?? 0);

  /// Advanced skill points allocated (sum of 8 advanced skills).
  int get advancedSkillPointsSpent =>
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
    String? concept,
    String? origin,
    String? upbringing,
    int? age,
    CoriolisIcon? selectedIcon,
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
  }) {
    return WizardDraft(
      name: name ?? this.name,
      concept: concept ?? this.concept,
      origin: origin ?? this.origin,
      upbringing: upbringing ?? this.upbringing,
      age: age ?? this.age,
      selectedIcon: selectedIcon ?? this.selectedIcon,
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
    );
  }

  @override
  List<Object?> get props => [
        name, concept, origin, upbringing, age,
        selectedIcon,
        strength, agility, wits, empathy,
        dexterity, force, infiltration, manipulation,
        meleeCombat, observation, rangedCombat, survival,
        command, culture, dataDjinn, medicurgy,
        mysticPowers, pilot, science, technology,
        pendingTalents,
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
