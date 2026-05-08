//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/ship_weapon_range.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_update.g.dart';

/// PATCH payload for `PATCH /api/v1/ship-modules/{id}`. The `slot` discriminator may not be changed after installation. All fields optional. 
///
/// Properties:
/// * [name] 
/// * [energyUse] 
/// * [notes] 
/// * [weaponBonus] - WEAPON only
/// * [weaponRange] - WEAPON only
/// * [weaponDamage] - WEAPON only
/// * [weaponCritThreshold] - WEAPON only
/// * [torpedoCount] - TORPEDO only
/// * [mineCount] - TORPEDO only
/// * [cargoTons] - HOLD only
/// * [concealed] - HOLD only
/// * [detectionBonus] - SENSOR only
@BuiltValue()
abstract class ShipModuleUpdate implements Built<ShipModuleUpdate, ShipModuleUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'energyUse')
  int? get energyUse;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// WEAPON only
  @BuiltValueField(wireName: r'weaponBonus')
  int? get weaponBonus;

  /// WEAPON only
  @BuiltValueField(wireName: r'weaponRange')
  ShipWeaponRange? get weaponRange;
  // enum weaponRangeEnum {  zero,  close,  medium,  long,  extreme,  };

  /// WEAPON only
  @BuiltValueField(wireName: r'weaponDamage')
  int? get weaponDamage;

  /// WEAPON only
  @BuiltValueField(wireName: r'weaponCritThreshold')
  int? get weaponCritThreshold;

  /// TORPEDO only
  @BuiltValueField(wireName: r'torpedoCount')
  int? get torpedoCount;

  /// TORPEDO only
  @BuiltValueField(wireName: r'mineCount')
  int? get mineCount;

  /// HOLD only
  @BuiltValueField(wireName: r'cargoTons')
  int? get cargoTons;

  /// HOLD only
  @BuiltValueField(wireName: r'concealed')
  bool? get concealed;

  /// SENSOR only
  @BuiltValueField(wireName: r'detectionBonus')
  int? get detectionBonus;

  ShipModuleUpdate._();

  factory ShipModuleUpdate([void updates(ShipModuleUpdateBuilder b)]) = _$ShipModuleUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleUpdate> get serializer => _$ShipModuleUpdateSerializer();
}

class _$ShipModuleUpdateSerializer implements PrimitiveSerializer<ShipModuleUpdate> {
  @override
  final Iterable<Type> types = const [ShipModuleUpdate, _$ShipModuleUpdate];

  @override
  final String wireName = r'ShipModuleUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
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
    if (object.torpedoCount != null) {
      yield r'torpedoCount';
      yield serializers.serialize(
        object.torpedoCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.mineCount != null) {
      yield r'mineCount';
      yield serializers.serialize(
        object.mineCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.cargoTons != null) {
      yield r'cargoTons';
      yield serializers.serialize(
        object.cargoTons,
        specifiedType: const FullType(int),
      );
    }
    if (object.concealed != null) {
      yield r'concealed';
      yield serializers.serialize(
        object.concealed,
        specifiedType: const FullType(bool),
      );
    }
    if (object.detectionBonus != null) {
      yield r'detectionBonus';
      yield serializers.serialize(
        object.detectionBonus,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
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
        case r'torpedoCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.torpedoCount = valueDes;
          break;
        case r'mineCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.mineCount = valueDes;
          break;
        case r'cargoTons':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cargoTons = valueDes;
          break;
        case r'concealed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.concealed = valueDes;
          break;
        case r'detectionBonus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.detectionBonus = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShipModuleUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleUpdateBuilder();
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

