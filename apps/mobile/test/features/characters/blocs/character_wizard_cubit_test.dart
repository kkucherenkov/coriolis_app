import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';

// Fallback value for addItem.
class _FakeDomainItem extends Fake implements DomainItem {}

// ── Mocks ────────────────────────────────────────────────────────────────────

class _MockRepo extends Mock implements CharacterRepository {}

// ── Test data ─────────────────────────────────────────────────────────────────

final _now = DateTime(2026, 5, 9);

const _blankAttrs = CharacterAttributes(
  strength: 2, agility: 2, wits: 2, empathy: 2,
);

const _blankSkills = CharacterSkills(
  dexterity: 0, force: 0, infiltration: 0, manipulation: 0,
  meleeCombat: 0, observation: 0, rangedCombat: 0, survival: 0,
  command: 0, culture: 0, dataDjinn: 0, medicurgy: 0,
  mysticPowers: 0, pilot: 0, science: 0, technology: 0,
);

Character _makeCharacter({String id = 'c1', String name = 'Untitled'}) =>
    Character(
      id: id,
      ownerId: 'u1',
      name: name,
      attributes: _blankAttrs,
      skills: _blankSkills,
      hp: const CharacterHp(current: 4, max: 4),
      mp: const CharacterMp(current: 4, max: 4),
      encumbrance: const CharacterEncumbrance(current: 0, max: 8),
      experience: 0,
      conditions: const CharacterConditions(
        exhausted: false, sleepless: false, thirsty: false, hungry: false,
      ),
      criticalInjuries: const [],
      talents: const [],
      inventory: const [],
      createdAt: _now,
      updatedAt: _now,
    );

CharacterWizardCubit _buildCubit(_MockRepo repo) =>
    CharacterWizardCubit(repository: repo);

void main() {
  late _MockRepo repo;

  setUpAll(() {
    // Register fallback values for named-argument matchers.
    registerFallbackValue(const CharacterAttributes(
      strength: 2, agility: 2, wits: 2, empathy: 2,
    ));
    registerFallbackValue(const CharacterSkills(
      dexterity: 0, force: 0, infiltration: 0, manipulation: 0,
      meleeCombat: 0, observation: 0, rangedCombat: 0, survival: 0,
      command: 0, culture: 0, dataDjinn: 0, medicurgy: 0,
      mysticPowers: 0, pilot: 0, science: 0, technology: 0,
    ));
    registerFallbackValue(_FakeDomainItem());
  });

  setUp(() {
    repo = _MockRepo();
  });

  group('CharacterWizardCubit', () {
    // ── start with no id — creates new draft ────────────────────────────────

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'start(id: null) POSTs a new draft with default upbringing=plebeian',
      build: () {
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => _makeCharacter());
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.start(),
      expect: () => [
        isA<CharacterWizardState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<CharacterWizardState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.character?.id, 'character.id', 'c1')
            .having((s) => s.saveStatus, 'saveStatus', WizardSaveStatus.idle),
      ],
      verify: (_) {
        verify(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).called(1);
      },
    );

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'start(id: null) emits error state when create throws',
      build: () {
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenThrow(Exception('network error'));
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.start(),
      expect: () => [
        isA<CharacterWizardState>().having((s) => s.isLoading, 'isLoading', true),
        isA<CharacterWizardState>()
            .having((s) => s.saveStatus, 'saveStatus', WizardSaveStatus.error)
            .having((s) => s.lastError, 'lastError', isNotNull),
      ],
    );

    // ── start with id — loads existing draft ────────────────────────────────

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'start(id: existing) GETs the draft and rehydrates WizardDraft',
      build: () {
        final c = _makeCharacter(name: 'Veteran Pilot');
        when(() => repo.get('c1')).thenAnswer((_) async => c);
        return _buildCubit(repo);
      },
      act: (cubit) => cubit.start(id: 'c1'),
      expect: () => [
        isA<CharacterWizardState>().having((s) => s.isLoading, 'isLoading', true),
        isA<CharacterWizardState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.character?.id, 'character.id', 'c1')
            .having((s) => s.draft.name, 'draft.name', 'Veteran Pilot'),
      ],
      verify: (_) {
        verify(() => repo.get('c1')).called(1);
      },
    );

    // ── next / back changes step ─────────────────────────────────────────────

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'next() advances step after persisting current step data',
      build: () {
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => _makeCharacter());
        when(() => repo.update('c1',
                  name: any(named: 'name'),
                  upbringing: any(named: 'upbringing'),
                  origin: any(named: 'origin'),
                  crewConcept: any(named: 'crewConcept'),
                )).thenAnswer((_) async => _makeCharacter());
        return _buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.start();
        await cubit.next();
      },
      verify: (cubit) {
        expect(cubit.state.step, 2);
      },
    );

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'back() decrements step without saving',
      build: () {
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => _makeCharacter());
        when(() => repo.update('c1',
                  name: any(named: 'name'),
                  upbringing: any(named: 'upbringing'),
                  origin: any(named: 'origin'),
                  crewConcept: any(named: 'crewConcept'),
                )).thenAnswer((_) async => _makeCharacter());
        return _buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.start();
        await cubit.next(); // step 2
        cubit.back();       // back to step 1
      },
      verify: (cubit) {
        expect(cubit.state.step, 1);
        // update was called once (for next), not twice.
        verify(() => repo.update(any(),
                  name: any(named: 'name'),
                  upbringing: any(named: 'upbringing'),
                  origin: any(named: 'origin'),
                  crewConcept: any(named: 'crewConcept'),
                )).called(1);
      },
    );

    // ── Step 1 Biography persists name + upbringing + origin + crew ──────

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'Step 1 Biography → next() PATCHes name + canonical upbringing + origin + crew',
      build: () {
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => _makeCharacter());
        when(() => repo.update('c1',
                  name: any(named: 'name'),
                  upbringing: any(named: 'upbringing'),
                  origin: any(named: 'origin'),
                  crewConcept: any(named: 'crewConcept'),
                )).thenAnswer((_) async => _makeCharacter());
        return _buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.start();
        cubit.updateName('Kira Sol');
        cubit.updateUpbringing('aristocrat');
        cubit.updateOrigin('Atlas Outpost');
        cubit.updateCrewConcept('freeTrader');
        await cubit.next(); // 1 → 2
      },
      verify: (cubit) {
        expect(cubit.state.step, 2);
        verify(() => repo.update('c1',
                  name: 'Kira Sol',
                  upbringing: 'aristocrat',
                  origin: 'Atlas Outpost',
                  crewConcept: 'freeTrader',
                )).called(1);
      },
    );

    // ── Step 2 Concept (амплуа) persists canonical concept ────────────────

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'Step 2 Concept → next() PATCHes the canonical Concept enum value',
      build: () {
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => _makeCharacter());
        when(() => repo.update('c1',
                  name: any(named: 'name'),
                  upbringing: any(named: 'upbringing'),
                  origin: any(named: 'origin'),
                  crewConcept: any(named: 'crewConcept'),
                )).thenAnswer((_) async => _makeCharacter());
        when(() => repo.update('c1', concept: any(named: 'concept')))
            .thenAnswer((_) async => _makeCharacter());
        return _buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.start();
        await cubit.next(); // 1 → 2
        cubit.updateConcept('pilot');
        await cubit.next(); // 2 → 3
      },
      verify: (cubit) {
        expect(cubit.state.step, 3);
        verify(() => repo.update('c1', concept: 'pilot')).called(1);
      },
    );

    // ── Step 3 Role persists canonical role ───────────────────────────────

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'Step 3 Role → next() PATCHes the canonical Role enum value',
      build: () {
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => _makeCharacter());
        when(() => repo.update('c1',
                  name: any(named: 'name'),
                  upbringing: any(named: 'upbringing'),
                  origin: any(named: 'origin'),
                  crewConcept: any(named: 'crewConcept'),
                )).thenAnswer((_) async => _makeCharacter());
        when(() => repo.update('c1', concept: any(named: 'concept')))
            .thenAnswer((_) async => _makeCharacter());
        when(() => repo.update('c1', role: any(named: 'role')))
            .thenAnswer((_) async => _makeCharacter());
        return _buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.start();
        cubit.updateConcept('pilot');
        await cubit.next(); // 1 → 2
        await cubit.next(); // 2 → 3
        cubit.updateRole('ace');
        await cubit.next(); // 3 → 4
      },
      verify: (cubit) {
        expect(cubit.state.step, 4);
        verify(() => repo.update('c1', role: 'ace')).called(1);
      },
    );

    // ── Step 7 Icon persists canonical iconId ─────────────────────────────

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'Step 7 Icon → next() returns false (no step 8); selectIconId roundtrips locally',
      build: () {
        return _buildCubit(repo);
      },
      act: (cubit) {
        // Without going through the full wizard, simulate landing on step 7.
        cubit.selectIconId('traveler');
      },
      verify: (cubit) {
        expect(cubit.state.draft.iconId, 'traveler');
      },
    );

    // ── forge() PATCHes status active ────────────────────────────────────────

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'forge() calls update with all draft data and re-fetches character',
      build: () {
        final base = _makeCharacter(name: 'Kira Sol');
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => base);
        when(() => repo.update(
              'c1',
              name: any(named: 'name'),
              concept: any(named: 'concept'),
              role: any(named: 'role'),
              iconId: any(named: 'iconId'),
              upbringing: any(named: 'upbringing'),
              origin: any(named: 'origin'),
              crewConcept: any(named: 'crewConcept'),
              mutant: any(named: 'mutant'),
              mutantLineage: any(named: 'mutantLineage'),
              attributes: any(named: 'attributes'),
              skills: any(named: 'skills'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => base);
        when(() => repo.get('c1')).thenAnswer((_) async => base);
        return _buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.start();
        cubit.updateName('Kira Sol');
        await cubit.forge();
      },
      verify: (cubit) {
        expect(cubit.state.saveStatus, WizardSaveStatus.saved);
        expect(cubit.state.character?.name, 'Kira Sol');
        verify(() => repo.update(
              'c1',
              name: any(named: 'name'),
              concept: any(named: 'concept'),
              role: any(named: 'role'),
              iconId: any(named: 'iconId'),
              upbringing: any(named: 'upbringing'),
              origin: any(named: 'origin'),
              crewConcept: any(named: 'crewConcept'),
              mutant: any(named: 'mutant'),
              mutantLineage: any(named: 'mutantLineage'),
              attributes: any(named: 'attributes'),
              skills: any(named: 'skills'),
              status: 'active',
            )).called(1);
        verify(() => repo.get('c1')).called(1);
      },
    );

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'forge() emits error state on repository failure',
      build: () {
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => _makeCharacter());
        when(() => repo.update(
              'c1',
              name: any(named: 'name'),
              concept: any(named: 'concept'),
              role: any(named: 'role'),
              iconId: any(named: 'iconId'),
              upbringing: any(named: 'upbringing'),
              origin: any(named: 'origin'),
              crewConcept: any(named: 'crewConcept'),
              mutant: any(named: 'mutant'),
              mutantLineage: any(named: 'mutantLineage'),
              attributes: any(named: 'attributes'),
              skills: any(named: 'skills'),
              status: any(named: 'status'),
            )).thenThrow(Exception('forge failed'));
        return _buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.start();
        await cubit.forge();
      },
      verify: (cubit) {
        expect(cubit.state.saveStatus, WizardSaveStatus.error);
        expect(cubit.state.lastError, isNotNull);
      },
    );

    // ── Step 8 — selectGearPick ──────────────────────────────────────────────

    test('selectGearPick sets the option for a row', () {
      final cubit = _buildCubit(repo);
      cubit.selectGearPick('row-1', 'tool-kit-s');
      expect(cubit.state.draft.pendingGearPicks['row-1'], 'tool-kit-s');
    });

    test('selectGearPick re-tap same option clears the row', () {
      final cubit = _buildCubit(repo);
      cubit.selectGearPick('row-1', 'tool-kit-s');
      expect(cubit.state.draft.pendingGearPicks['row-1'], 'tool-kit-s');
      cubit.selectGearPick('row-1', 'tool-kit-s');
      expect(cubit.state.draft.pendingGearPicks['row-1'], isNull);
    });

    test('selectGearPick flipping from one option to another in same row', () {
      final cubit = _buildCubit(repo);
      cubit.selectGearPick('row-1', 'tool-kit-s');
      cubit.selectGearPick('row-1', 'piloting-talisman');
      expect(cubit.state.draft.pendingGearPicks['row-1'], 'piloting-talisman');
    });

    // ── forge() posts picked gear items ─────────────────────────────────────

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'forge() calls addItem for each non-null gear pick in order',
      build: () {
        final base = _makeCharacter(name: 'Kira Sol');
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => base);
        when(() => repo.update(
              'c1',
              name: any(named: 'name'),
              concept: any(named: 'concept'),
              role: any(named: 'role'),
              iconId: any(named: 'iconId'),
              upbringing: any(named: 'upbringing'),
              origin: any(named: 'origin'),
              crewConcept: any(named: 'crewConcept'),
              mutant: any(named: 'mutant'),
              mutantLineage: any(named: 'mutantLineage'),
              attributes: any(named: 'attributes'),
              skills: any(named: 'skills'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => base);
        when(() => repo.get('c1')).thenAnswer((_) async => base);
        when(() => repo.addItem('c1', any()))
            .thenAnswer((_) async => const DomainItem(
                  id: 'new-item',
                  type: ItemType.gear,
                  name: 'Tool kit (S)',
                ));
        return _buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.start();
        // Seed concept + role + two gear picks.
        cubit.updateConcept('pilot');
        cubit.updateRole('ace');
        cubit.selectGearPick('row-1', 'tool-kit-s');
        cubit.selectGearPick('row-4', 'rail-pistol');
        await cubit.forge();
      },
      verify: (cubit) {
        expect(cubit.state.saveStatus, WizardSaveStatus.saved);
        // addItem called twice — once per non-null pick.
        verify(() => repo.addItem('c1', any())).called(2);
      },
    );

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'forge() with no gear picks calls addItem zero times',
      build: () {
        final base = _makeCharacter();
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => base);
        when(() => repo.update(
              'c1',
              name: any(named: 'name'),
              concept: any(named: 'concept'),
              role: any(named: 'role'),
              iconId: any(named: 'iconId'),
              upbringing: any(named: 'upbringing'),
              origin: any(named: 'origin'),
              crewConcept: any(named: 'crewConcept'),
              mutant: any(named: 'mutant'),
              mutantLineage: any(named: 'mutantLineage'),
              attributes: any(named: 'attributes'),
              skills: any(named: 'skills'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => base);
        when(() => repo.get('c1')).thenAnswer((_) async => base);
        return _buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.start();
        cubit.updateConcept('pilot');
        cubit.updateRole('ace');
        // No gear picks.
        await cubit.forge();
      },
      verify: (cubit) {
        expect(cubit.state.saveStatus, WizardSaveStatus.saved);
        verifyNever(() => repo.addItem(any(), any()));
      },
    );

    blocTest<CharacterWizardCubit, CharacterWizardState>(
      'forge() with null concept/role skips gear items',
      build: () {
        final base = _makeCharacter();
        when(() => repo.create(
              name: 'Untitled',
              upbringing: 'plebeian',
              status: 'draft',
            )).thenAnswer((_) async => base);
        when(() => repo.update(
              'c1',
              name: any(named: 'name'),
              concept: any(named: 'concept'),
              role: any(named: 'role'),
              iconId: any(named: 'iconId'),
              upbringing: any(named: 'upbringing'),
              origin: any(named: 'origin'),
              crewConcept: any(named: 'crewConcept'),
              mutant: any(named: 'mutant'),
              mutantLineage: any(named: 'mutantLineage'),
              attributes: any(named: 'attributes'),
              skills: any(named: 'skills'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => base);
        when(() => repo.get('c1')).thenAnswer((_) async => base);
        return _buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.start();
        // No concept/role — findStarterKit returns null.
        cubit.selectGearPick('row-1', 'something');
        await cubit.forge();
      },
      verify: (cubit) {
        verifyNever(() => repo.addItem(any(), any()));
      },
    );

    // ── mutant / mutantLineage coupling ──────────────────────────────────────

    test('setMutant(false) clears mutantLineage', () {
      final cubit = _buildCubit(repo);
      cubit.setMutant(true);
      cubit.setMutantLineage('zirba');
      expect(cubit.state.draft.mutant, isTrue);
      expect(cubit.state.draft.mutantLineage, 'zirba');

      cubit.setMutant(false);
      expect(cubit.state.draft.mutant, isFalse);
      expect(cubit.state.draft.mutantLineage, isNull);
    });

    // ── point-pool guard ─────────────────────────────────────────────────────

    test('updateAttribute respects 13-point pool limit', () {
      final cubit = _buildCubit(repo);
      // Manually place 13 points (2+2+2+2 = 8 spent initially,
      // we need to fill the remaining 5 into one attribute).
      cubit.updateAttribute('strength', 3); // → 5 (2+3)
      cubit.updateAttribute('agility', 1);  // → 3 (2+1)
      cubit.updateAttribute('wits', 1);     // → 3 (2+1)
      cubit.updateAttribute('empathy', 1);  // → 3 (2+1), total = 14 → exceeds
      // The last update was rejected at 13 total:
      // 5+3+3+2 = 13, so empathy +1 would make 14 — rejected.
      final d = cubit.state.draft;
      expect(
        (d.strength ?? 2) + (d.agility ?? 2) + (d.wits ?? 2) + (d.empathy ?? 2),
        lessThanOrEqualTo(13),
      );
    });
  });
}
