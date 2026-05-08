//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_slot_type.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model4.g.dart';

/// Model4
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [slot] 
/// * [effect] 
@BuiltValue()
abstract class Model4 implements Built<Model4, Model4Builder> {
  @BuiltValueField(wireName: r'type')
  Model4TypeEnum get type;
  // enum typeEnum {  SHIP_MODULE,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'slot')
  ItemSlotType get slot;
  // enum slotEnum {  bridge,  hull,  hold,  weapon,  drive,  sensor,  comms,  };

  @BuiltValueField(wireName: r'effect')
  String get effect;

  Model4._();

  factory Model4([void updates(Model4Builder b)]) = _$Model4;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Model4Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Model4> get serializer => _$Model4Serializer();
}

class _$Model4Serializer implements PrimitiveSerializer<Model4> {
  @override
  final Iterable<Type> types = const [Model4, _$Model4];

  @override
  final String wireName = r'Model4';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Model4 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(Model4TypeEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ItemSlotType),
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
    Model4 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Model4Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Model4TypeEnum),
          ) as Model4TypeEnum;
          result.type = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemSlotType),
          ) as ItemSlotType;
          result.slot = valueDes;
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
  Model4 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Model4Builder();
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

class Model4TypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SHIP_MODULE')
  static const Model4TypeEnum SHIP_MODULE = _$model4TypeEnum_SHIP_MODULE;

  static Serializer<Model4TypeEnum> get serializer => _$model4TypeEnumSerializer;

  const Model4TypeEnum._(String name): super(name);

  static BuiltSet<Model4TypeEnum> get values => _$model4TypeEnumValues;
  static Model4TypeEnum valueOf(String name) => _$model4TypeEnumValueOf(name);
}

