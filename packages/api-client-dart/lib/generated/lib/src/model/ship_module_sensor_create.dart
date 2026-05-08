//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_sensor_create.g.dart';

/// Create payload for a SENSOR ship module. No `id` — server-assigned.
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [detectionBonus] - Modifier added to sensor / dataDjinn checks
/// * [notes] 
@BuiltValue()
abstract class ShipModuleSensorCreate implements Built<ShipModuleSensorCreate, ShipModuleSensorCreateBuilder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleSensorCreateSlotEnum get slot;
  // enum slotEnum {  SENSOR,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  /// Modifier added to sensor / dataDjinn checks
  @BuiltValueField(wireName: r'detectionBonus')
  int? get detectionBonus;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleSensorCreate._();

  factory ShipModuleSensorCreate([void updates(ShipModuleSensorCreateBuilder b)]) = _$ShipModuleSensorCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleSensorCreateBuilder b) => b
      ..detectionBonus = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleSensorCreate> get serializer => _$ShipModuleSensorCreateSerializer();
}

class _$ShipModuleSensorCreateSerializer implements PrimitiveSerializer<ShipModuleSensorCreate> {
  @override
  final Iterable<Type> types = const [ShipModuleSensorCreate, _$ShipModuleSensorCreate];

  @override
  final String wireName = r'ShipModuleSensorCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleSensorCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleSensorCreateSlotEnum),
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
    ShipModuleSensorCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleSensorCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleSensorCreateSlotEnum),
          ) as ShipModuleSensorCreateSlotEnum;
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
  ShipModuleSensorCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleSensorCreateBuilder();
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

class ShipModuleSensorCreateSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SENSOR')
  static const ShipModuleSensorCreateSlotEnum SENSOR = _$shipModuleSensorCreateSlotEnum_SENSOR;

  static Serializer<ShipModuleSensorCreateSlotEnum> get serializer => _$shipModuleSensorCreateSlotEnumSerializer;

  const ShipModuleSensorCreateSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleSensorCreateSlotEnum> get values => _$shipModuleSensorCreateSlotEnumValues;
  static ShipModuleSensorCreateSlotEnum valueOf(String name) => _$shipModuleSensorCreateSlotEnumValueOf(name);
}

