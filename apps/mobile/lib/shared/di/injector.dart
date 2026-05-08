import 'package:app_api_client/app_api_client.dart' show CharactersApi, standardSerializers;
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:app_mobile/features/auth/data/auth_api.dart';
import 'package:app_mobile/features/auth/domain/auth_repository.dart';
import 'package:app_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:app_mobile/features/characters/data/character_repository_impl.dart';
import 'package:app_mobile/features/characters/domain/character_repository.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:app_mobile/features/characters/presentation/blocs/characters_list/characters_list_cubit.dart';
import 'package:app_mobile/shared/auth/token_storage.dart';
import 'package:app_mobile/shared/config/app_config.dart';
import 'package:app_mobile/shared/network/api_client.dart';

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
  getIt.registerLazySingleton<CharactersApi>(
    () => CharactersApi(getIt<Dio>(), standardSerializers),
  );

  // ── Characters domain ────────────────────────────────────────────────────
  getIt.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(api: getIt<CharactersApi>()),
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
}

/// Test-only reset hook. Call in `tearDown` to drop singletons between cases.
Future<void> resetInjector() => getIt.reset();
