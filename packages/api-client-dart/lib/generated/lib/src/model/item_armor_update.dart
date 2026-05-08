//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_armor_update.g.dart';

/// PATCH payload for an ARMOR item. All fields optional.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [armorRating] 
/// * [weight] 
/// * [features] 
/// * [equipped] 
@BuiltValue()
abstract class ItemArmorUpdate implements Built<ItemArmorUpdate, ItemArmorUpdateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemArmorUpdateTypeEnum? get type;
  // enum typeEnum {  ARMOR,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'armorRating')
  int? get armorRating;

  @BuiltValueField(wireName: r'weight')
  num? get weight;

  @BuiltValueField(wireName: r'features')
  BuiltList<String>? get features;

  @BuiltValueField(wireName: r'equipped')
  bool? get equipped;

  ItemArmorUpdate._();

  factory ItemArmorUpdate([void updates(ItemArmorUpdateBuilder b)]) = _$ItemArmorUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemArmorUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemArmorUpdate> get serializer => _$ItemArmorUpdateSerializer();
}

class _$ItemArmorUpdateSerializer implements PrimitiveSerializer<ItemArmorUpdate> {
  @override
  final Iterable<Type> types = const [ItemArmorUpdate, _$ItemArmorUpdate];

  @override
  final String wireName = r'ItemArmorUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemArmorUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(ItemArmorUpdateTypeEnum),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.armorRating != null) {
      yield r'armorRating';
      yield serializers.serialize(
        object.armorRating,
        specifiedType: const FullType(int),
      );
    }
    if (object.weight != null) {
      yield r'weight';
      yield serializers.serialize(
        object.weight,
        specifiedType: const FullType(num),
      );
    }
    if (object.features != null) {
      yield r'features';
      yield serializers.serialize(
        object.features,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.equipped != null) {
      yield r'equipped';
      yield serializers.serialize(
        object.equipped,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemArmorUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemArmorUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemArmorUpdateTypeEnum),
          ) as ItemArmorUpdateTypeEnum;
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
  ItemArmorUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemArmorUpdateBuilder();
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

class ItemArmorUpdateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ARMOR')
  static const ItemArmorUpdateTypeEnum ARMOR = _$itemArmorUpdateTypeEnum_ARMOR;

  static Serializer<ItemArmorUpdateTypeEnum> get serializer => _$itemArmorUpdateTypeEnumSerializer;

  const ItemArmorUpdateTypeEnum._(String name): super(name);

  static BuiltSet<ItemArmorUpdateTypeEnum> get values => _$itemArmorUpdateTypeEnumValues;
  static ItemArmorUpdateTypeEnum valueOf(String name) => _$itemArmorUpdateTypeEnumValueOf(name);
}

