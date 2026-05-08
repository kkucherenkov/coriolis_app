//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_base.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_other.g.dart';

/// ItemOther
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [type] 
/// * [name] - Item name
/// * [weight] - Encumbrance weight in slots
/// * [notes] - Optional free-text notes
@BuiltValue()
abstract class ItemOther implements ItemBase, Built<ItemOther, ItemOtherBuilder> {
  /// Optional free-text notes
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// Encumbrance weight in slots
  @BuiltValueField(wireName: r'weight')
  num get weight;

  ItemOther._();

  factory ItemOther([void updates(ItemOtherBuilder b)]) = _$ItemOther;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemOtherBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemOther> get serializer => _$ItemOtherSerializer();
}

class _$ItemOtherSerializer implements PrimitiveSerializer<ItemOther> {
  @override
  final Iterable<Type> types = const [ItemOther, _$ItemOther];

  @override
  final String wireName = r'ItemOther';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemOther object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemOther object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemOtherBuilder result,
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItemOther deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemOtherBuilder();
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

class ItemOtherTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ItemOtherTypeEnum OTHER = _$itemOtherTypeEnum_OTHER;

  static Serializer<ItemOtherTypeEnum> get serializer => _$itemOtherTypeEnumSerializer;

  const ItemOtherTypeEnum._(String name): super(name);

  static BuiltSet<ItemOtherTypeEnum> get values => _$itemOtherTypeEnumValues;
  static ItemOtherTypeEnum valueOf(String name) => _$itemOtherTypeEnumValueOf(name);
}

