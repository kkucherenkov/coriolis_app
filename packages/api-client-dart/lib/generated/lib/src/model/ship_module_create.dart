//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/model32.dart';
import 'package:app_api_client/src/model/ship_module_create_one_of2.dart';
import 'package:app_api_client/src/model/ship_module_create_one_of4.dart';
import 'package:app_api_client/src/model/model12.dart';
import 'package:app_api_client/src/model/ship_module_create_one_of.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_module_create_one_of3.dart';
import 'package:app_api_client/src/model/model42.dart';
import 'package:app_api_client/src/model/ship_module_create_one_of1.dart';
import 'package:app_api_client/src/model/model22.dart';
import 'package:app_api_client/src/model/model02.dart';
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
abstract class ShipModuleCreate implements Built<ShipModuleCreate, ShipModuleCreateBuilder> {
  /// One Of [ShipModuleCreateOneOf], [ShipModuleCreateOneOf1], [ShipModuleCreateOneOf2], [ShipModuleCreateOneOf3], [ShipModuleCreateOneOf4]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'slot';

  static const Map<String, Type> discriminatorMapping = {
    r'BRIDGE': Model42,
    r'CHAPEL': Model42,
    r'COMMS': Model42,
    r'CONCEALED-HOLD': Model42,
    r'CRYO': Model42,
    r'DOCKING': Model42,
    r'DRIVE': Model42,
    r'ESCAPE-PODS': Model42,
    r'HANGAR': Model42,
    r'HOLD': Model22,
    r'MEDICAL': Model42,
    r'MINING': Model42,
    r'OTHER': Model42,
    r'PROXY-DECK': Model42,
    r'QUARTERS': Model42,
    r'REACTOR': Model42,
    r'REPAIR': Model42,
    r'SENSOR': Model32,
    r'TORPEDO': Model12,
    r'WEAPON': Model02,
    r'WORKSHOP': Model42,
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
        if (this is Model42) {
            return r'BRIDGE';
        }
        if (this is Model42) {
            return r'CHAPEL';
        }
        if (this is Model42) {
            return r'COMMS';
        }
        if (this is Model42) {
            return r'CONCEALED-HOLD';
        }
        if (this is Model42) {
            return r'CRYO';
        }
        if (this is Model42) {
            return r'DOCKING';
        }
        if (this is Model42) {
            return r'DRIVE';
        }
        if (this is Model42) {
            return r'ESCAPE-PODS';
        }
        if (this is Model42) {
            return r'HANGAR';
        }
        if (this is Model22) {
            return r'HOLD';
        }
        if (this is Model42) {
            return r'MEDICAL';
        }
        if (this is Model42) {
            return r'MINING';
        }
        if (this is Model42) {
            return r'OTHER';
        }
        if (this is Model42) {
            return r'PROXY-DECK';
        }
        if (this is Model42) {
            return r'QUARTERS';
        }
        if (this is Model42) {
            return r'REACTOR';
        }
        if (this is Model42) {
            return r'REPAIR';
        }
        if (this is Model32) {
            return r'SENSOR';
        }
        if (this is Model12) {
            return r'TORPEDO';
        }
        if (this is Model02) {
            return r'WEAPON';
        }
        if (this is Model42) {
            return r'WORKSHOP';
        }
        return null;
    }
}
extension ShipModuleCreateBuilderDiscriminatorExt on ShipModuleCreateBuilder {
    String? get discriminatorValue {
        if (this is Model42Builder) {
            return r'BRIDGE';
        }
        if (this is Model42Builder) {
            return r'CHAPEL';
        }
        if (this is Model42Builder) {
            return r'COMMS';
        }
        if (this is Model42Builder) {
            return r'CONCEALED-HOLD';
        }
        if (this is Model42Builder) {
            return r'CRYO';
        }
        if (this is Model42Builder) {
            return r'DOCKING';
        }
        if (this is Model42Builder) {
            return r'DRIVE';
        }
        if (this is Model42Builder) {
            return r'ESCAPE-PODS';
        }
        if (this is Model42Builder) {
            return r'HANGAR';
        }
        if (this is Model22Builder) {
            return r'HOLD';
        }
        if (this is Model42Builder) {
            return r'MEDICAL';
        }
        if (this is Model42Builder) {
            return r'MINING';
        }
        if (this is Model42Builder) {
            return r'OTHER';
        }
        if (this is Model42Builder) {
            return r'PROXY-DECK';
        }
        if (this is Model42Builder) {
            return r'QUARTERS';
        }
        if (this is Model42Builder) {
            return r'REACTOR';
        }
        if (this is Model42Builder) {
            return r'REPAIR';
        }
        if (this is Model32Builder) {
            return r'SENSOR';
        }
        if (this is Model12Builder) {
            return r'TORPEDO';
        }
        if (this is Model02Builder) {
            return r'WEAPON';
        }
        if (this is Model42Builder) {
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
    final oneOfTypes = [Model42, Model42, Model42, Model42, Model42, Model42, Model42, Model42, Model42, Model22, Model42, Model42, Model42, Model42, Model42, Model42, Model42, Model32, Model12, Model02, Model42, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'BRIDGE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'CHAPEL':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'COMMS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'CONCEALED-HOLD':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'CRYO':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'DOCKING':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'DRIVE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'ESCAPE-PODS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'HANGAR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'HOLD':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model22),
        ) as Model22;
        oneOfType = Model22;
        break;
      case r'MEDICAL':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'MINING':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'OTHER':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'PROXY-DECK':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'QUARTERS':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'REACTOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'REPAIR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      case r'SENSOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model32),
        ) as Model32;
        oneOfType = Model32;
        break;
      case r'TORPEDO':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model12),
        ) as Model12;
        oneOfType = Model12;
        break;
      case r'WEAPON':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model02),
        ) as Model02;
        oneOfType = Model02;
        break;
      case r'WORKSHOP':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model42),
        ) as Model42;
        oneOfType = Model42;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}

class ShipModuleCreateSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'BRIDGE')
  static const ShipModuleCreateSlotEnum BRIDGE = _$shipModuleCreateSlotEnum_BRIDGE;
  @BuiltValueEnumConst(wireName: r'REACTOR')
  static const ShipModuleCreateSlotEnum REACTOR = _$shipModuleCreateSlotEnum_REACTOR;
  @BuiltValueEnumConst(wireName: r'DRIVE')
  static const ShipModuleCreateSlotEnum DRIVE = _$shipModuleCreateSlotEnum_DRIVE;
  @BuiltValueEnumConst(wireName: r'COMMS')
  static const ShipModuleCreateSlotEnum COMMS = _$shipModuleCreateSlotEnum_COMMS;
  @BuiltValueEnumConst(wireName: r'HANGAR')
  static const ShipModuleCreateSlotEnum HANGAR = _$shipModuleCreateSlotEnum_HANGAR;
  @BuiltValueEnumConst(wireName: r'QUARTERS')
  static const ShipModuleCreateSlotEnum QUARTERS = _$shipModuleCreateSlotEnum_QUARTERS;
  @BuiltValueEnumConst(wireName: r'MEDICAL')
  static const ShipModuleCreateSlotEnum MEDICAL = _$shipModuleCreateSlotEnum_MEDICAL;
  @BuiltValueEnumConst(wireName: r'WORKSHOP')
  static const ShipModuleCreateSlotEnum WORKSHOP = _$shipModuleCreateSlotEnum_WORKSHOP;
  @BuiltValueEnumConst(wireName: r'CHAPEL')
  static const ShipModuleCreateSlotEnum CHAPEL = _$shipModuleCreateSlotEnum_CHAPEL;
  @BuiltValueEnumConst(wireName: r'ESCAPE-PODS')
  static const ShipModuleCreateSlotEnum ESCAPE_PODS = _$shipModuleCreateSlotEnum_ESCAPE_PODS;
  @BuiltValueEnumConst(wireName: r'CRYO')
  static const ShipModuleCreateSlotEnum CRYO = _$shipModuleCreateSlotEnum_CRYO;
  @BuiltValueEnumConst(wireName: r'DOCKING')
  static const ShipModuleCreateSlotEnum DOCKING = _$shipModuleCreateSlotEnum_DOCKING;
  @BuiltValueEnumConst(wireName: r'MINING')
  static const ShipModuleCreateSlotEnum MINING = _$shipModuleCreateSlotEnum_MINING;
  @BuiltValueEnumConst(wireName: r'REPAIR')
  static const ShipModuleCreateSlotEnum REPAIR = _$shipModuleCreateSlotEnum_REPAIR;
  @BuiltValueEnumConst(wireName: r'CONCEALED-HOLD')
  static const ShipModuleCreateSlotEnum CONCEALED_HOLD = _$shipModuleCreateSlotEnum_CONCEALED_HOLD;
  @BuiltValueEnumConst(wireName: r'PROXY-DECK')
  static const ShipModuleCreateSlotEnum PROXY_DECK = _$shipModuleCreateSlotEnum_PROXY_DECK;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ShipModuleCreateSlotEnum OTHER = _$shipModuleCreateSlotEnum_OTHER;

  static Serializer<ShipModuleCreateSlotEnum> get serializer => _$shipModuleCreateSlotEnumSerializer;

  const ShipModuleCreateSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleCreateSlotEnum> get values => _$shipModuleCreateSlotEnumValues;
  static ShipModuleCreateSlotEnum valueOf(String name) => _$shipModuleCreateSlotEnumValueOf(name);
}

