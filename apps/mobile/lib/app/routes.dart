import 'package:flutter/material.dart';

import 'package:coriolis_companion/features/auth/presentation/sign_in_screen.dart';
import 'package:coriolis_companion/features/auth/presentation/sign_up_screen.dart';
import 'package:coriolis_companion/features/auth/presentation/welcome_screen.dart';
import 'package:coriolis_companion/features/characters/presentation/pages/character_create_page.dart';
import 'package:coriolis_companion/features/characters/presentation/pages/character_sheet_page.dart';
import 'package:coriolis_companion/features/characters/presentation/pages/characters_list_page.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_cubit.dart';
import 'package:coriolis_companion/features/combat/presentation/pages/combat_tracker_page.dart';
import 'package:coriolis_companion/features/game_sessions/presentation/pages/session_detail_page.dart';
import 'package:coriolis_companion/shared/di/injector.dart';
import 'package:coriolis_companion/features/game_sessions/presentation/pages/sessions_list_page.dart';
import 'package:coriolis_companion/features/settings/presentation/settings_screen.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_create/ship_create_cubit.dart';
import 'package:coriolis_companion/features/ships/presentation/pages/ship_create_page.dart';
import 'package:coriolis_companion/features/ships/presentation/pages/ship_sheet_page.dart';
import 'package:coriolis_companion/features/ships/presentation/pages/ships_list_page.dart';

/// Named route constants.
abstract class AppRoutes {
  static const welcome = '/';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const settings = '/settings';

  // Characters feature — authenticated routes.
  static const characters = '/app/characters';
  static const charactersNew = '/app/characters/new';

  /// Detail route: pass the character id as a [RouteSettings.arguments] String.
  static const characterDetail = '/app/characters/detail';

  // Sessions feature (Phase 4).
  static const sessions = '/app/sessions';

  /// Pass the session id as a [RouteSettings.arguments] String.
  static const sessionDetail = '/app/sessions/detail';

  // Ships feature.
  static const ships = '/app/ships';

  /// Create flow — pushed from the ships-list FAB.
  static const shipsNew = '/app/ships/new';

  /// Detail route: pass the ship id as a [RouteSettings.arguments] String.
  static const shipDetail = '/app/ships/detail';

  // Combat feature.
  /// Pass a [CombatTrackerArgs] as [RouteSettings.arguments].
  static const combatTracker = '/app/combat/tracker';
}

/// Arguments for the [AppRoutes.combatTracker] route.
class CombatTrackerArgs {
  const CombatTrackerArgs({
    required this.sessionId,
    required this.isGm,
    required this.dpCount,
    this.sessionCharacterIds = const [],
  });

  final String sessionId;
  final bool isGm;
  final int dpCount;

  /// Character ids assigned to the parent session. The Add-Combatant picker
  /// filters the user's character list by this set so the GM only sees PCs
  /// that actually belong in this session. Empty list disables the filter.
  final List<String> sessionCharacterIds;
}

/// Route factory — maps route names to screen widgets.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final name = settings.name;

  if (name == AppRoutes.welcome) {
    return MaterialPageRoute<void>(
      builder: (_) => const WelcomeScreen(),
      settings: settings,
    );
  }

  if (name == AppRoutes.signIn) {
    return MaterialPageRoute<void>(
      builder: (_) => const SignInScreen(),
      settings: settings,
    );
  }

  if (name == AppRoutes.signUp) {
    return MaterialPageRoute<void>(
      builder: (_) => const SignUpScreen(),
      settings: settings,
    );
  }

  if (name == AppRoutes.settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const SettingsScreen(),
      settings: settings,
    );
  }

  // ── Characters feature ─────────────────────────────────────────────────

  if (name == AppRoutes.characters) {
    return MaterialPageRoute<void>(
      builder: (_) => const CharactersListPage(),
      settings: settings,
    );
  }

  if (name == AppRoutes.charactersNew) {
    // arguments may be a String draft id (resume) or null (new).
    final draftId = settings.arguments is String
        ? settings.arguments as String
        : null;
    return MaterialPageRoute<void>(
      builder: (_) => CharacterCreatePage(draftId: draftId),
      settings: settings,
    );
  }

  if (name == AppRoutes.characterDetail) {
    final id = settings.arguments as String;
    return MaterialPageRoute<void>(
      builder: (_) => CharacterSheetPage(characterId: id),
      settings: settings,
    );
  }

  // ── Sessions feature ───────────────────────────────────────────────────

  if (name == AppRoutes.sessions) {
    return MaterialPageRoute<void>(
      builder: (_) => const SessionsListPage(),
      settings: settings,
    );
  }

  if (name == AppRoutes.sessionDetail) {
    final id = settings.arguments as String;
    return MaterialPageRoute<void>(
      builder: (_) => SessionDetailPage(sessionId: id),
      settings: settings,
    );
  }

  // ── Ships feature ──────────────────────────────────────────────────────

  if (name == AppRoutes.ships) {
    return MaterialPageRoute<void>(
      builder: (_) => const ShipsListPage(),
      settings: settings,
    );
  }

  if (name == AppRoutes.shipsNew) {
    return MaterialPageRoute<void>(
      builder: (_) => ShipCreatePage(
        cubitFactory: () => getIt<ShipCreateCubit>(),
      ),
      settings: settings,
    );
  }

  if (name == AppRoutes.shipDetail) {
    final id = settings.arguments as String;
    return MaterialPageRoute<void>(
      builder: (_) => ShipSheetPage(shipId: id),
      settings: settings,
    );
  }

  // ── Combat feature ─────────────────────────────────────────────────────

  if (name == AppRoutes.combatTracker) {
    final args = settings.arguments as CombatTrackerArgs;
    return MaterialPageRoute<void>(
      builder: (_) => CombatTrackerPage(
        sessionId: args.sessionId,
        isGm: args.isGm,
        dpCount: args.dpCount,
        sessionCharacterIds: args.sessionCharacterIds,
        cubitFactory: () => getIt<ActiveCombatCubit>(),
      ),
      settings: settings,
    );
  }

  return null;
}
