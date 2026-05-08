import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for Attributes
void main() {
  final instance = AttributesBuilder();
  // TODO add properties to the builder and call build()

  group(Attributes, () {
    // STR — governs Force, Melee Combat skills and HP max
    // int strength
    test('to test the property `strength`', () async {
      // TODO
    });

    // AGI — governs Dexterity, Infiltration, Ranged Combat, Pilot; contributes to HP max
    // int agility
    test('to test the property `agility`', () async {
      // TODO
    });

    // WIT — governs Observation, Survival, Technology, Data Djinn, Science, Medicurgy; contributes to MP max
    // int wits
    test('to test the property `wits`', () async {
      // TODO
    });

    // EMP — governs Manipulation, Command, Culture, Mystic Powers; contributes to MP max
    // int empathy
    test('to test the property `empathy`', () async {
      // TODO
    });

  });
}
