//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_create_one_of4.g.dart';

/// ShipModuleCreateOneOf4
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [notes] 
@BuiltValue()
abstract class ShipModuleCreateOneOf4 implements Built<ShipModuleCreateOneOf4, ShipModuleCreateOneOf4Builder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleCreateOneOf4SlotEnum get slot;
  // enum slotEnum {  BRIDGE,  REACTOR,  DRIVE,  COMMS,  HANGAR,  QUARTERS,  MEDICAL,  WORKSHOP,  CHAPEL,  ESCAPE-PODS,  CRYO,  DOCKING,  MINING,  REPAIR,  CONCEALED-HOLD,  PROXY-DECK,  OTHER,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleCreateOneOf4._();

  factory ShipModuleCreateOneOf4([void updates(ShipModuleCreateOneOf4Builder b)]) = _$ShipModuleCreateOneOf4;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleCreateOneOf4Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleCreateOneOf4> get serializer => _$ShipModuleCreateOneOf4Serializer();
}

class _$ShipModuleCreateOneOf4Serializer implements PrimitiveSerializer<ShipModuleCreateOneOf4> {
  @override
  final Iterable<Type> types = const [ShipModuleCreateOneOf4, _$ShipModuleCreateOneOf4];

  @override
  final String wireName = r'ShipModuleCreateOneOf4';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleCreateOneOf4 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleCreateOneOf4SlotEnum),
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
    ShipModuleCreateOneOf4 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleCreateOneOf4Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleCreateOneOf4SlotEnum),
          ) as ShipModuleCreateOneOf4SlotEnum;
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
  ShipModuleCreateOneOf4 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleCreateOneOf4Builder();
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

class ShipModuleCreateOneOf4SlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'BRIDGE')
  static const ShipModuleCreateOneOf4SlotEnum BRIDGE = _$shipModuleCreateOneOf4SlotEnum_BRIDGE;
  @BuiltValueEnumConst(wireName: r'REACTOR')
  static const ShipModuleCreateOneOf4SlotEnum REACTOR = _$shipModuleCreateOneOf4SlotEnum_REACTOR;
  @BuiltValueEnumConst(wireName: r'DRIVE')
  static const ShipModuleCreateOneOf4SlotEnum DRIVE = _$shipModuleCreateOneOf4SlotEnum_DRIVE;
  @BuiltValueEnumConst(wireName: r'COMMS')
  static const ShipModuleCreateOneOf4SlotEnum COMMS = _$shipModuleCreateOneOf4SlotEnum_COMMS;
  @BuiltValueEnumConst(wireName: r'HANGAR')
  static const ShipModuleCreateOneOf4SlotEnum HANGAR = _$shipModuleCreateOneOf4SlotEnum_HANGAR;
  @BuiltValueEnumConst(wireName: r'QUARTERS')
  static const ShipModuleCreateOneOf4SlotEnum QUARTERS = _$shipModuleCreateOneOf4SlotEnum_QUARTERS;
  @BuiltValueEnumConst(wireName: r'MEDICAL')
  static const ShipModuleCreateOneOf4SlotEnum MEDICAL = _$shipModuleCreateOneOf4SlotEnum_MEDICAL;
  @BuiltValueEnumConst(wireName: r'WORKSHOP')
  static const ShipModuleCreateOneOf4SlotEnum WORKSHOP = _$shipModuleCreateOneOf4SlotEnum_WORKSHOP;
  @BuiltValueEnumConst(wireName: r'CHAPEL')
  static const ShipModuleCreateOneOf4SlotEnum CHAPEL = _$shipModuleCreateOneOf4SlotEnum_CHAPEL;
  @BuiltValueEnumConst(wireName: r'ESCAPE-PODS')
  static const ShipModuleCreateOneOf4SlotEnum ESCAPE_PODS = _$shipModuleCreateOneOf4SlotEnum_ESCAPE_PODS;
  @BuiltValueEnumConst(wireName: r'CRYO')
  static const ShipModuleCreateOneOf4SlotEnum CRYO = _$shipModuleCreateOneOf4SlotEnum_CRYO;
  @BuiltValueEnumConst(wireName: r'DOCKING')
  static const ShipModuleCreateOneOf4SlotEnum DOCKING = _$shipModuleCreateOneOf4SlotEnum_DOCKING;
  @BuiltValueEnumConst(wireName: r'MINING')
  static const ShipModuleCreateOneOf4SlotEnum MINING = _$shipModuleCreateOneOf4SlotEnum_MINING;
  @BuiltValueEnumConst(wireName: r'REPAIR')
  static const ShipModuleCreateOneOf4SlotEnum REPAIR = _$shipModuleCreateOneOf4SlotEnum_REPAIR;
  @BuiltValueEnumConst(wireName: r'CONCEALED-HOLD')
  static const ShipModuleCreateOneOf4SlotEnum CONCEALED_HOLD = _$shipModuleCreateOneOf4SlotEnum_CONCEALED_HOLD;
  @BuiltValueEnumConst(wireName: r'PROXY-DECK')
  static const ShipModuleCreateOneOf4SlotEnum PROXY_DECK = _$shipModuleCreateOneOf4SlotEnum_PROXY_DECK;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ShipModuleCreateOneOf4SlotEnum OTHER = _$shipModuleCreateOneOf4SlotEnum_OTHER;

  static Serializer<ShipModuleCreateOneOf4SlotEnum> get serializer => _$shipModuleCreateOneOf4SlotEnumSerializer;

  const ShipModuleCreateOneOf4SlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleCreateOneOf4SlotEnum> get values => _$shipModuleCreateOneOf4SlotEnumValues;
  static ShipModuleCreateOneOf4SlotEnum valueOf(String name) => _$shipModuleCreateOneOf4SlotEnumValueOf(name);
}

