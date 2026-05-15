import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_1_biography.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_2_concept.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_3_role.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_4_attributes.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_6_talents.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_7_icon.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class _MockRepo extends Mock implements CharacterRepository {}

/// A cubit whose state is pre-seeded for widget tests.
class _SeededWizardCubit extends CharacterWizardCubit {
  _SeededWizardCubit(CharacterWizardState seed, CharacterRepository repo)
      : super(repository: repo) {
    emit(seed);
  }

  @override
  Future<String?> start({String? id}) async => null;
}

// ── Shared test data ──────────────────────────────────────────────────────────

final _now = DateTime(2026, 5, 9);

Character _makeCharacter() => Character(
      id: 'c1',
      ownerId: 'u1',
      name: 'Untitled',
      attributes: const CharacterAttributes(
          strength: 2, agility: 2, wits: 2, empathy: 2),
      skills: const CharacterSkills(
        dexterity: 0, force: 0, infiltration: 0, manipulation: 0,
        meleeCombat: 0, observation: 0, rangedCombat: 0, survival: 0,
        command: 0, culture: 0, dataDjinn: 0, medicurgy: 0,
        mysticPowers: 0, pilot: 0, science: 0, technology: 0,
      ),
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

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _wrapStep(CharacterWizardState state, Widget stepWidget) {
  LocaleSettings.setLocaleRaw('en');
  final repo = _MockRepo();
  final cubit = _SeededWizardCubit(state, repo);
  return TranslationProvider(
    child: Builder(
      builder: (ctx) => MaterialApp(
        locale: TranslationProvider.of(ctx).flutterLocale,
        // Force-disable animations in widget tests so the infinite-pulse
        // ticker on Step 3's selected icon does not run a paint loop until
        // the binding stack overflows.
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: BlocProvider<CharacterWizardCubit>.value(
            value: cubit,
            child: Scaffold(body: stepWidget),
          ),
        ),
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('CharacterCreatePage — wizard steps (7-step canonical order)', () {
    // ── Step 1 Biography — name field surfaces ─────────────────────────────

    testWidgets('Step1Biography shows the name field', (tester) async {
      final state = CharacterWizardState(
        step: 1,
        draft: const WizardDraft(name: 'Kira Sol'),
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step1Biography()));
      await tester.pump();
      expect(find.text('Kira Sol'), findsAtLeastNWidgets(1));
    });

    // ── Step 2 Concept — amplua picker renders all 11 cards ────────────────

    testWidgets('Step2Concept renders all eleven amplua cards',
        (tester) async {
      final state = CharacterWizardState(
        step: 2,
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step2Concept()));
      await tester.pump();
      // Spot-check two of the eleven amplua labels.
      expect(find.textContaining('Pilot'), findsOneWidget);
      expect(find.textContaining('Soldier'), findsOneWidget);
    });

    // ── Step 3 Role — placeholder when no concept; cards when picked ───────

    testWidgets('Step3Role renders placeholder when concept is null',
        (tester) async {
      final state = CharacterWizardState(
        step: 3,
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step3Role()));
      await tester.pump();
      expect(find.textContaining('Pick an amplua'), findsOneWidget);
    });

    testWidgets('Step3Role renders the three roles of the chosen amplua',
        (tester) async {
      final state = CharacterWizardState(
        step: 3,
        draft: const WizardDraft(concept: 'pilot'),
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step3Role()));
      await tester.pump();
      // pilot amplua → Ace · Driver · Trucker.
      expect(find.text('Ace'), findsOneWidget);
      expect(find.text('Driver'), findsOneWidget);
      expect(find.text('Trucker'), findsOneWidget);
    });

    // ── Step 4 — attribute stepper rows ───────────────────────────────────

    testWidgets('Step4Attributes shows four attribute rows', (tester) async {
      final state = CharacterWizardState(
        step: 4,
        draft: const WizardDraft(
          strength: 3, agility: 2, wits: 4, empathy: 4,
        ),
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step4Attributes()));
      await tester.pump();
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Agility'), findsOneWidget);
      expect(find.text('Wits'), findsOneWidget);
      expect(find.text('Empathy'), findsOneWidget);
    });

    // ── Step 6 — talents list + Add button ────────────────────────────────

    testWidgets('Step6Talents shows pending talents and Add button',
        (tester) async {
      final state = CharacterWizardState(
        step: 6,
        draft: const WizardDraft(
          pendingTalents: [
            PendingTalent(name: 'Nine lives', description: 'Survive lethal hits.'),
          ],
        ),
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step6Talents()));
      await tester.pump();

      expect(find.text('Nine lives'), findsOneWidget);
      expect(find.textContaining('Add talent'), findsOneWidget);
    });

    // ── Step 7 Icon — canonical 9-card grid ───────────────────────────────

    testWidgets('Step7Icon renders all nine canonical icon cards',
        (tester) async {
      final state = CharacterWizardState(
        step: 7,
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step7Icon()));
      await tester.pump();
      expect(find.textContaining('Traveler'), findsOneWidget);
      expect(find.textContaining('Faceless'), findsOneWidget);
    });

    testWidgets('Step7Icon highlights selected icon', (tester) async {
      final state = CharacterWizardState(
        step: 7,
        draft: const WizardDraft(iconId: 'traveler'),
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step7Icon()));
      await tester.pump();
      expect(
        find.byWidgetPredicate((w) =>
            w is AppCard && w.variant == AppCardVariant.featured),
        findsAtLeastNWidgets(1),
      );
    });
  });
}
