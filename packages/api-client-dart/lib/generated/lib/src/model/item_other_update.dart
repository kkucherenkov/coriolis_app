//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_other_update.g.dart';

/// PATCH payload for an OTHER item. All fields optional.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [weight] 
/// * [notes] 
@BuiltValue()
abstract class ItemOtherUpdate implements Built<ItemOtherUpdate, ItemOtherUpdateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemOtherUpdateTypeEnum? get type;
  // enum typeEnum {  OTHER,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'weight')
  num? get weight;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ItemOtherUpdate._();

  factory ItemOtherUpdate([void updates(ItemOtherUpdateBuilder b)]) = _$ItemOtherUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemOtherUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemOtherUpdate> get serializer => _$ItemOtherUpdateSerializer();
}

class _$ItemOtherUpdateSerializer implements PrimitiveSerializer<ItemOtherUpdate> {
  @override
  final Iterable<Type> types = const [ItemOtherUpdate, _$ItemOtherUpdate];

  @override
  final String wireName = r'ItemOtherUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemOtherUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(ItemOtherUpdateTypeEnum),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.weight != null) {
      yield r'weight';
      yield serializers.serialize(
        object.weight,
        specifiedType: const FullType(num),
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
    ItemOtherUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemOtherUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemOtherUpdateTypeEnum),
          ) as ItemOtherUpdateTypeEnum;
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
  ItemOtherUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemOtherUpdateBuilder();
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

class ItemOtherUpdateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ItemOtherUpdateTypeEnum OTHER = _$itemOtherUpdateTypeEnum_OTHER;

  static Serializer<ItemOtherUpdateTypeEnum> get serializer => _$itemOtherUpdateTypeEnumSerializer;

  const ItemOtherUpdateTypeEnum._(String name): super(name);

  static BuiltSet<ItemOtherUpdateTypeEnum> get values => _$itemOtherUpdateTypeEnumValues;
  static ItemOtherUpdateTypeEnum valueOf(String name) => _$itemOtherUpdateTypeEnumValueOf(name);
}

