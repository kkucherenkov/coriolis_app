import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_8_gear.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class _MockRepo extends Mock implements CharacterRepository {}

/// Pre-seeds state so tests don't need to drive the full wizard start flow.
class _SeededCubit extends CharacterWizardCubit {
  _SeededCubit(CharacterWizardState seed, CharacterRepository repo)
      : super(repository: repo) {
    emit(seed);
  }

  @override
  Future<String?> start({String? id}) async => null;
}

// ── Shared fixture ────────────────────────────────────────────────────────────

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

Widget _wrap(CharacterWizardState state) {
  LocaleSettings.setLocaleRaw('en');
  final repo = _MockRepo();
  final cubit = _SeededCubit(state, repo);
  return TranslationProvider(
    child: Builder(
      builder: (ctx) => MaterialApp(
        locale: TranslationProvider.of(ctx).flutterLocale,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: BlocProvider<CharacterWizardCubit>.value(
            value: cubit,
            child: const Scaffold(
              body: SingleChildScrollView(child: Step8Gear()),
            ),
          ),
        ),
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Step8Gear', () {
    // ── Empty-state when no concept ──────────────────────────────────────────

    testWidgets('renders placeholder when concept is null', (tester) async {
      final state = CharacterWizardState(
        step: 8,
        character: _makeCharacter(),
        // no concept or role set
      );
      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(
        find.textContaining('Pick a concept and role first'),
        findsOneWidget,
      );
      // No gear cards should appear.
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('renders placeholder when role is null but concept is set',
        (tester) async {
      final state = CharacterWizardState(
        step: 8,
        character: _makeCharacter(),
        draft: const WizardDraft(concept: 'pilot'),
        // no role — findStarterKit returns null
      );
      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(
        find.textContaining('Pick a concept and role first'),
        findsOneWidget,
      );
    });

    // ── Correct options rendered for a known kit ─────────────────────────────

    testWidgets('renders 5 rows × 2 option texts for pilot/ace',
        (tester) async {
      final state = CharacterWizardState(
        step: 8,
        character: _makeCharacter(),
        draft: const WizardDraft(concept: 'pilot', role: 'ace'),
      );
      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      // Row 1 options: Tool kit (S) | Piloting talisman
      expect(find.textContaining('Tool kit (S)'), findsOneWidget);
      expect(find.textContaining('Piloting talisman'), findsOneWidget);
      // Row 4 options: Rail pistol | Neuroshocker
      expect(find.textContaining('Rail pistol'), findsOneWidget);
      expect(find.textContaining('Neuroshocker'), findsOneWidget);

      // No pick yet → no checkmarks.
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // Progress counter should show "Picked 0 of 5".
      expect(find.textContaining('Picked 0 of 5'), findsOneWidget);
    });

    // ── Tapping selects an option ────────────────────────────────────────────

    testWidgets('tapping an option card calls selectGearPick on the cubit',
        (tester) async {
      final repo = _MockRepo();
      final state = CharacterWizardState(
        step: 8,
        character: _makeCharacter(),
        draft: const WizardDraft(concept: 'pilot', role: 'ace'),
      );
      final cubit = _SeededCubit(state, repo);

      LocaleSettings.setLocaleRaw('en');
      await tester.pumpWidget(TranslationProvider(
        child: Builder(
          builder: (ctx) => MaterialApp(
            locale: TranslationProvider.of(ctx).flutterLocale,
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: BlocProvider<CharacterWizardCubit>.value(
                value: cubit,
                child: const Scaffold(
                  body: SingleChildScrollView(child: Step8Gear()),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      // Tap "Tool kit (S)" — first option in row-1 for pilot kit.
      await tester.tap(find.textContaining('Tool kit (S)'));
      await tester.pump();

      // After tap the cubit state should have row-1 → tool-kit-s.
      expect(cubit.state.draft.pendingGearPicks['row-1'], 'tool-kit-s');

      // A checkmark should appear.
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Progress counter increments.
      expect(find.textContaining('Picked 1 of 5'), findsOneWidget);
    });

    // ── Re-tapping the same option clears the row ────────────────────────────

    testWidgets('re-tapping same option clears the row pick', (tester) async {
      final repo = _MockRepo();
      final state = CharacterWizardState(
        step: 8,
        character: _makeCharacter(),
        draft: const WizardDraft(
          concept: 'pilot',
          role: 'ace',
          pendingGearPicks: {'row-1': 'tool-kit-s'},
        ),
      );
      final cubit = _SeededCubit(state, repo);

      LocaleSettings.setLocaleRaw('en');
      await tester.pumpWidget(TranslationProvider(
        child: Builder(
          builder: (ctx) => MaterialApp(
            locale: TranslationProvider.of(ctx).flutterLocale,
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: BlocProvider<CharacterWizardCubit>.value(
                value: cubit,
                child: const Scaffold(
                  body: SingleChildScrollView(child: Step8Gear()),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      // One checkmark already visible for the pre-seeded pick.
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Re-tap the selected option.
      await tester.tap(find.textContaining('Tool kit (S)'));
      await tester.pump();

      // Cubit should clear the row.
      expect(cubit.state.draft.pendingGearPicks['row-1'], isNull);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });
  });
}
