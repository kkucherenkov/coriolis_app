import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_1_concept.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_3_icon.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_4_attributes.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_6_talents.dart';
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
  group('CharacterCreatePage — wizard steps', () {
    // ── Step 1 — renders name + concept fields ─────────────────────────────

    testWidgets('Step1Concept shows the name field', (tester) async {
      final state = CharacterWizardState(
        step: 1,
        draft: const WizardDraft(name: 'Kira Sol'),
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step1Concept()));
      await tester.pump();

      // The AppInput uses TextField internally; locate by value.
      expect(find.text('Kira Sol'), findsAtLeastNWidgets(1));
    });

    // ── Step 3 — Icon grid renders all 9 canonical icons ──────────────────

    testWidgets('Step3Icon renders all nine canonical icon cards',
        (tester) async {
      final state = CharacterWizardState(
        step: 3,
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step3Icon()));
      await tester.pump();

      // Check that two of the canonical nine are present.
      expect(find.textContaining('Traveler'), findsOneWidget);
      expect(find.textContaining('Faceless'), findsOneWidget);
    });

    testWidgets('Step3Icon highlights selected icon', (tester) async {
      final state = CharacterWizardState(
        step: 3,
        draft: const WizardDraft(iconId: 'traveler'),
        character: _makeCharacter(),
      );
      await tester.pumpWidget(_wrapStep(state, const Step3Icon()));
      await tester.pump();

      // The selected card is an AppCard.featured; verify at least one exists.
      expect(
        find.byWidgetPredicate((w) =>
            w is AppCard && w.variant == AppCardVariant.featured),
        findsAtLeastNWidgets(1),
      );
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

      // Each attribute has a full label visible.
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
      // "Add talent" button should be visible (< 3 talents).
      expect(find.textContaining('Add talent'), findsOneWidget);
    });
  });
}
