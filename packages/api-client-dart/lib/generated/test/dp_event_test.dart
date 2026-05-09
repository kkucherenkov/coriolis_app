import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for DpEvent
void main() {
  final instance = DpEventBuilder();
  // TODO add properties to the builder and call build()

  group(DpEvent, () {
    // Opaque event identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Session the event belongs to
    // String gameSessionId
    test('to test the property `gameSessionId`', () async {
      // TODO
    });

    // How many DP were added (positive) or removed (negative)
    // int delta
    test('to test the property `delta`', () async {
      // TODO
    });

    // Optional human-readable reason
    // String reason
    test('to test the property `reason`', () async {
      // TODO
    });

    // DpSource source_
    test('to test the property `source_`', () async {
      // TODO
    });

    // Roll identifier when source is roll-push
    // String rollId
    test('to test the property `rollId`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

  });
}
