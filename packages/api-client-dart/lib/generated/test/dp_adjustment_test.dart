import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for DpAdjustment
void main() {
  final instance = DpAdjustmentBuilder();
  // TODO add properties to the builder and call build()

  group(DpAdjustment, () {
    // Positive to add DP, negative to remove DP. Must be non-zero. A negative delta is only accepted from the GM owner of the session. 
    // int delta
    test('to test the property `delta`', () async {
      // TODO
    });

    // Optional human-readable reason for the adjustment
    // String reason
    test('to test the property `reason`', () async {
      // TODO
    });

  });
}
