//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model22.g.dart';

/// Model22
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [cargoTons] 
/// * [concealed] 
/// * [notes] 
@BuiltValue()
abstract class Model22 implements Built<Model22, Model22Builder> {
  @BuiltValueField(wireName: r'slot')
  Model22SlotEnum get slot;
  // enum slotEnum {  HOLD,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  @BuiltValueField(wireName: r'cargoTons')
  int? get cargoTons;

  @BuiltValueField(wireName: r'concealed')
  bool? get concealed;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  Model22._();

  factory Model22([void updates(Model22Builder b)]) = _$Model22;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Model22Builder b) => b
      ..cargoTons = 0
      ..concealed = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<Model22> get serializer => _$Model22Serializer();
}

class _$Model22Serializer implements PrimitiveSerializer<Model22> {
  @override
  final Iterable<Type> types = const [Model22, _$Model22];

  @override
  final String wireName = r'Model22';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Model22 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(Model22SlotEnum),
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
    if (object.cargoTons != null) {
      yield r'cargoTons';
      yield serializers.serialize(
        object.cargoTons,
        specifiedType: const FullType(int),
      );
    }
    if (object.concealed != null) {
      yield r'concealed';
      yield serializers.serialize(
        object.concealed,
        specifiedType: const FullType(bool),
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
    Model22 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Model22Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Model22SlotEnum),
          ) as Model22SlotEnum;
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
        case r'cargoTons':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cargoTons = valueDes;
          break;
        case r'concealed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.concealed = valueDes;
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
  Model22 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Model22Builder();
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

class Model22SlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'HOLD')
  static const Model22SlotEnum HOLD = _$model22SlotEnum_HOLD;

  static Serializer<Model22SlotEnum> get serializer => _$model22SlotEnumSerializer;

  const Model22SlotEnum._(String name): super(name);

  static BuiltSet<Model22SlotEnum> get values => _$model22SlotEnumValues;
  static Model22SlotEnum valueOf(String name) => _$model22SlotEnumValueOf(name);
}

