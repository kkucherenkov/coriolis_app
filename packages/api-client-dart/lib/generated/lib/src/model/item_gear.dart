//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_base.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_gear.g.dart';

/// ItemGear
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [type] 
/// * [name] - Item name
/// * [weight] - Encumbrance weight in slots
/// * [quantity] - Number of units
/// * [notes] - Optional free-text notes
@BuiltValue()
abstract class ItemGear implements ItemBase, Built<ItemGear, ItemGearBuilder> {
  /// Number of units
  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  /// Optional free-text notes
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// Encumbrance weight in slots
  @BuiltValueField(wireName: r'weight')
  num get weight;

  ItemGear._();

  factory ItemGear([void updates(ItemGearBuilder b)]) = _$ItemGear;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemGearBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemGear> get serializer => _$ItemGearSerializer();
}

class _$ItemGearSerializer implements PrimitiveSerializer<ItemGear> {
  @override
  final Iterable<Type> types = const [ItemGear, _$ItemGear];

  @override
  final String wireName = r'ItemGear';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemGear object, {
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
    ItemGear object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemGearBuilder result,
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
  ItemGear deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemGearBuilder();
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

class ItemGearTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'GEAR')
  static const ItemGearTypeEnum GEAR = _$itemGearTypeEnum_GEAR;

  static Serializer<ItemGearTypeEnum> get serializer => _$itemGearTypeEnumSerializer;

  const ItemGearTypeEnum._(String name): super(name);

  static BuiltSet<ItemGearTypeEnum> get values => _$itemGearTypeEnumValues;
  static ItemGearTypeEnum valueOf(String name) => _$itemGearTypeEnumValueOf(name);
}

