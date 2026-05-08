//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/ship_module_hold_create.dart';
import 'package:app_api_client/src/model/ship_module_weapon_create.dart';
import 'package:app_api_client/src/model/ship_module_torpedo_create.dart';
import 'package:app_api_client/src/model/ship_module_other_create.dart';
import 'package:app_api_client/src/model/ship_module_sensor_create.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'ship_module_create.g.dart';

/// Payload for `POST /api/v1/ships/{id}/modules`. Same discriminated union as `ShipModule` but without `id` (server-assigned). The `slot` discriminator must be present.  Note: BRIDGE, REACTOR, and DRIVE modules are created automatically with the ship and cannot be added via this endpoint. 
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
/// * [torpedoCount] - Number of torpedoes currently loaded
/// * [mineCount] - Number of mines currently loaded
/// * [cargoTons] - Cargo capacity in tonnes
/// * [concealed] - True for a concealed hold
/// * [detectionBonus] - Modifier added to sensor / dataDjinn checks
@BuiltValue()
abstract class ShipModuleCreate implements Built<ShipModuleCreate, ShipModuleCreateBuilder> {
  /// One Of [ShipModuleHoldCreate], [ShipModuleOtherCreate], [ShipModuleSensorCreate], [ShipModuleTorpedoCreate], [ShipModuleWeaponCreate]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'slot';

  static const Map<String, Type> discriminatorMapping = {
    r'BRIDGE': ShipModuleOtherCreate,
    r'CHAPEL': ShipModuleOtherCreate,
    r'COMMS': ShipModuleOtherCreate,
    r'CONCEALED-HOLD': ShipModuleOtherCreate,
    r'CRYO': ShipModuleOtherCreate,
    r'DOCKING': ShipModuleOtherCreate,
    r'DRIVE': ShipModuleOtherCreate,
    r'ESCAPE-PODS': ShipModuleOtherCreate,
    r'HANGAR': ShipModuleOtherCreate,
    r'HOLD': ShipModuleHoldCreate,
    r'MEDICAL': ShipModuleOtherCreate,
    r'MINING': ShipModuleOtherCreate,
    r'OTHER': ShipModuleOtherCreate,
    r'PROXY-DECK': ShipModuleOtherCreate,
    r'QUARTERS': ShipModuleOtherCreate,
    r'REACTOR': ShipModuleOtherCreate,
    r'REPAIR': ShipModuleOtherCreate,
    r'SENSOR': ShipModuleSensorCreate,
    r'TORPEDO': ShipModuleTorpedoCreate,
    r'WEAPON': ShipModuleWeaponCreate,
    r'WORKSHOP': ShipModuleOtherCreate,
  };

  ShipModuleCreate._();

  factory ShipModuleCreate([void updates(ShipModuleCreateBuilder b)]) = _$ShipModuleCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleCreate> get serializer => _$ShipModuleCreateSerializer();
}

extension ShipModuleCreateDiscriminatorExt on ShipModuleCreate {
    String? get discriminatorValue {
        if (this is ShipModuleOtherCreate) {
            return r'BRIDGE';
        }
        if (this is ShipModuleOtherCreate) {
            return r'CHAPEL';
        }
        if (this is ShipModuleOtherCreate) {
            return r'COMMS';
        }
        if (this is ShipModuleOtherCreate) {
            return r'CONCEALED-HOLD';
        }
        if (this is ShipModuleOtherCreate) {
            return r'CRYO';
        }
        if (this is ShipModuleOtherCreate) {
            return r'DOCKING';
        }
        if (this is ShipModuleOtherCreate) {
            return r'DRIVE';
        }
        if (this is ShipModuleOtherCreate) {
            return r'ESCAPE-PODS';
        }
        if (this is ShipModuleOtherCreate) {
            return r'HANGAR';
        }
        if (this is ShipModuleHoldCreate) {
            return r'HOLD';
        }
        if (this is ShipModuleOtherCreate) {
            return r'MEDICAL';
        }
        if (this is ShipModuleOtherCreate) {
            return r'MINING';
        }
        if (this is ShipModuleOtherCreate) {
            return r'OTHER';
        }
        if (this is ShipModuleOtherCreate) {
            return r'PROXY-DECK';
        }
        if (this is ShipModuleOtherCreate) {
            return r'QUARTERS';
        }
        if (this is ShipModuleOtherCreate) {
            return r'REACTOR';
        }
        if (this is ShipModuleOtherCreate) {
            return r'REPAIR';
        }
        if (this is ShipModuleSensorCreate) {
            return r'SENSOR';
        }
        if (this is ShipModuleTorpedoCreate) {
            return r'TORPEDO';
        }
        if (this is ShipModuleWeaponCreate) {
            return r'WEAPON';
        }
        if (this is ShipModuleOtherCreate) {
            return r'WORKSHOP';
        }
        return null;
    }
}
extension ShipModuleCreateBuilderDiscriminatorExt on ShipModuleCreateBuilder {
    String? get discriminatorValue {
        if (this is ShipModuleOtherCreateBuilder) {
            return r'BRIDGE';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'CHAPEL';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'COMMS';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'CONCEALED-HOLD';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'CRYO';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'DOCKING';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'DRIVE';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'ESCAPE-PODS';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'HANGAR';
        }
        if (this is ShipModuleHoldCreateBuilder) {
            return r'HOLD';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'MEDICAL';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'MINING';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'OTHER';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'PROXY-DECK';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'QUARTERS';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'REACTOR';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'REPAIR';
        }
        if (this is ShipModuleSensorCreateBuilder) {
            return r'SENSOR';
        }
        if (this is ShipModuleTorpedoCreateBuilder) {
            return r'TORPEDO';
        }
        if (this is ShipModuleWeaponCreateBuilder) {
            return r'WEAPON';
        }
        if (this is ShipModuleOtherCreateBuilder) {
            return r'WORKSHOP';
        }
        return null;
    }
}

class _$ShipModuleCreateSerializer implements PrimitiveSerializer<ShipModuleCreate> {
  @override
  final Iterable<Type> types = const [ShipModuleCreate, _$ShipModuleCreate];

  @override
  final String wireName = r'ShipModuleCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  ShipModuleCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleCreateBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(ShipModuleCreate.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleHoldCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleOtherCreate, ShipModuleSensorCreate, ShipModuleTorpedoCreate, ShipModuleWeaponCreate, ShipModuleOtherCreate, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'BRIDGE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'CHAPEL':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'COMMS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'CONCEALED-HOLD':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'CRYO':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'DOCKING':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'DRIVE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'ESCAPE-PODS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'HANGAR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'HOLD':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleHoldCreate),
        ) as ShipModuleHoldCreate;
        oneOfType = ShipModuleHoldCreate;
        break;
      case r'MEDICAL':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'MINING':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'OTHER':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'PROXY-DECK':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'QUARTERS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'REACTOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'REPAIR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      case r'SENSOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleSensorCreate),
        ) as ShipModuleSensorCreate;
        oneOfType = ShipModuleSensorCreate;
        break;
      case r'TORPEDO':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleTorpedoCreate),
        ) as ShipModuleTorpedoCreate;
        oneOfType = ShipModuleTorpedoCreate;
        break;
      case r'WEAPON':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleWeaponCreate),
        ) as ShipModuleWeaponCreate;
        oneOfType = ShipModuleWeaponCreate;
        break;
      case r'WORKSHOP':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherCreate),
        ) as ShipModuleOtherCreate;
        oneOfType = ShipModuleOtherCreate;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}

