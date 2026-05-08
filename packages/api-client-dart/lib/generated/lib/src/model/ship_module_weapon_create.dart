//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_weapon_range.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_weapon_create.g.dart';

/// Create payload for a WEAPON ship module. No `id` — server-assigned.
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [weaponBonus] - Modifier dice added to the attack pool
/// * [weaponRange] 
/// * [weaponDamage] - Structural damage dealt on a hit
/// * [weaponCritThreshold] - Number of successes required to trigger a critical effect
/// * [notes] 
@BuiltValue()
abstract class ShipModuleWeaponCreate implements Built<ShipModuleWeaponCreate, ShipModuleWeaponCreateBuilder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleWeaponCreateSlotEnum get slot;
  // enum slotEnum {  WEAPON,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  /// Modifier dice added to the attack pool
  @BuiltValueField(wireName: r'weaponBonus')
  int get weaponBonus;

  @BuiltValueField(wireName: r'weaponRange')
  ShipWeaponRange get weaponRange;
  // enum weaponRangeEnum {  zero,  close,  medium,  long,  extreme,  };

  /// Structural damage dealt on a hit
  @BuiltValueField(wireName: r'weaponDamage')
  int get weaponDamage;

  /// Number of successes required to trigger a critical effect
  @BuiltValueField(wireName: r'weaponCritThreshold')
  int get weaponCritThreshold;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleWeaponCreate._();

  factory ShipModuleWeaponCreate([void updates(ShipModuleWeaponCreateBuilder b)]) = _$ShipModuleWeaponCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleWeaponCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleWeaponCreate> get serializer => _$ShipModuleWeaponCreateSerializer();
}

class _$ShipModuleWeaponCreateSerializer implements PrimitiveSerializer<ShipModuleWeaponCreate> {
  @override
  final Iterable<Type> types = const [ShipModuleWeaponCreate, _$ShipModuleWeaponCreate];

  @override
  final String wireName = r'ShipModuleWeaponCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleWeaponCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleWeaponCreateSlotEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'energyUse';
    yield serializers.serialize(
      object.energyUse,
      specifiedType: const FullType(int),
    );
    yield r'weaponBonus';
    yield serializers.serialize(
      object.weaponBonus,
      specifiedType: const FullType(int),
    );
    yield r'weaponRange';
    yield serializers.serialize(
      object.weaponRange,
      specifiedType: const FullType(ShipWeaponRange),
    );
    yield r'weaponDamage';
    yield serializers.serialize(
      object.weaponDamage,
      specifiedType: const FullType(int),
    );
    yield r'weaponCritThreshold';
    yield serializers.serialize(
      object.weaponCritThreshold,
      specifiedType: const FullType(int),
    );
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
    ShipModuleWeaponCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleWeaponCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleWeaponCreateSlotEnum),
          ) as ShipModuleWeaponCreateSlotEnum;
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
  ShipModuleWeaponCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleWeaponCreateBuilder();
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

class ShipModuleWeaponCreateSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WEAPON')
  static const ShipModuleWeaponCreateSlotEnum WEAPON = _$shipModuleWeaponCreateSlotEnum_WEAPON;

  static Serializer<ShipModuleWeaponCreateSlotEnum> get serializer => _$shipModuleWeaponCreateSlotEnumSerializer;

  const ShipModuleWeaponCreateSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleWeaponCreateSlotEnum> get values => _$shipModuleWeaponCreateSlotEnumValues;
  static ShipModuleWeaponCreateSlotEnum valueOf(String name) => _$shipModuleWeaponCreateSlotEnumValueOf(name);
}

