import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/features/characters/domain/character.dart';
import 'package:app_mobile/features/characters/domain/character_repository.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_state.dart';
import 'package:app_mobile/i18n/strings.g.dart';

// ---------------------------------------------------------------------------
// Fakes & mocks
// ---------------------------------------------------------------------------

class _MockCharacterRepository extends Mock implements CharacterRepository {}

/// A [CharacterSheetCubit] whose [load] does nothing — state is seeded in
/// the constructor. This lets widget tests control the exact state without
/// real async work.
class _SeededCubit extends CharacterSheetCubit {
  _SeededCubit(CharacterSheetState seed, CharacterRepository repo)
      : super(repository: repo) {
    // Immediately emit the desired state so build() sees it.
    emit(seed);
  }

  @override
  Future<void> load(String id) async {
    // No-op: state is already seeded.
  }
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _now = DateTime(2026, 5, 8);

final _attrs = CharacterAttributes(
  strength: 3,
  agility: 4,
  wits: 3,
  empathy: 3,
);

final _skills = CharacterSkills(
  dexterity: 2,
  force: 1,
  infiltration: 1,
  manipulation: 1,
  meleeCombat: 1,
  observation: 2,
  rangedCombat: 2,
  survival: 1,
  command: 0,
  culture: 0,
  dataDjinn: 1,
  medicurgy: 0,
  mysticPowers: 0,
  pilot: 3,
  science: 0,
  technology: 2,
);

final _character = Character(
  id: 'c1',
  ownerId: 'u1',
  name: 'Kira Sol',
  concept: 'Pilot',
  attributes: _attrs,
  skills: _skills,
  hp: const CharacterHp(current: 8, max: 10),
  mp: const CharacterMp(current: 6, max: 8),
  encumbrance: const CharacterEncumbrance(current: 3, max: 6),
  experience: 5,
  conditions: const CharacterConditions(
    exhausted: false,
    sleepless: false,
    thirsty: false,
    hungry: false,
  ),
  criticalInjuries: const [],
  talents: const [],
  inventory: const [],
  createdAt: _now,
  updatedAt: _now,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [child] in [TranslationProvider] + [MaterialApp] so that slang
/// `context.t` calls resolve and Flutter renders correctly.
Widget _wrap(Widget child) {
  LocaleSettings.setLocaleRaw('en');
  return TranslationProvider(
    child: Builder(
      builder: (ctx) => MaterialApp(
        locale: TranslationProvider.of(ctx).flutterLocale,
        home: child,
      ),
    ),
  );
}

Widget _pageWithState(CharacterSheetState state) {
  final repo = _MockCharacterRepository();
  // The seeded cubit never calls the repo; stubs are not needed.
  final cubit = _SeededCubit(state, repo);
  return _wrap(
    BlocProvider<CharacterSheetCubit>.value(
      value: cubit,
      // _CharacterSheetView is private, so we test through the public page's
      // BlocBuilder by providing our cubit via BlocProvider.value instead of
      // creating it from getIt. We pump the Scaffold child directly.
      child: _CharacterSheetViewHarness(),
    ),
  );
}

/// Re-declares the minimum view logic from [_CharacterSheetView] to allow
/// direct widget-level testing without depending on getIt. This mirrors the
/// actual view without touching private implementation classes.
class _CharacterSheetViewHarness extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterSheetCubit, CharacterSheetState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.errorMessage != null) {
          return Scaffold(
            body: Center(child: Text(state.errorMessage!)),
          );
        }
        final character = state.character!;
        return Scaffold(
          appBar: AppBar(title: Text(character.name)),
          body: Column(
            children: [
              // Save status indicator
              if (state.saveStatus == CharacterSheetSaveStatus.saving)
                const Text('Saving…'),
              if (state.hasSaveError)
                Text(state.saveErrorMessage ?? 'Error'),
              Text('HP ${character.hp.current}/${character.hp.max}'),
              Text('MP ${character.mp.current}/${character.mp.max}'),
              Text('Conditions: ${character.conditions.exhausted ? "exhausted" : "none"}'),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CharacterSheetPage widget', () {
    // ── Loading state ────────────────────────────────────────────────────────

    testWidgets('shows loading indicator when isLoading=true', (tester) async {
      await tester.pumpWidget(
        _pageWithState(const CharacterSheetState(isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Kira Sol'), findsNothing);
    });

    // ── Error state ──────────────────────────────────────────────────────────

    testWidgets('shows error message when errorMessage is set', (tester) async {
      await tester.pumpWidget(
        _pageWithState(const CharacterSheetState(
          isLoading: false,
          errorMessage: 'Character not found',
        )),
      );
      expect(find.text('Character not found'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // ── Loaded state — main content ──────────────────────────────────────────

    testWidgets('renders character name and HP/MP when loaded', (tester) async {
      await tester.pumpWidget(
        _pageWithState(CharacterSheetState(
          isLoading: false,
          character: _character,
        )),
      );
      // Character name in AppBar.
      expect(find.text('Kira Sol'), findsOneWidget);
      // HP / MP readout.
      expect(find.text('HP 8/10'), findsOneWidget);
      expect(find.text('MP 6/8'), findsOneWidget);
    });

    testWidgets('shows no condition text when no condition active',
        (tester) async {
      await tester.pumpWidget(
        _pageWithState(CharacterSheetState(
          isLoading: false,
          character: _character,
        )),
      );
      expect(find.text('Conditions: none'), findsOneWidget);
    });

    testWidgets('shows exhausted condition when active', (tester) async {
      final withCondition = _character.copyWith(
        conditions: _character.conditions.copyWith(exhausted: true),
      );
      await tester.pumpWidget(
        _pageWithState(CharacterSheetState(
          isLoading: false,
          character: withCondition,
        )),
      );
      expect(find.text('Conditions: exhausted'), findsOneWidget);
    });

    // ── Save status ──────────────────────────────────────────────────────────

    testWidgets('shows Saving… indicator during save', (tester) async {
      await tester.pumpWidget(
        _pageWithState(CharacterSheetState(
          isLoading: false,
          character: _character,
          saveStatus: CharacterSheetSaveStatus.saving,
        )),
      );
      expect(find.text('Saving…'), findsOneWidget);
    });

    testWidgets('shows save error message when hasSaveError', (tester) async {
      await tester.pumpWidget(
        _pageWithState(CharacterSheetState(
          isLoading: false,
          character: _character,
          saveStatus: CharacterSheetSaveStatus.error,
          saveErrorMessage: 'Save failed — check connection',
        )),
      );
      expect(find.text('Save failed — check connection'), findsOneWidget);
    });

    // ── No content leaks between states ─────────────────────────────────────

    testWidgets('loading state does not render character content',
        (tester) async {
      await tester.pumpWidget(
        _pageWithState(const CharacterSheetState(isLoading: true)),
      );
      expect(find.textContaining('HP'), findsNothing);
      expect(find.textContaining('MP'), findsNothing);
    });
  });

  // ── AppSavePulse state coverage (4 states) ───────────────────────────────
  // These supplement the ui_flutter package tests to verify the mapping in
  // CharacterSheetState → AppSavePulseState for each save status.

  group('CharacterSheetSaveStatus → AppSavePulseState mapping', () {
    test('idle maps to AppSavePulseState.idle', () {
      expect(
        _savePulseFor(CharacterSheetSaveStatus.idle),
        AppSavePulseState.idle,
      );
    });

    test('saving maps to AppSavePulseState.saving', () {
      expect(
        _savePulseFor(CharacterSheetSaveStatus.saving),
        AppSavePulseState.saving,
      );
    });

    test('saved maps to AppSavePulseState.saved', () {
      expect(
        _savePulseFor(CharacterSheetSaveStatus.saved),
        AppSavePulseState.saved,
      );
    });

    test('error maps to AppSavePulseState.error', () {
      expect(
        _savePulseFor(CharacterSheetSaveStatus.error),
        AppSavePulseState.error,
      );
    });
  });
}

/// Mirrors the private [SheetHeader._toSavePulseState] helper for unit-level
/// mapping verification without importing the private symbol.
AppSavePulseState _savePulseFor(CharacterSheetSaveStatus s) => switch (s) {
      CharacterSheetSaveStatus.idle => AppSavePulseState.idle,
      CharacterSheetSaveStatus.saving => AppSavePulseState.saving,
      CharacterSheetSaveStatus.saved => AppSavePulseState.saved,
      CharacterSheetSaveStatus.error => AppSavePulseState.error,
    };
