//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_other_create.g.dart';

/// Create payload for an OTHER item. No `id` — server-assigned.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [weight] - Encumbrance weight in slots
/// * [notes] - Optional free-text notes
@BuiltValue()
abstract class ItemOtherCreate implements Built<ItemOtherCreate, ItemOtherCreateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemOtherCreateTypeEnum get type;
  // enum typeEnum {  OTHER,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  /// Encumbrance weight in slots
  @BuiltValueField(wireName: r'weight')
  num get weight;

  /// Optional free-text notes
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ItemOtherCreate._();

  factory ItemOtherCreate([void updates(ItemOtherCreateBuilder b)]) = _$ItemOtherCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemOtherCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemOtherCreate> get serializer => _$ItemOtherCreateSerializer();
}

class _$ItemOtherCreateSerializer implements PrimitiveSerializer<ItemOtherCreate> {
  @override
  final Iterable<Type> types = const [ItemOtherCreate, _$ItemOtherCreate];

  @override
  final String wireName = r'ItemOtherCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemOtherCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(ItemOtherCreateTypeEnum),
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
    ItemOtherCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemOtherCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemOtherCreateTypeEnum),
          ) as ItemOtherCreateTypeEnum;
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
  ItemOtherCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemOtherCreateBuilder();
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

class ItemOtherCreateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ItemOtherCreateTypeEnum OTHER = _$itemOtherCreateTypeEnum_OTHER;

  static Serializer<ItemOtherCreateTypeEnum> get serializer => _$itemOtherCreateTypeEnumSerializer;

  const ItemOtherCreateTypeEnum._(String name): super(name);

  static BuiltSet<ItemOtherCreateTypeEnum> get values => _$itemOtherCreateTypeEnumValues;
  static ItemOtherCreateTypeEnum valueOf(String name) => _$itemOtherCreateTypeEnumValueOf(name);
}

