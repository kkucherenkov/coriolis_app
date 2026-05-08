//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_weapon_range.g.dart';

class ShipWeaponRange extends EnumClass {

  /// Ship-combat range bands per ST3001 ГЛАВА 7 Table 7.9. Distinct from the personal-scale `ItemRangeEnum`. - `zero` — point-blank / boarding range. - `close` — within a few hundred metres. - `medium` — standard engagement distance. - `long` — extended engagement. - `extreme` — maximum sensor range. 
  @BuiltValueEnumConst(wireName: r'zero')
  static const ShipWeaponRange zero = _$zero;
  /// Ship-combat range bands per ST3001 ГЛАВА 7 Table 7.9. Distinct from the personal-scale `ItemRangeEnum`. - `zero` — point-blank / boarding range. - `close` — within a few hundred metres. - `medium` — standard engagement distance. - `long` — extended engagement. - `extreme` — maximum sensor range. 
  @BuiltValueEnumConst(wireName: r'close')
  static const ShipWeaponRange close = _$close;
  /// Ship-combat range bands per ST3001 ГЛАВА 7 Table 7.9. Distinct from the personal-scale `ItemRangeEnum`. - `zero` — point-blank / boarding range. - `close` — within a few hundred metres. - `medium` — standard engagement distance. - `long` — extended engagement. - `extreme` — maximum sensor range. 
  @BuiltValueEnumConst(wireName: r'medium')
  static const ShipWeaponRange medium = _$medium;
  /// Ship-combat range bands per ST3001 ГЛАВА 7 Table 7.9. Distinct from the personal-scale `ItemRangeEnum`. - `zero` — point-blank / boarding range. - `close` — within a few hundred metres. - `medium` — standard engagement distance. - `long` — extended engagement. - `extreme` — maximum sensor range. 
  @BuiltValueEnumConst(wireName: r'long')
  static const ShipWeaponRange long = _$long;
  /// Ship-combat range bands per ST3001 ГЛАВА 7 Table 7.9. Distinct from the personal-scale `ItemRangeEnum`. - `zero` — point-blank / boarding range. - `close` — within a few hundred metres. - `medium` — standard engagement distance. - `long` — extended engagement. - `extreme` — maximum sensor range. 
  @BuiltValueEnumConst(wireName: r'extreme')
  static const ShipWeaponRange extreme = _$extreme;

  static Serializer<ShipWeaponRange> get serializer => _$shipWeaponRangeSerializer;

  const ShipWeaponRange._(String name): super(name);

  static BuiltSet<ShipWeaponRange> get values => _$values;
  static ShipWeaponRange valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ShipWeaponRangeMixin = Object with _$ShipWeaponRangeMixin;

