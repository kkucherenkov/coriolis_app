import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/game_sessions/data/cached_session_repository.dart';
import 'package:coriolis_companion/features/game_sessions/data/game_session_cache.dart';
import 'package:coriolis_companion/features/ships/data/cached_ship_repository.dart';
import 'package:coriolis_companion/features/ships/data/ship_cache.dart';
import 'package:coriolis_companion/features/game_sessions/domain/session_repository.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';
import 'package:coriolis_companion/shared/cache/app_database.dart';
import 'package:coriolis_companion/shared/di/injector.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());

    configureDependenciesForTesting(
      appDatabase: AppDatabase.forTesting(NativeDatabase.memory()),
      connectivity: mockConnectivity,
    );
  });

  tearDown(() async => resetInjector());

  test('LocalShipCache and LocalGameSessionCache are registered', () {
    expect(getIt<LocalShipCache>(), isNotNull);
    expect(getIt<LocalGameSessionCache>(), isNotNull);
  });

  test('ShipRepository resolves as CachedShipRepository', () {
    final repo = getIt<ShipRepository>();
    expect(repo, isA<CachedShipRepository>());
  });

  test('SessionRepository resolves as CachedSessionRepository', () {
    final repo = getIt<SessionRepository>();
    expect(repo, isA<CachedSessionRepository>());
  });
}
