//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model5.g.dart';

/// Model5
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [weight] 
/// * [notes] 
@BuiltValue()
abstract class Model5 implements Built<Model5, Model5Builder> {
  @BuiltValueField(wireName: r'type')
  Model5TypeEnum get type;
  // enum typeEnum {  OTHER,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'weight')
  num get weight;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  Model5._();

  factory Model5([void updates(Model5Builder b)]) = _$Model5;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Model5Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Model5> get serializer => _$Model5Serializer();
}

class _$Model5Serializer implements PrimitiveSerializer<Model5> {
  @override
  final Iterable<Type> types = const [Model5, _$Model5];

  @override
  final String wireName = r'Model5';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Model5 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(Model5TypeEnum),
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
    Model5 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Model5Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Model5TypeEnum),
          ) as Model5TypeEnum;
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
  Model5 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Model5Builder();
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

class Model5TypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OTHER')
  static const Model5TypeEnum OTHER = _$model5TypeEnum_OTHER;

  static Serializer<Model5TypeEnum> get serializer => _$model5TypeEnumSerializer;

  const Model5TypeEnum._(String name): super(name);

  static BuiltSet<Model5TypeEnum> get values => _$model5TypeEnumValues;
  static Model5TypeEnum valueOf(String name) => _$model5TypeEnumValueOf(name);
}

