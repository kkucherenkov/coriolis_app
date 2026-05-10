//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'combatant_type.g.dart';

class CombatantType extends EnumClass {

  /// Discriminator field that identifies the source entity type of a combatant.  - `pc` — references an existing `Character` owned by the encounter's GM   (or assigned to the parent `GameSession`). - `npc` — references an existing `Npc` owned by the GM. 
  @BuiltValueEnumConst(wireName: r'pc')
  static const CombatantType pc = _$pc;
  /// Discriminator field that identifies the source entity type of a combatant.  - `pc` — references an existing `Character` owned by the encounter's GM   (or assigned to the parent `GameSession`). - `npc` — references an existing `Npc` owned by the GM. 
  @BuiltValueEnumConst(wireName: r'npc')
  static const CombatantType npc = _$npc;

  static Serializer<CombatantType> get serializer => _$combatantTypeSerializer;

  const CombatantType._(String name): super(name);

  static BuiltSet<CombatantType> get values => _$values;
  static CombatantType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CombatantTypeMixin = Object with _$CombatantTypeMixin;

