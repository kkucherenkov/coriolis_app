//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_armor_create.g.dart';

/// Create payload for an ARMOR item. No `id` — server-assigned.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [armorRating] - Armor rating — reduces incoming damage
/// * [weight] - Encumbrance weight in slots
/// * [features] - Feature tags (e.g. \"Vacuum Sealed\", \"Exo-Skeleton\")
/// * [equipped] 
@BuiltValue()
abstract class ItemArmorCreate implements Built<ItemArmorCreate, ItemArmorCreateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemArmorCreateTypeEnum get type;
  // enum typeEnum {  ARMOR,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  /// Armor rating — reduces incoming damage
  @BuiltValueField(wireName: r'armorRating')
  int get armorRating;

  /// Encumbrance weight in slots
  @BuiltValueField(wireName: r'weight')
  num get weight;

  /// Feature tags (e.g. \"Vacuum Sealed\", \"Exo-Skeleton\")
  @BuiltValueField(wireName: r'features')
  BuiltList<String> get features;

  @BuiltValueField(wireName: r'equipped')
  bool get equipped;

  ItemArmorCreate._();

  factory ItemArmorCreate([void updates(ItemArmorCreateBuilder b)]) = _$ItemArmorCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemArmorCreateBuilder b) => b
      ..equipped = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemArmorCreate> get serializer => _$ItemArmorCreateSerializer();
}

class _$ItemArmorCreateSerializer implements PrimitiveSerializer<ItemArmorCreate> {
  @override
  final Iterable<Type> types = const [ItemArmorCreate, _$ItemArmorCreate];

  @override
  final String wireName = r'ItemArmorCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemArmorCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(ItemArmorCreateTypeEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'armorRating';
    yield serializers.serialize(
      object.armorRating,
      specifiedType: const FullType(int),
    );
    yield r'weight';
    yield serializers.serialize(
      object.weight,
      specifiedType: const FullType(num),
    );
    yield r'features';
    yield serializers.serialize(
      object.features,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'equipped';
    yield serializers.serialize(
      object.equipped,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemArmorCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemArmorCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemArmorCreateTypeEnum),
          ) as ItemArmorCreateTypeEnum;
          result.type = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'armorRating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.armorRating = valueDes;
          break;
        case r'weight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.weight = valueDes;
          break;
        case r'features':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.features.replace(valueDes);
          break;
        case r'equipped':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.equipped = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItemArmorCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemArmorCreateBuilder();
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

class ItemArmorCreateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ARMOR')
  static const ItemArmorCreateTypeEnum ARMOR = _$itemArmorCreateTypeEnum_ARMOR;

  static Serializer<ItemArmorCreateTypeEnum> get serializer => _$itemArmorCreateTypeEnumSerializer;

  const ItemArmorCreateTypeEnum._(String name): super(name);

  static BuiltSet<ItemArmorCreateTypeEnum> get values => _$itemArmorCreateTypeEnumValues;
  static ItemArmorCreateTypeEnum valueOf(String name) => _$itemArmorCreateTypeEnumValueOf(name);
}

