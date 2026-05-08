//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_module_base.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_sensor.g.dart';

/// ShipModuleSensor
///
/// Properties:
/// * [id] - Opaque module identifier (cuid2)
/// * [slot] 
/// * [name] - Module name (e.g. \"Graviton Projector\", \"Smuggler hold\")
/// * [energyUse] - Energy points consumed by this module when active
/// * [notes] - Free-text notes; used for damage state, special conditions, etc.
/// * [detectionBonus] - Modifier added to sensor / dataDjinn checks
@BuiltValue()
abstract class ShipModuleSensor implements ShipModuleBase, Built<ShipModuleSensor, ShipModuleSensorBuilder> {
  /// Modifier added to sensor / dataDjinn checks
  @BuiltValueField(wireName: r'detectionBonus')
  int? get detectionBonus;

  ShipModuleSensor._();

  factory ShipModuleSensor([void updates(ShipModuleSensorBuilder b)]) = _$ShipModuleSensor;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleSensorBuilder b) => b
      ..detectionBonus = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleSensor> get serializer => _$ShipModuleSensorSerializer();
}

class _$ShipModuleSensorSerializer implements PrimitiveSerializer<ShipModuleSensor> {
  @override
  final Iterable<Type> types = const [ShipModuleSensor, _$ShipModuleSensor];

  @override
  final String wireName = r'ShipModuleSensor';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleSensor object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
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
    yield r'energyUse';
    yield serializers.serialize(
      object.energyUse,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleSensor object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleSensorBuilder result,
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
  ShipModuleSensor deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleSensorBuilder();
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

class ShipModuleSensorSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SENSOR')
  static const ShipModuleSensorSlotEnum SENSOR = _$shipModuleSensorSlotEnum_SENSOR;

  static Serializer<ShipModuleSensorSlotEnum> get serializer => _$shipModuleSensorSlotEnumSerializer;

  const ShipModuleSensorSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleSensorSlotEnum> get values => _$shipModuleSensorSlotEnumValues;
  static ShipModuleSensorSlotEnum valueOf(String name) => _$shipModuleSensorSlotEnumValueOf(name);
}

