import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/shared/cache/app_database.dart';
import 'package:coriolis_companion/shared/di/injector.dart';
import 'package:coriolis_companion/shared/queue/drift_mutation_queue.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue_drainer.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue_interceptor.dart';

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

  test('LocalMutationQueue resolves as DriftMutationQueue', () {
    final queue = getIt<LocalMutationQueue>();
    expect(queue, isNotNull);
    expect(queue, isA<DriftMutationQueue>());
  });

  test('MutationQueueDrainer resolves and is a singleton', () {
    final drainer1 = getIt<MutationQueueDrainer>();
    final drainer2 = getIt<MutationQueueDrainer>();
    expect(drainer1, isNotNull);
    expect(identical(drainer1, drainer2), isTrue);
  });

  test('Dio interceptors contain exactly one MutationQueueInterceptor', () {
    final dio = getIt<Dio>();
    final count =
        dio.interceptors.whereType<MutationQueueInterceptor>().length;
    expect(count, equals(1));
  });
}
