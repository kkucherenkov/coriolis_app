//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model3.g.dart';

/// Model3
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [bodyPoints] 
/// * [effect] 
@BuiltValue()
abstract class Model3 implements Built<Model3, Model3Builder> {
  @BuiltValueField(wireName: r'type')
  Model3TypeEnum get type;
  // enum typeEnum {  CYBERNETIC,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'bodyPoints')
  int get bodyPoints;

  @BuiltValueField(wireName: r'effect')
  String get effect;

  Model3._();

  factory Model3([void updates(Model3Builder b)]) = _$Model3;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Model3Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Model3> get serializer => _$Model3Serializer();
}

class _$Model3Serializer implements PrimitiveSerializer<Model3> {
  @override
  final Iterable<Type> types = const [Model3, _$Model3];

  @override
  final String wireName = r'Model3';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Model3 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(Model3TypeEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'bodyPoints';
    yield serializers.serialize(
      object.bodyPoints,
      specifiedType: const FullType(int),
    );
    yield r'effect';
    yield serializers.serialize(
      object.effect,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Model3 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Model3Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Model3TypeEnum),
          ) as Model3TypeEnum;
          result.type = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'bodyPoints':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bodyPoints = valueDes;
          break;
        case r'effect':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.effect = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Model3 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Model3Builder();
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

class Model3TypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'CYBERNETIC')
  static const Model3TypeEnum CYBERNETIC = _$model3TypeEnum_CYBERNETIC;

  static Serializer<Model3TypeEnum> get serializer => _$model3TypeEnumSerializer;

  const Model3TypeEnum._(String name): super(name);

  static BuiltSet<Model3TypeEnum> get values => _$model3TypeEnumValues;
  static Model3TypeEnum valueOf(String name) => _$model3TypeEnumValueOf(name);
}

