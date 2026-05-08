//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_range_enum.g.dart';

class ItemRangeEnum extends EnumClass {

  /// Effective range band for a weapon. Matches the Coriolis core book range terminology: - `arm` — Engaged / hand-to-hand. - `near` — same room / close quarters. - `short` — corridor / street distance. - `long` — open ground / rooftop. - `distant` — sniper range. 
  @BuiltValueEnumConst(wireName: r'arm')
  static const ItemRangeEnum arm = _$arm;
  /// Effective range band for a weapon. Matches the Coriolis core book range terminology: - `arm` — Engaged / hand-to-hand. - `near` — same room / close quarters. - `short` — corridor / street distance. - `long` — open ground / rooftop. - `distant` — sniper range. 
  @BuiltValueEnumConst(wireName: r'near')
  static const ItemRangeEnum near = _$near;
  /// Effective range band for a weapon. Matches the Coriolis core book range terminology: - `arm` — Engaged / hand-to-hand. - `near` — same room / close quarters. - `short` — corridor / street distance. - `long` — open ground / rooftop. - `distant` — sniper range. 
  @BuiltValueEnumConst(wireName: r'short')
  static const ItemRangeEnum short = _$short;
  /// Effective range band for a weapon. Matches the Coriolis core book range terminology: - `arm` — Engaged / hand-to-hand. - `near` — same room / close quarters. - `short` — corridor / street distance. - `long` — open ground / rooftop. - `distant` — sniper range. 
  @BuiltValueEnumConst(wireName: r'long')
  static const ItemRangeEnum long = _$long;
  /// Effective range band for a weapon. Matches the Coriolis core book range terminology: - `arm` — Engaged / hand-to-hand. - `near` — same room / close quarters. - `short` — corridor / street distance. - `long` — open ground / rooftop. - `distant` — sniper range. 
  @BuiltValueEnumConst(wireName: r'distant')
  static const ItemRangeEnum distant = _$distant;

  static Serializer<ItemRangeEnum> get serializer => _$itemRangeEnumSerializer;

  const ItemRangeEnum._(String name): super(name);

  static BuiltSet<ItemRangeEnum> get values => _$values;
  static ItemRangeEnum valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ItemRangeEnumMixin = Object with _$ItemRangeEnumMixin;

