import 'package:app_api_client/app_api_client.dart'
    show
        CharactersApi,
        DiceApi,
        EncountersApi,
        GameSessionsApi,
        RealtimeApi,
        standardSerializers;
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:coriolis_companion/features/auth/data/auth_api.dart';
import 'package:coriolis_companion/features/auth/domain/auth_repository.dart';
import 'package:coriolis_companion/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:coriolis_companion/features/characters/data/character_repository_impl.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/characters_list/characters_list_cubit.dart';
import 'package:coriolis_companion/features/rolls/data/roll_repository_impl.dart';
import 'package:coriolis_companion/features/rolls/domain/roll_repository.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/dice_roller/dice_roller_cubit.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/roll_history/roll_history_cubit.dart';
import 'package:coriolis_companion/features/combat/data/combat_repository_impl.dart';
import 'package:coriolis_companion/features/combat/domain/combat_repository.dart';
import 'package:coriolis_companion/features/sessions/data/session_repository_impl.dart';
import 'package:coriolis_companion/features/sessions/domain/session_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/session_detail/session_detail_cubit.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/sessions_list/sessions_list_cubit.dart';
import 'package:coriolis_companion/shared/auth/token_storage.dart';
import 'package:coriolis_companion/shared/config/app_config.dart';
import 'package:coriolis_companion/shared/network/api_client.dart';
import 'package:coriolis_companion/shared/realtime/session_realtime.dart';

/// Global service locator. All runtime dependencies register here; widgets
/// resolve blocs via `BlocProvider(create: (_) => getIt<FooBloc>())` and
/// MUST NOT call `getIt<T>()` inside `build()`.
final GetIt getIt = GetIt.instance;

/// Wires the composition root. Call once, before `runApp`.
///
/// Ports (interfaces) are registered as lazy singletons — features consume the
/// interface, not the implementation. Blocs/Cubits are factories — each
/// `BlocProvider` gets a fresh instance.
void configureDependencies() {
  if (getIt.isRegistered<AppConfig>()) {
    return;
  }

  // ── Infra singletons ────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<AppConfig>(AppConfig.fromEnv)
    ..registerLazySingleton<TokenStorage>(SecureTokenStorage.new)
    ..registerLazySingleton<Dio>(
      () => buildDio(
        config: getIt<AppConfig>(),
        tokenStorage: getIt<TokenStorage>(),
      ),
    );

  // ── Domain repository singletons ────────────────────────────────────────
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthApiImpl(
      dio: getIt<Dio>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  // ── Generated API singletons ─────────────────────────────────────────────
  getIt
    ..registerLazySingleton<CharactersApi>(
      () => CharactersApi(getIt<Dio>(), standardSerializers),
    )
    ..registerLazySingleton<DiceApi>(
      () => DiceApi(getIt<Dio>(), standardSerializers),
    )
    ..registerLazySingleton<GameSessionsApi>(
      () => GameSessionsApi(getIt<Dio>(), standardSerializers),
    )
    ..registerLazySingleton<RealtimeApi>(
      () => RealtimeApi(getIt<Dio>(), standardSerializers),
    )
    ..registerLazySingleton<EncountersApi>(
      () => EncountersApi(getIt<Dio>(), standardSerializers),
    );

  // ── Characters domain ────────────────────────────────────────────────────
  getIt.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(api: getIt<CharactersApi>()),
  );

  // ── Rolls domain (Phase 4 Feature 7.1) ───────────────────────────────────
  getIt.registerLazySingleton<RollRepository>(
    () => RollRepositoryImpl(api: getIt<DiceApi>()),
  );

  // ── Sessions domain (Phase 4 Features 7.2 + 7.3) ─────────────────────────
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(api: getIt<GameSessionsApi>()),
  );

  // ── Combat domain (Phase 6 Block 1) ──────────────────────────────────────
  getIt.registerLazySingleton<CombatRepository>(
    () => CombatRepositoryImpl(api: getIt<EncountersApi>()),
  );

  // ── Cubit factories ─────────────────────────────────────────────────────
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepository>()),
  );

  getIt.registerFactory<CharactersListCubit>(
    () => CharactersListCubit(getIt<CharacterRepository>()),
  );

  getIt.registerFactory<CharacterSheetCubit>(
    () => CharacterSheetCubit(repository: getIt<CharacterRepository>()),
  );

  getIt.registerFactory<CharacterWizardCubit>(
    () => CharacterWizardCubit(repository: getIt<CharacterRepository>()),
  );

  getIt
    ..registerFactory<DiceRollerCubit>(
      () => DiceRollerCubit(repository: getIt<RollRepository>()),
    )
    ..registerFactory<RollHistoryCubit>(
      () => RollHistoryCubit(repository: getIt<RollRepository>()),
    )
    ..registerFactory<SessionsListCubit>(
      () => SessionsListCubit(repository: getIt<SessionRepository>()),
    )
    ..registerFactory<SessionDetailCubit>(
      () => SessionDetailCubit(
        repository: getIt<SessionRepository>(),
        realtime: SessionRealtime(
          realtimeApi: getIt<RealtimeApi>(),
          config: getIt<AppConfig>(),
        ),
      ),
    );
}

/// Test-only reset hook. Call in `tearDown` to drop singletons between cases.
Future<void> resetInjector() => getIt.reset();
