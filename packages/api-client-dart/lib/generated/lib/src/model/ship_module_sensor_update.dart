//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_sensor_update.g.dart';

/// PATCH payload for a SENSOR ship module. All fields optional.
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [detectionBonus] 
/// * [notes] 
@BuiltValue()
abstract class ShipModuleSensorUpdate implements Built<ShipModuleSensorUpdate, ShipModuleSensorUpdateBuilder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleSensorUpdateSlotEnum? get slot;
  // enum slotEnum {  SENSOR,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'energyUse')
  int? get energyUse;

  @BuiltValueField(wireName: r'detectionBonus')
  int? get detectionBonus;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleSensorUpdate._();

  factory ShipModuleSensorUpdate([void updates(ShipModuleSensorUpdateBuilder b)]) = _$ShipModuleSensorUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleSensorUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleSensorUpdate> get serializer => _$ShipModuleSensorUpdateSerializer();
}

class _$ShipModuleSensorUpdateSerializer implements PrimitiveSerializer<ShipModuleSensorUpdate> {
  @override
  final Iterable<Type> types = const [ShipModuleSensorUpdate, _$ShipModuleSensorUpdate];

  @override
  final String wireName = r'ShipModuleSensorUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleSensorUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.slot != null) {
      yield r'slot';
      yield serializers.serialize(
        object.slot,
        specifiedType: const FullType(ShipModuleSensorUpdateSlotEnum),
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
    ShipModuleSensorUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleSensorUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleSensorUpdateSlotEnum),
          ) as ShipModuleSensorUpdateSlotEnum;
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
  ShipModuleSensorUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleSensorUpdateBuilder();
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

class ShipModuleSensorUpdateSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SENSOR')
  static const ShipModuleSensorUpdateSlotEnum SENSOR = _$shipModuleSensorUpdateSlotEnum_SENSOR;

  static Serializer<ShipModuleSensorUpdateSlotEnum> get serializer => _$shipModuleSensorUpdateSlotEnumSerializer;

  const ShipModuleSensorUpdateSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleSensorUpdateSlotEnum> get values => _$shipModuleSensorUpdateSlotEnumValues;
  static ShipModuleSensorUpdateSlotEnum valueOf(String name) => _$shipModuleSensorUpdateSlotEnumValueOf(name);
}

