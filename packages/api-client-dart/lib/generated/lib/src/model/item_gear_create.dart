//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_gear_create.g.dart';

/// Create payload for a GEAR item. No `id` — server-assigned.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [weight] - Encumbrance weight in slots
/// * [quantity] - Number of units
/// * [notes] - Optional free-text notes
@BuiltValue()
abstract class ItemGearCreate implements Built<ItemGearCreate, ItemGearCreateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemGearCreateTypeEnum get type;
  // enum typeEnum {  GEAR,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  /// Encumbrance weight in slots
  @BuiltValueField(wireName: r'weight')
  num get weight;

  /// Number of units
  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  /// Optional free-text notes
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ItemGearCreate._();

  factory ItemGearCreate([void updates(ItemGearCreateBuilder b)]) = _$ItemGearCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemGearCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemGearCreate> get serializer => _$ItemGearCreateSerializer();
}

class _$ItemGearCreateSerializer implements PrimitiveSerializer<ItemGearCreate> {
  @override
  final Iterable<Type> types = const [ItemGearCreate, _$ItemGearCreate];

  @override
  final String wireName = r'ItemGearCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemGearCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(ItemGearCreateTypeEnum),
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
    ItemGearCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemGearCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemGearCreateTypeEnum),
          ) as ItemGearCreateTypeEnum;
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
  ItemGearCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemGearCreateBuilder();
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

class ItemGearCreateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'GEAR')
  static const ItemGearCreateTypeEnum GEAR = _$itemGearCreateTypeEnum_GEAR;

  static Serializer<ItemGearCreateTypeEnum> get serializer => _$itemGearCreateTypeEnumSerializer;

  const ItemGearCreateTypeEnum._(String name): super(name);

  static BuiltSet<ItemGearCreateTypeEnum> get values => _$itemGearCreateTypeEnumValues;
  static ItemGearCreateTypeEnum valueOf(String name) => _$itemGearCreateTypeEnumValueOf(name);
}

