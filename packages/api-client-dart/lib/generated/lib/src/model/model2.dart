//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model2.g.dart';

/// Model2
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [weight] 
/// * [quantity] 
/// * [notes] 
@BuiltValue()
abstract class Model2 implements Built<Model2, Model2Builder> {
  @BuiltValueField(wireName: r'type')
  Model2TypeEnum get type;
  // enum typeEnum {  GEAR,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'weight')
  num get weight;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  Model2._();

  factory Model2([void updates(Model2Builder b)]) = _$Model2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Model2Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Model2> get serializer => _$Model2Serializer();
}

class _$Model2Serializer implements PrimitiveSerializer<Model2> {
  @override
  final Iterable<Type> types = const [Model2, _$Model2];

  @override
  final String wireName = r'Model2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Model2 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(Model2TypeEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'weight';
    yield serializers.serialize(
      object.weight,
      specifiedType: const FullType(num),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
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
    Model2 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Model2Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Model2TypeEnum),
          ) as Model2TypeEnum;
          result.type = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'weight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.weight = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
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
  Model2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Model2Builder();
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

class Model2TypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'GEAR')
  static const Model2TypeEnum GEAR = _$model2TypeEnum_GEAR;

  static Serializer<Model2TypeEnum> get serializer => _$model2TypeEnumSerializer;

  const Model2TypeEnum._(String name): super(name);

  static BuiltSet<Model2TypeEnum> get values => _$model2TypeEnumValues;
  static Model2TypeEnum valueOf(String name) => _$model2TypeEnumValueOf(name);
}

