//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_module_base.dart';
import 'package:app_api_client/src/model/ship_weapon_range.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:app_api_client/src/model/ship_module_slot.dart';

part 'ship_module_weapon.g.dart';

/// ShipModuleWeapon
///
/// Properties:
/// * [id] - Opaque module identifier (cuid2)
/// * [slot] 
/// * [name] - Module name (e.g. \"Graviton Projector\", \"Smuggler hold\")
/// * [energyUse] - Energy points consumed by this module when active
/// * [notes] - Free-text notes; used for damage state, special conditions, etc.
/// * [weaponBonus] - Modifier dice added to the attack pool (Мод. column in Table 7.9)
/// * [weaponRange] 
/// * [weaponDamage] - Structural damage dealt on a hit
/// * [weaponCritThreshold] - Number of successes required to trigger a critical effect
@BuiltValue()
abstract class ShipModuleWeapon implements ShipModuleBase, Built<ShipModuleWeapon, ShipModuleWeaponBuilder> {
  @BuiltValueField(wireName: r'weaponRange')
  ShipWeaponRange get weaponRange;
  // enum weaponRangeEnum {  zero,  close,  medium,  long,  extreme,  };

  /// Modifier dice added to the attack pool (Мод. column in Table 7.9)
  @BuiltValueField(wireName: r'weaponBonus')
  int get weaponBonus;

  /// Number of successes required to trigger a critical effect
  @BuiltValueField(wireName: r'weaponCritThreshold')
  int get weaponCritThreshold;

  /// Structural damage dealt on a hit
  @BuiltValueField(wireName: r'weaponDamage')
  int get weaponDamage;

  ShipModuleWeapon._();

  factory ShipModuleWeapon([void updates(ShipModuleWeaponBuilder b)]) = _$ShipModuleWeapon;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleWeaponBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleWeapon> get serializer => _$ShipModuleWeaponSerializer();
}

class _$ShipModuleWeaponSerializer implements PrimitiveSerializer<ShipModuleWeapon> {
  @override
  final Iterable<Type> types = const [ShipModuleWeapon, _$ShipModuleWeapon];

  @override
  final String wireName = r'ShipModuleWeapon';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleWeapon object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'weaponRange';
    yield serializers.serialize(
      object.weaponRange,
      specifiedType: const FullType(ShipWeaponRange),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'weaponBonus';
    yield serializers.serialize(
      object.weaponBonus,
      specifiedType: const FullType(int),
    );
    yield r'weaponCritThreshold';
    yield serializers.serialize(
      object.weaponCritThreshold,
      specifiedType: const FullType(int),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleSlot),
    );
    yield r'weaponDamage';
    yield serializers.serialize(
      object.weaponDamage,
      specifiedType: const FullType(int),
    );
    yield r'energyUse';
    yield serializers.serialize(
      object.energyUse,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleWeapon object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleWeaponBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'weaponRange':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipWeaponRange),
          ) as ShipWeaponRange;
          result.weaponRange = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'weaponBonus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.weaponBonus = valueDes;
          break;
        case r'weaponCritThreshold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.weaponCritThreshold = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleSlot),
          ) as ShipModuleSlot;
          result.slot = valueDes;
          break;
        case r'weaponDamage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.weaponDamage = valueDes;
          break;
        case r'energyUse':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.energyUse = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShipModuleWeapon deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleWeaponBuilder();
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

class ShipModuleWeaponSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WEAPON')
  static const ShipModuleWeaponSlotEnum WEAPON = _$shipModuleWeaponSlotEnum_WEAPON;

  static Serializer<ShipModuleWeaponSlotEnum> get serializer => _$shipModuleWeaponSlotEnumSerializer;

  const ShipModuleWeaponSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleWeaponSlotEnum> get values => _$shipModuleWeaponSlotEnumValues;
  static ShipModuleWeaponSlotEnum valueOf(String name) => _$shipModuleWeaponSlotEnumValueOf(name);
}

