//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/ship_module_torpedo.dart';
import 'package:app_api_client/src/model/ship_module_weapon.dart';
import 'package:app_api_client/src/model/ship_module_other.dart';
import 'package:app_api_client/src/model/ship_module_sensor.dart';
import 'package:app_api_client/src/model/ship_module_slot.dart';
import 'package:app_api_client/src/model/ship_module_hold.dart';
import 'package:app_api_client/src/model/ship_weapon_range.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'ship_module.g.dart';

/// A discriminated union of all ship module variants. The `slot` field determines which variant applies. Generated clients produce a correctly-typed sum type from this schema.  Mandatory modules (BRIDGE, REACTOR, DRIVE) are always present on a ship and are not individually manageable via the module CRUD endpoints. They appear in the `modules` array for completeness and energy tracking. 
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
/// * [torpedoCount] - Number of torpedoes currently loaded
/// * [mineCount] - Number of mines currently loaded
/// * [cargoTons] - Cargo capacity in tonnes (class-dependent per Table 7.6)
/// * [concealed] - True for a потайной грузовой отсек (concealed hold)
/// * [detectionBonus] - Modifier added to sensor / dataDjinn checks
@BuiltValue()
abstract class ShipModule implements Built<ShipModule, ShipModuleBuilder> {
  /// One Of [ShipModuleHold], [ShipModuleOther], [ShipModuleSensor], [ShipModuleTorpedo], [ShipModuleWeapon]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'slot';

  static const Map<String, Type> discriminatorMapping = {
    r'BRIDGE': ShipModuleOther,
    r'CHAPEL': ShipModuleOther,
    r'COMMS': ShipModuleOther,
    r'CONCEALED-HOLD': ShipModuleOther,
    r'CRYO': ShipModuleOther,
    r'DOCKING': ShipModuleOther,
    r'DRIVE': ShipModuleOther,
    r'ESCAPE-PODS': ShipModuleOther,
    r'HANGAR': ShipModuleOther,
    r'HOLD': ShipModuleHold,
    r'MEDICAL': ShipModuleOther,
    r'MINING': ShipModuleOther,
    r'OTHER': ShipModuleOther,
    r'PROXY-DECK': ShipModuleOther,
    r'QUARTERS': ShipModuleOther,
    r'REACTOR': ShipModuleOther,
    r'REPAIR': ShipModuleOther,
    r'SENSOR': ShipModuleSensor,
    r'TORPEDO': ShipModuleTorpedo,
    r'WEAPON': ShipModuleWeapon,
    r'WORKSHOP': ShipModuleOther,
  };

  ShipModule._();

  factory ShipModule([void updates(ShipModuleBuilder b)]) = _$ShipModule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModule> get serializer => _$ShipModuleSerializer();
}

extension ShipModuleDiscriminatorExt on ShipModule {
    String? get discriminatorValue {
        if (this is ShipModuleOther) {
            return r'BRIDGE';
        }
        if (this is ShipModuleOther) {
            return r'CHAPEL';
        }
        if (this is ShipModuleOther) {
            return r'COMMS';
        }
        if (this is ShipModuleOther) {
            return r'CONCEALED-HOLD';
        }
        if (this is ShipModuleOther) {
            return r'CRYO';
        }
        if (this is ShipModuleOther) {
            return r'DOCKING';
        }
        if (this is ShipModuleOther) {
            return r'DRIVE';
        }
        if (this is ShipModuleOther) {
            return r'ESCAPE-PODS';
        }
        if (this is ShipModuleOther) {
            return r'HANGAR';
        }
        if (this is ShipModuleHold) {
            return r'HOLD';
        }
        if (this is ShipModuleOther) {
            return r'MEDICAL';
        }
        if (this is ShipModuleOther) {
            return r'MINING';
        }
        if (this is ShipModuleOther) {
            return r'OTHER';
        }
        if (this is ShipModuleOther) {
            return r'PROXY-DECK';
        }
        if (this is ShipModuleOther) {
            return r'QUARTERS';
        }
        if (this is ShipModuleOther) {
            return r'REACTOR';
        }
        if (this is ShipModuleOther) {
            return r'REPAIR';
        }
        if (this is ShipModuleSensor) {
            return r'SENSOR';
        }
        if (this is ShipModuleTorpedo) {
            return r'TORPEDO';
        }
        if (this is ShipModuleWeapon) {
            return r'WEAPON';
        }
        if (this is ShipModuleOther) {
            return r'WORKSHOP';
        }
        return null;
    }
}
extension ShipModuleBuilderDiscriminatorExt on ShipModuleBuilder {
    String? get discriminatorValue {
        if (this is ShipModuleOtherBuilder) {
            return r'BRIDGE';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'CHAPEL';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'COMMS';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'CONCEALED-HOLD';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'CRYO';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'DOCKING';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'DRIVE';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'ESCAPE-PODS';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'HANGAR';
        }
        if (this is ShipModuleHoldBuilder) {
            return r'HOLD';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'MEDICAL';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'MINING';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'OTHER';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'PROXY-DECK';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'QUARTERS';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'REACTOR';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'REPAIR';
        }
        if (this is ShipModuleSensorBuilder) {
            return r'SENSOR';
        }
        if (this is ShipModuleTorpedoBuilder) {
            return r'TORPEDO';
        }
        if (this is ShipModuleWeaponBuilder) {
            return r'WEAPON';
        }
        if (this is ShipModuleOtherBuilder) {
            return r'WORKSHOP';
        }
        return null;
    }
}

class _$ShipModuleSerializer implements PrimitiveSerializer<ShipModule> {
  @override
  final Iterable<Type> types = const [ShipModule, _$ShipModule];

  @override
  final String wireName = r'ShipModule';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModule object) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipModule object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  ShipModule deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(ShipModule.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleHold, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleOther, ShipModuleSensor, ShipModuleTorpedo, ShipModuleWeapon, ShipModuleOther, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'BRIDGE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'CHAPEL':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'COMMS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'CONCEALED-HOLD':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'CRYO':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'DOCKING':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'DRIVE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'ESCAPE-PODS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'HANGAR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'HOLD':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleHold),
        ) as ShipModuleHold;
        oneOfType = ShipModuleHold;
        break;
      case r'MEDICAL':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'MINING':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'OTHER':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'PROXY-DECK':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'QUARTERS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'REACTOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'REPAIR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      case r'SENSOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleSensor),
        ) as ShipModuleSensor;
        oneOfType = ShipModuleSensor;
        break;
      case r'TORPEDO':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleTorpedo),
        ) as ShipModuleTorpedo;
        oneOfType = ShipModuleTorpedo;
        break;
      case r'WEAPON':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleWeapon),
        ) as ShipModuleWeapon;
        oneOfType = ShipModuleWeapon;
        break;
      case r'WORKSHOP':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ShipModuleOther),
        ) as ShipModuleOther;
        oneOfType = ShipModuleOther;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}

