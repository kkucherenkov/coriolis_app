import 'package:app_api_client/app_api_client.dart'
    show
        CharactersApi,
        ChatApi,
        DiceApi,
        EncountersApi,
        GameSessionsApi,
        MeApi,
        MembershipsApi,
        NpcsApi,
        RealtimeApi,
        ShipsApi,
        standardSerializers;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:coriolis_companion/features/auth/data/auth_api.dart';
import 'package:coriolis_companion/features/auth/domain/auth_repository.dart';
import 'package:coriolis_companion/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:coriolis_companion/features/characters/data/cached_character_repository.dart';
import 'package:coriolis_companion/features/characters/data/character_cache.dart';
import 'package:coriolis_companion/features/characters/data/character_repository_impl.dart';
import 'package:coriolis_companion/features/characters/data/drift_character_cache.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/characters_list/characters_list_cubit.dart';
import 'package:coriolis_companion/features/rolls/data/roll_repository_impl.dart';
import 'package:coriolis_companion/features/rolls/domain/roll_repository.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/dice_roller/dice_roller_cubit.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/roll_history/roll_history_cubit.dart';
import 'package:coriolis_companion/features/combat/data/combat_repository_impl.dart';
import 'package:coriolis_companion/features/combat/domain/combat_repository.dart';
import 'package:coriolis_companion/features/npcs/data/cached_npc_repository.dart';
import 'package:coriolis_companion/features/npcs/data/drift_npc_cache.dart';
import 'package:coriolis_companion/features/npcs/data/npc_cache.dart';
import 'package:coriolis_companion/features/npcs/data/npc_repository_impl.dart';
import 'package:coriolis_companion/features/npcs/domain/npc_repository.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_cubit.dart';
import 'package:coriolis_companion/features/game_sessions/data/cached_session_repository.dart';
import 'package:coriolis_companion/features/game_sessions/data/drift_game_session_cache.dart';
import 'package:coriolis_companion/features/game_sessions/data/game_session_cache.dart';
import 'package:coriolis_companion/features/game_sessions/data/session_repository_impl.dart';
import 'package:coriolis_companion/features/game_sessions/domain/session_repository.dart';
import 'package:coriolis_companion/features/game_sessions/presentation/blocs/session_detail/session_detail_cubit.dart';
import 'package:coriolis_companion/features/game_sessions/presentation/blocs/sessions_list/sessions_list_cubit.dart';
import 'package:coriolis_companion/features/sessions/data/cached_player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/data/drift_player_membership_cache.dart';
import 'package:coriolis_companion/features/sessions/data/player_membership_cache.dart';
import 'package:coriolis_companion/features/sessions/data/player_session_repository_impl.dart';
import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/data/chat_realtime_service_impl.dart';
import 'package:coriolis_companion/features/sessions/data/chat_repository_impl.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_realtime_service.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_repository.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/join_session/join_session_cubit.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_cubit.dart';
import 'package:coriolis_companion/features/ships/data/cached_ship_repository.dart';
import 'package:coriolis_companion/features/ships/data/drift_ship_cache.dart';
import 'package:coriolis_companion/features/ships/data/ship_cache.dart';
import 'package:coriolis_companion/features/ships/data/ship_repository_impl.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_create/ship_create_cubit.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ship_sheet/ship_sheet_cubit.dart';
import 'package:coriolis_companion/features/ships/presentation/blocs/ships_list/ships_list_cubit.dart';
import 'package:coriolis_companion/shared/auth/token_storage.dart';
import 'package:coriolis_companion/shared/config/app_config.dart';
import 'package:coriolis_companion/shared/network/api_client.dart';
import 'package:coriolis_companion/shared/queue/drift_mutation_queue.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue_drainer.dart';
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
    ..registerLazySingleton<TokenStorage>(SecureTokenStorage.new);

  // AppDatabase may have been pre-registered by configureDependenciesForTesting.
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);
  }

  getIt.registerLazySingleton<LocalCharacterCache>(
    () => DriftCharacterCache(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<LocalPlayerMembershipCache>(
    () => DriftPlayerMembershipCache(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<LocalShipCache>(
    () => DriftShipCache(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<LocalGameSessionCache>(
    () => DriftGameSessionCache(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<LocalNpcCache>(
    () => DriftNpcCache(getIt<AppDatabase>()),
  );

  // Connectivity singleton — shared by the queue interceptor and the drainer.
  // May have been pre-registered by configureDependenciesForTesting.
  if (!getIt.isRegistered<Connectivity>()) {
    getIt.registerLazySingleton<Connectivity>(Connectivity.new);
  }

  // Offline mutation queue (Phase 7 / Feature 10.2 / T-10.2.b).
  // May have been pre-registered by configureDependenciesForTesting.
  if (!getIt.isRegistered<LocalMutationQueue>()) {
    getIt.registerLazySingleton<LocalMutationQueue>(
      () => DriftMutationQueue(getIt<AppDatabase>()),
    );
  }

  getIt
    ..registerLazySingleton<Dio>(
      () => buildDio(
        config: getIt<AppConfig>(),
        tokenStorage: getIt<TokenStorage>(),
        characterCache: getIt<LocalCharacterCache>(),
        membershipCache: getIt<LocalPlayerMembershipCache>(),
        shipCache: getIt<LocalShipCache>(),
        gameSessionCache: getIt<LocalGameSessionCache>(),
        npcCache: getIt<LocalNpcCache>(),
        mutationQueue: getIt<LocalMutationQueue>(),
        connectivity: getIt<Connectivity>(),
      ),
    )
    ..registerLazySingleton<MutationQueueDrainer>(
      () => MutationQueueDrainer(
        queue: getIt<LocalMutationQueue>(),
        dio: getIt<Dio>(),
        connectivity: getIt<Connectivity>(),
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
    ..registerLazySingleton<NpcsApi>(
      () => NpcsApi(getIt<Dio>(), standardSerializers),
    )
    ..registerLazySingleton<RealtimeApi>(
      () => RealtimeApi(getIt<Dio>(), standardSerializers),
    )
    ..registerLazySingleton<EncountersApi>(
      () => EncountersApi(getIt<Dio>(), standardSerializers),
    )
    ..registerLazySingleton<ShipsApi>(
      () => ShipsApi(getIt<Dio>(), standardSerializers),
    )
    ..registerLazySingleton<MembershipsApi>(
      () => MembershipsApi(getIt<Dio>(), standardSerializers),
    )
    ..registerLazySingleton<MeApi>(
      () => MeApi(getIt<Dio>(), standardSerializers),
    )
    ..registerLazySingleton<ChatApi>(
      () => ChatApi(getIt<Dio>(), standardSerializers),
    );

  // ── Characters domain ────────────────────────────────────────────────────
  getIt.registerLazySingleton<CharacterRepository>(
    () => CachedCharacterRepository(
      remote: CharacterRepositoryImpl(api: getIt<CharactersApi>()),
      cache: getIt<LocalCharacterCache>(),
    ),
  );

  // ── Rolls domain (Phase 4 Feature 7.1) ───────────────────────────────────
  getIt.registerLazySingleton<RollRepository>(
    () => RollRepositoryImpl(api: getIt<DiceApi>()),
  );

  // ── Sessions domain (Phase 4 Features 7.2 + 7.3) ─────────────────────────
  getIt.registerLazySingleton<SessionRepository>(
    () => CachedSessionRepository(
      remote: SessionRepositoryImpl(api: getIt<GameSessionsApi>()),
      cache: getIt<LocalGameSessionCache>(),
    ),
  );

  // ── NPCs domain (T-MOBILE-NPC-PICKER, T-2026-05-17-PHASE-7-MOBILE-OFFLINE-4) ─
  getIt.registerLazySingleton<NpcRepository>(
    () => CachedNpcRepository(
      remote: NpcRepositoryImpl(api: getIt<NpcsApi>()),
      cache: getIt<LocalNpcCache>(),
    ),
  );

  // ── Combat domain (Phase 6 Block 1) ──────────────────────────────────────
  getIt.registerLazySingleton<CombatRepository>(
    () => CombatRepositoryImpl(api: getIt<EncountersApi>()),
  );

  getIt.registerFactory<ActiveCombatCubit>(
    () => ActiveCombatCubit(repository: getIt<CombatRepository>()),
  );

  // ── Ships domain (T-MOBILE-SHIP-SHEET, T-2026-05-14-005) ─────────────────
  getIt.registerLazySingleton<ShipRepository>(
    () => CachedShipRepository(
      remote: ShipRepositoryImpl(api: getIt<ShipsApi>()),
      cache: getIt<LocalShipCache>(),
    ),
  );

  getIt
    ..registerFactory<ShipsListCubit>(
      () => ShipsListCubit(getIt<ShipRepository>()),
    )
    ..registerFactory<ShipSheetCubit>(
      () => ShipSheetCubit(repository: getIt<ShipRepository>()),
    )
    ..registerFactory<ShipCreateCubit>(
      () => ShipCreateCubit(repository: getIt<ShipRepository>()),
    );

  // ── Chat domain (Phase 8 Stream D) ──────────────────────────────────────
  getIt
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(
        chatApi: getIt<ChatApi>(),
        gameSessionsApi: getIt<GameSessionsApi>(),
      ),
    )
    ..registerFactory<ChatRealtimeService>(
      () => ChatRealtimeServiceImpl(
        realtimeApi: getIt<RealtimeApi>(),
        config: getIt<AppConfig>(),
      ),
    );

  // ── Player sessions domain (Phase 8 Stream B) ────────────────────────────
  getIt
    ..registerLazySingleton<PlayerSessionRepository>(
      () => CachedPlayerSessionRepository(
        remote: PlayerSessionRepositoryImpl(
          membershipsApi: getIt<MembershipsApi>(),
          meApi: getIt<MeApi>(),
          gameSessionsApi: getIt<GameSessionsApi>(),
        ),
        cache: getIt<LocalPlayerMembershipCache>(),
      ),
    )
    ..registerFactory<PlayerSessionsListCubit>(
      () => PlayerSessionsListCubit(
        repository: getIt<PlayerSessionRepository>(),
      ),
    )
    ..registerFactory<JoinSessionCubit>(
      () => JoinSessionCubit(repository: getIt<PlayerSessionRepository>()),
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

/// Test-only DI bootstrap.
///
/// Allows tests to supply in-memory / mock substitutes before the normal
/// composition root runs. All parameters are optional; callers that only need
/// a [appDatabase] override keep compiling without changes.
///
/// - [appDatabase]: in-memory Drift DB (`AppDatabase.forTesting(NativeDatabase.memory())`).
/// - [connectivity]: mock connectivity (avoids platform-channel access in unit tests).
/// - [mutationQueue]: in-memory queue implementation (avoids disk I/O in unit tests).
/// - [shipCache]: override for [LocalShipCache] (avoids disk I/O in unit tests).
/// - [gameSessionCache]: override for [LocalGameSessionCache] (avoids disk I/O in unit tests).
/// - [npcCache]: override for [LocalNpcCache] (avoids disk I/O in unit tests).
void configureDependenciesForTesting({
  AppDatabase? appDatabase,
  Connectivity? connectivity,
  LocalMutationQueue? mutationQueue,
  LocalShipCache? shipCache,
  LocalGameSessionCache? gameSessionCache,
  LocalNpcCache? npcCache,
}) {
  if (appDatabase != null && !getIt.isRegistered<AppDatabase>()) {
    getIt.registerSingleton<AppDatabase>(appDatabase);
  }
  if (connectivity != null && !getIt.isRegistered<Connectivity>()) {
    getIt.registerSingleton<Connectivity>(connectivity);
  }
  if (mutationQueue != null && !getIt.isRegistered<LocalMutationQueue>()) {
    getIt.registerSingleton<LocalMutationQueue>(mutationQueue);
  }
  if (shipCache != null && !getIt.isRegistered<LocalShipCache>()) {
    getIt.registerSingleton<LocalShipCache>(shipCache);
  }
  if (gameSessionCache != null && !getIt.isRegistered<LocalGameSessionCache>()) {
    getIt.registerSingleton<LocalGameSessionCache>(gameSessionCache);
  }
  if (npcCache != null && !getIt.isRegistered<LocalNpcCache>()) {
    getIt.registerSingleton<LocalNpcCache>(npcCache);
  }
  configureDependencies();
}

/// Test-only reset hook. Call in `tearDown` to drop singletons between cases.
Future<void> resetInjector() => getIt.reset();
