//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/ship_module_other_update.dart';
import 'package:app_api_client/src/model/ship_module_weapon_update.dart';
import 'package:app_api_client/src/model/ship_module_torpedo_update.dart';
import 'package:app_api_client/src/model/ship_module_hold_update.dart';
import 'package:app_api_client/src/model/ship_module_sensor_update.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'ship_module_update.g.dart';

/// PATCH payload for `PATCH /api/v1/ship-modules/{id}`. The `slot` discriminator must match the installed module's slot — changing it returns 400 `SHIP_MODULE_SLOT_MISMATCH`. All fields optional. 
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
/// * [torpedoCount] 
/// * [mineCount] 
/// * [cargoTons] 
/// * [concealed] 
/// * [detectionBonus] 
@BuiltValue()
abstract class ShipModuleUpdate implements Built<ShipModuleUpdate, ShipModuleUpdateBuilder> {
  /// One Of [ShipModuleHoldUpdate], [ShipModuleOtherUpdate], [ShipModuleSensorUpdate], [ShipModuleTorpedoUpdate], [ShipModuleWeaponUpdate]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'slot';

  static const Map<String, Type> discriminatorMapping = {
    r'BRIDGE': ShipModuleOtherUpdate,
    r'CHAPEL': ShipModuleOtherUpdate,
    r'COMMS': ShipModuleOtherUpdate,
    r'CONCEALED-HOLD': ShipModuleOtherUpdate,
    r'CRYO': ShipModuleOtherUpdate,
    r'DOCKING': ShipModuleOtherUpdate,
    r'DRIVE': ShipModuleOtherUpdate,
    r'ESCAPE-PODS': ShipModuleOtherUpdate,
    r'HANGAR': ShipModuleOtherUpdate,
    r'HOLD': ShipModuleHoldUpdate,
    r'MEDICAL': ShipModuleOtherUpdate,
    r'MINING': ShipModuleOtherUpdate,
    r'OTHER': ShipModuleOtherUpdate,
    r'PROXY-DECK': ShipModuleOtherUpdate,
    r'QUARTERS': ShipModuleOtherUpdate,
    r'REACTOR': ShipModuleOtherUpdate,
    r'REPAIR': ShipModuleOtherUpdate,
    r'SENSOR': ShipModuleSensorUpdate,
    r'TORPEDO': ShipModuleTorpedoUpdate,
    r'WEAPON': ShipModuleWeaponUpdate,
    r'WORKSHOP': ShipModuleOtherUpdate,
  };

  ShipModuleUpdate._();

  factory ShipModuleUpdate([void updates(ShipModuleUpdateBuilder b)]) = _$ShipModuleUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleUpdate> get serializer => _$ShipModuleUpdateSerializer();
}

extension ShipModuleUpdateDiscriminatorExt on ShipModuleUpdate {
    String? get discriminatorValue {
        if (this is ShipModuleOtherUpdate) {
            return r'BRIDGE';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'CHAPEL';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'COMMS';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'CONCEALED-HOLD';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'CRYO';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'DOCKING';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'DRIVE';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'ESCAPE-PODS';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'HANGAR';
        }
        if (this is ShipModuleHoldUpdate) {
            return r'HOLD';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'MEDICAL';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'MINING';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'OTHER';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'PROXY-DECK';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'QUARTERS';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'REACTOR';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'REPAIR';
        }
        if (this is ShipModuleSensorUpdate) {
            return r'SENSOR';
        }
        if (this is ShipModuleTorpedoUpdate) {
            return r'TORPEDO';
        }
        if (this is ShipModuleWeaponUpdate) {
            return r'WEAPON';
        }
        if (this is ShipModuleOtherUpdate) {
            return r'WORKSHOP';
        }
        return null;
    }
}
extension ShipModuleUpdateBuilderDiscriminatorExt on ShipModuleUpdateBuilder {
    String? get discriminatorValue {
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'BRIDGE';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'CHAPEL';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'COMMS';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'CONCEALED-HOLD';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'CRYO';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'DOCKING';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'DRIVE';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'ESCAPE-PODS';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'HANGAR';
        }
        if (this is ShipModuleHoldUpdateBuilder) {
            return r'HOLD';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'MEDICAL';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'MINING';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'OTHER';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'PROXY-DECK';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'QUARTERS';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'REACTOR';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'REPAIR';
        }
        if (this is ShipModuleSensorUpdateBuilder) {
            return r'SENSOR';
        }
        if (this is ShipModuleTorpedoUpdateBuilder) {
            return r'TORPEDO';
        }
        if (this is ShipModuleWeaponUpdateBuilder) {
            return r'WEAPON';
        }
        if (this is ShipModuleOtherUpdateBuilder) {
            return r'WORKSHOP';
        }
        return null;
    }
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  ShipModuleUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleUpdateBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(ShipModuleUpdate.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleHoldUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleOtherUpdate, ShipModuleSensorUpdate, ShipModuleTorpedoUpdate, ShipModuleWeaponUpdate, ShipModuleOtherUpdate, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'BRIDGE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'CHAPEL':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'COMMS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'CONCEALED-HOLD':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'CRYO':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'DOCKING':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'DRIVE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'ESCAPE-PODS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'HANGAR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'HOLD':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleHoldUpdate),
        ) as ShipModuleHoldUpdate;
        oneOfType = ShipModuleHoldUpdate;
        break;
      case r'MEDICAL':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'MINING':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'OTHER':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'PROXY-DECK':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'QUARTERS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'REACTOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'REPAIR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      case r'SENSOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleSensorUpdate),
        ) as ShipModuleSensorUpdate;
        oneOfType = ShipModuleSensorUpdate;
        break;
      case r'TORPEDO':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleTorpedoUpdate),
        ) as ShipModuleTorpedoUpdate;
        oneOfType = ShipModuleTorpedoUpdate;
        break;
      case r'WEAPON':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleWeaponUpdate),
        ) as ShipModuleWeaponUpdate;
        oneOfType = ShipModuleWeaponUpdate;
        break;
      case r'WORKSHOP':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOtherUpdate),
        ) as ShipModuleOtherUpdate;
        oneOfType = ShipModuleOtherUpdate;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}

