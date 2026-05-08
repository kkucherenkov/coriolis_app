//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_weapon_range.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_weapon_update.g.dart';

/// PATCH payload for a WEAPON ship module. All fields optional.
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [weaponBonus] 
/// * [weaponRange] 
/// * [weaponDamage] 
/// * [weaponCritThreshold] 
/// * [notes] 
@BuiltValue()
abstract class ShipModuleWeaponUpdate implements Built<ShipModuleWeaponUpdate, ShipModuleWeaponUpdateBuilder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleWeaponUpdateSlotEnum? get slot;
  // enum slotEnum {  WEAPON,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'energyUse')
  int? get energyUse;

  @BuiltValueField(wireName: r'weaponBonus')
  int? get weaponBonus;

  @BuiltValueField(wireName: r'weaponRange')
  ShipWeaponRange? get weaponRange;
  // enum weaponRangeEnum {  zero,  close,  medium,  long,  extreme,  };

  @BuiltValueField(wireName: r'weaponDamage')
  int? get weaponDamage;

  @BuiltValueField(wireName: r'weaponCritThreshold')
  int? get weaponCritThreshold;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleWeaponUpdate._();

  factory ShipModuleWeaponUpdate([void updates(ShipModuleWeaponUpdateBuilder b)]) = _$ShipModuleWeaponUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleWeaponUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleWeaponUpdate> get serializer => _$ShipModuleWeaponUpdateSerializer();
}

class _$ShipModuleWeaponUpdateSerializer implements PrimitiveSerializer<ShipModuleWeaponUpdate> {
  @override
  final Iterable<Type> types = const [ShipModuleWeaponUpdate, _$ShipModuleWeaponUpdate];

  @override
  final String wireName = r'ShipModuleWeaponUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleWeaponUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.slot != null) {
      yield r'slot';
      yield serializers.serialize(
        object.slot,
        specifiedType: const FullType(ShipModuleWeaponUpdateSlotEnum),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.energyUse != null) {
      yield r'energyUse';
      yield serializers.serialize(
        object.energyUse,
        specifiedType: const FullType(int),
      );
    }
    if (object.weaponBonus != null) {
      yield r'weaponBonus';
      yield serializers.serialize(
        object.weaponBonus,
        specifiedType: const FullType(int),
      );
    }
    if (object.weaponRange != null) {
      yield r'weaponRange';
      yield serializers.serialize(
        object.weaponRange,
        specifiedType: const FullType(ShipWeaponRange),
      );
    }
    if (object.weaponDamage != null) {
      yield r'weaponDamage';
      yield serializers.serialize(
        object.weaponDamage,
        specifiedType: const FullType(int),
      );
    }
    if (object.weaponCritThreshold != null) {
      yield r'weaponCritThreshold';
      yield serializers.serialize(
        object.weaponCritThreshold,
        specifiedType: const FullType(int),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleWeaponUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleWeaponUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleWeaponUpdateSlotEnum),
          ) as ShipModuleWeaponUpdateSlotEnum;
          result.slot = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'energyUse':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.energyUse = valueDes;
          break;
        case r'weaponBonus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.weaponBonus = valueDes;
          break;
        case r'weaponRange':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipWeaponRange),
          ) as ShipWeaponRange;
          result.weaponRange = valueDes;
          break;
        case r'weaponDamage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.weaponDamage = valueDes;
          break;
        case r'weaponCritThreshold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.weaponCritThreshold = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShipModuleWeaponUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleWeaponUpdateBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class ShipModuleWeaponUpdateSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WEAPON')
  static const ShipModuleWeaponUpdateSlotEnum WEAPON = _$shipModuleWeaponUpdateSlotEnum_WEAPON;

  static Serializer<ShipModuleWeaponUpdateSlotEnum> get serializer => _$shipModuleWeaponUpdateSlotEnumSerializer;

  const ShipModuleWeaponUpdateSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleWeaponUpdateSlotEnum> get values => _$shipModuleWeaponUpdateSlotEnumValues;
  static ShipModuleWeaponUpdateSlotEnum valueOf(String name) => _$shipModuleWeaponUpdateSlotEnumValueOf(name);
}

