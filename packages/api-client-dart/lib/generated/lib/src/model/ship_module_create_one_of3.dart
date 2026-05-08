//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_create_one_of3.g.dart';

/// ShipModuleCreateOneOf3
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [detectionBonus] 
/// * [notes] 
@BuiltValue()
abstract class ShipModuleCreateOneOf3 implements Built<ShipModuleCreateOneOf3, ShipModuleCreateOneOf3Builder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleCreateOneOf3SlotEnum get slot;
  // enum slotEnum {  SENSOR,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  @BuiltValueField(wireName: r'detectionBonus')
  int? get detectionBonus;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleCreateOneOf3._();

  factory ShipModuleCreateOneOf3([void updates(ShipModuleCreateOneOf3Builder b)]) = _$ShipModuleCreateOneOf3;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleCreateOneOf3Builder b) => b
      ..detectionBonus = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleCreateOneOf3> get serializer => _$ShipModuleCreateOneOf3Serializer();
}

class _$ShipModuleCreateOneOf3Serializer implements PrimitiveSerializer<ShipModuleCreateOneOf3> {
  @override
  final Iterable<Type> types = const [ShipModuleCreateOneOf3, _$ShipModuleCreateOneOf3];

  @override
  final String wireName = r'ShipModuleCreateOneOf3';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleCreateOneOf3 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleCreateOneOf3SlotEnum),
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
    if (object.detectionBonus != null) {
      yield r'detectionBonus';
      yield serializers.serialize(
        object.detectionBonus,
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
    ShipModuleCreateOneOf3 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleCreateOneOf3Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleCreateOneOf3SlotEnum),
          ) as ShipModuleCreateOneOf3SlotEnum;
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
        case r'detectionBonus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.detectionBonus = valueDes;
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
  ShipModuleCreateOneOf3 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleCreateOneOf3Builder();
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

class ShipModuleCreateOneOf3SlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SENSOR')
  static const ShipModuleCreateOneOf3SlotEnum SENSOR = _$shipModuleCreateOneOf3SlotEnum_SENSOR;

  static Serializer<ShipModuleCreateOneOf3SlotEnum> get serializer => _$shipModuleCreateOneOf3SlotEnumSerializer;

  const ShipModuleCreateOneOf3SlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleCreateOneOf3SlotEnum> get values => _$shipModuleCreateOneOf3SlotEnumValues;
  static ShipModuleCreateOneOf3SlotEnum valueOf(String name) => _$shipModuleCreateOneOf3SlotEnumValueOf(name);
}

