//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_slot_type.g.dart';

class ItemSlotType extends EnumClass {

  /// Ship module slot type. Used only for SHIP_MODULE items. Matches the slot categories from Coriolis core book ship construction rules. 
  @BuiltValueEnumConst(wireName: r'bridge')
  static const ItemSlotType bridge = _$bridge;
  /// Ship module slot type. Used only for SHIP_MODULE items. Matches the slot categories from Coriolis core book ship construction rules. 
  @BuiltValueEnumConst(wireName: r'hull')
  static const ItemSlotType hull = _$hull;
  /// Ship module slot type. Used only for SHIP_MODULE items. Matches the slot categories from Coriolis core book ship construction rules. 
  @BuiltValueEnumConst(wireName: r'hold')
  static const ItemSlotType hold = _$hold;
  /// Ship module slot type. Used only for SHIP_MODULE items. Matches the slot categories from Coriolis core book ship construction rules. 
  @BuiltValueEnumConst(wireName: r'weapon')
  static const ItemSlotType weapon = _$weapon;
  /// Ship module slot type. Used only for SHIP_MODULE items. Matches the slot categories from Coriolis core book ship construction rules. 
  @BuiltValueEnumConst(wireName: r'drive')
  static const ItemSlotType drive = _$drive;
  /// Ship module slot type. Used only for SHIP_MODULE items. Matches the slot categories from Coriolis core book ship construction rules. 
  @BuiltValueEnumConst(wireName: r'sensor')
  static const ItemSlotType sensor = _$sensor;
  /// Ship module slot type. Used only for SHIP_MODULE items. Matches the slot categories from Coriolis core book ship construction rules. 
  @BuiltValueEnumConst(wireName: r'comms')
  static const ItemSlotType comms = _$comms;

  static Serializer<ItemSlotType> get serializer => _$itemSlotTypeSerializer;

  const ItemSlotType._(String name): super(name);

  static BuiltSet<ItemSlotType> get values => _$values;
  static ItemSlotType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ItemSlotTypeMixin = Object with _$ItemSlotTypeMixin;

