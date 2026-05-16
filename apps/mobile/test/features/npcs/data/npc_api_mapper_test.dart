import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/npcs/data/npc_api_mapper.dart';

api_client.Npc _wire() => api_client.Npc((b) => b
  ..id = 'npc-42'
  ..ownerId = 'user-1'
  ..name = 'The Emissary'
  ..updatedAt = DateTime.utc(2026, 5, 17)
  ..createdAt = DateTime.utc(2026, 5, 17)
  ..attributes.update((ab) => ab
    ..strength = 2
    ..agility = 2
    ..wits = 3
    ..empathy = 3)
  ..skills.update((sb) => sb
    ..dexterity = 0
    ..force = 0
    ..infiltration = 0
    ..manipulation = 2
    ..meleeCombat = 0
    ..observation = 1
    ..rangedCombat = 0
    ..survival = 0
    ..command = 1
    ..culture = 1
    ..dataDjinn = 0
    ..medicurgy = 0
    ..mysticPowers = 0
    ..pilot = 0
    ..science = 0
    ..technology = 0)
  ..hp.update((hb) => hb
    ..current = 4
    ..max = 4)
  ..mp.update((mb) => mb
    ..current = 6
    ..max = 6)
  ..armor.replace(BuiltList<api_client.ItemArmor>())
  ..weapons.replace(BuiltList<api_client.ItemWeapon>())
  ..tags.replace(BuiltList<String>()));

void main() {
  test('fromWire maps id and name from a sample wire Npc', () {
    final summary = NpcApiMapper.fromWire(_wire());
    expect(summary.id, 'npc-42');
    expect(summary.name, 'The Emissary');
  });
}
