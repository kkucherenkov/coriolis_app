//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'encounter_status.g.dart';

class EncounterStatus extends EnumClass {

  /// Lifecycle state of an encounter (combat tracker).  - `setup` — the GM is building the encounter. Combatants can be   added or removed freely. Initiative has not been rolled. `round`   is 0 and `activeCombatantId` is null. - `active` — combat has started. Initiative is rolled, turn order   is locked. `round` is bumped to 1 on the `setup → active`   transition and advances with each full rotation. `activeCombatantId`   points to the combatant whose turn it is. Combatant mutations are   only possible through the GM-driven turn-advance and   initiative-reorder operations (Block 4). - `ended` — combat is resolved. The encounter is read-only history.   `activeCombatantId` is reset to null.  **Allowed transitions:** `setup → active`, `active → ended`. No reverse transitions and no skipping states are permitted. Historical (`ended`) encounters are archived and immutable. 
  @BuiltValueEnumConst(wireName: r'setup')
  static const EncounterStatus setup = _$setup;
  /// Lifecycle state of an encounter (combat tracker).  - `setup` — the GM is building the encounter. Combatants can be   added or removed freely. Initiative has not been rolled. `round`   is 0 and `activeCombatantId` is null. - `active` — combat has started. Initiative is rolled, turn order   is locked. `round` is bumped to 1 on the `setup → active`   transition and advances with each full rotation. `activeCombatantId`   points to the combatant whose turn it is. Combatant mutations are   only possible through the GM-driven turn-advance and   initiative-reorder operations (Block 4). - `ended` — combat is resolved. The encounter is read-only history.   `activeCombatantId` is reset to null.  **Allowed transitions:** `setup → active`, `active → ended`. No reverse transitions and no skipping states are permitted. Historical (`ended`) encounters are archived and immutable. 
  @BuiltValueEnumConst(wireName: r'active')
  static const EncounterStatus active = _$active;
  /// Lifecycle state of an encounter (combat tracker).  - `setup` — the GM is building the encounter. Combatants can be   added or removed freely. Initiative has not been rolled. `round`   is 0 and `activeCombatantId` is null. - `active` — combat has started. Initiative is rolled, turn order   is locked. `round` is bumped to 1 on the `setup → active`   transition and advances with each full rotation. `activeCombatantId`   points to the combatant whose turn it is. Combatant mutations are   only possible through the GM-driven turn-advance and   initiative-reorder operations (Block 4). - `ended` — combat is resolved. The encounter is read-only history.   `activeCombatantId` is reset to null.  **Allowed transitions:** `setup → active`, `active → ended`. No reverse transitions and no skipping states are permitted. Historical (`ended`) encounters are archived and immutable. 
  @BuiltValueEnumConst(wireName: r'ended')
  static const EncounterStatus ended = _$ended;

  static Serializer<EncounterStatus> get serializer => _$encounterStatusSerializer;

  const EncounterStatus._(String name): super(name);

  static BuiltSet<EncounterStatus> get values => _$values;
  static EncounterStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class EncounterStatusMixin = Object with _$EncounterStatusMixin;

