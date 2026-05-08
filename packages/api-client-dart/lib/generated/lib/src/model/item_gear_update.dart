//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_gear_update.g.dart';

/// PATCH payload for a GEAR item. All fields optional.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [weight] 
/// * [quantity] 
/// * [notes] 
@BuiltValue()
abstract class ItemGearUpdate implements Built<ItemGearUpdate, ItemGearUpdateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemGearUpdateTypeEnum? get type;
  // enum typeEnum {  GEAR,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'weight')
  num? get weight;

  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ItemGearUpdate._();

  factory ItemGearUpdate([void updates(ItemGearUpdateBuilder b)]) = _$ItemGearUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemGearUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemGearUpdate> get serializer => _$ItemGearUpdateSerializer();
}

class _$ItemGearUpdateSerializer implements PrimitiveSerializer<ItemGearUpdate> {
  @override
  final Iterable<Type> types = const [ItemGearUpdate, _$ItemGearUpdate];

  @override
  final String wireName = r'ItemGearUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemGearUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(ItemGearUpdateTypeEnum),
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
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
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
    ItemGearUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemGearUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemGearUpdateTypeEnum),
          ) as ItemGearUpdateTypeEnum;
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
  ItemGearUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemGearUpdateBuilder();
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

class ItemGearUpdateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'GEAR')
  static const ItemGearUpdateTypeEnum GEAR = _$itemGearUpdateTypeEnum_GEAR;

  static Serializer<ItemGearUpdateTypeEnum> get serializer => _$itemGearUpdateTypeEnumSerializer;

  const ItemGearUpdateTypeEnum._(String name): super(name);

  static BuiltSet<ItemGearUpdateTypeEnum> get values => _$itemGearUpdateTypeEnumValues;
  static ItemGearUpdateTypeEnum valueOf(String name) => _$itemGearUpdateTypeEnumValueOf(name);
}

