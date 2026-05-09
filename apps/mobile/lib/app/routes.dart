import 'package:flutter/material.dart';

import 'package:coriolis_companion/features/auth/presentation/sign_in_screen.dart';
import 'package:coriolis_companion/features/auth/presentation/sign_up_screen.dart';
import 'package:coriolis_companion/features/auth/presentation/welcome_screen.dart';
import 'package:coriolis_companion/features/characters/presentation/pages/character_create_page.dart';
import 'package:coriolis_companion/features/characters/presentation/pages/character_sheet_page.dart';
import 'package:coriolis_companion/features/characters/presentation/pages/characters_list_page.dart';
import 'package:coriolis_companion/features/settings/presentation/settings_screen.dart';

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

  return null;
}
