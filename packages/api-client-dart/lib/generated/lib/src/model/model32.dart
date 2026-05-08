//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model32.g.dart';

/// Model32
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [detectionBonus] 
/// * [notes] 
@BuiltValue()
abstract class Model32 implements Built<Model32, Model32Builder> {
  @BuiltValueField(wireName: r'slot')
  Model32SlotEnum get slot;
  // enum slotEnum {  SENSOR,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  @BuiltValueField(wireName: r'detectionBonus')
  int? get detectionBonus;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  Model32._();

  factory Model32([void updates(Model32Builder b)]) = _$Model32;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Model32Builder b) => b
      ..detectionBonus = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<Model32> get serializer => _$Model32Serializer();
}

class _$Model32Serializer implements PrimitiveSerializer<Model32> {
  @override
  final Iterable<Type> types = const [Model32, _$Model32];

  @override
  final String wireName = r'Model32';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Model32 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(Model32SlotEnum),
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
    Model32 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Model32Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Model32SlotEnum),
          ) as Model32SlotEnum;
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
  Model32 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Model32Builder();
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

class Model32SlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SENSOR')
  static const Model32SlotEnum SENSOR = _$model32SlotEnum_SENSOR;

  static Serializer<Model32SlotEnum> get serializer => _$model32SlotEnumSerializer;

  const Model32SlotEnum._(String name): super(name);

  static BuiltSet<Model32SlotEnum> get values => _$model32SlotEnumValues;
  static Model32SlotEnum valueOf(String name) => _$model32SlotEnumValueOf(name);
}

