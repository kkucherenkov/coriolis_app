//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/item_range_enum.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_weapon_update.g.dart';

/// PATCH payload for a WEAPON item. All fields optional.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [damage] 
/// * [range] 
/// * [bonus] 
/// * [crit] 
/// * [weight] 
/// * [features] 
/// * [equipped] 
@BuiltValue()
abstract class ItemWeaponUpdate implements Built<ItemWeaponUpdate, ItemWeaponUpdateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemWeaponUpdateTypeEnum? get type;
  // enum typeEnum {  WEAPON,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'damage')
  int? get damage;

  @BuiltValueField(wireName: r'range')
  ItemRangeEnum? get range;
  // enum rangeEnum {  close,  medium,  long,  extreme,  };

  @BuiltValueField(wireName: r'bonus')
  int? get bonus;

  @BuiltValueField(wireName: r'crit')
  int? get crit;

  @BuiltValueField(wireName: r'weight')
  num? get weight;

  @BuiltValueField(wireName: r'features')
  BuiltList<String>? get features;

  @BuiltValueField(wireName: r'equipped')
  bool? get equipped;

  ItemWeaponUpdate._();

  factory ItemWeaponUpdate([void updates(ItemWeaponUpdateBuilder b)]) = _$ItemWeaponUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemWeaponUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemWeaponUpdate> get serializer => _$ItemWeaponUpdateSerializer();
}

class _$ItemWeaponUpdateSerializer implements PrimitiveSerializer<ItemWeaponUpdate> {
  @override
  final Iterable<Type> types = const [ItemWeaponUpdate, _$ItemWeaponUpdate];

  @override
  final String wireName = r'ItemWeaponUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemWeaponUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(ItemWeaponUpdateTypeEnum),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.damage != null) {
      yield r'damage';
      yield serializers.serialize(
        object.damage,
        specifiedType: const FullType(int),
      );
    }
    if (object.range != null) {
      yield r'range';
      yield serializers.serialize(
        object.range,
        specifiedType: const FullType(ItemRangeEnum),
      );
    }
    if (object.bonus != null) {
      yield r'bonus';
      yield serializers.serialize(
        object.bonus,
        specifiedType: const FullType(int),
      );
    }
    if (object.crit != null) {
      yield r'crit';
      yield serializers.serialize(
        object.crit,
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
    ItemWeaponUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemWeaponUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemWeaponUpdateTypeEnum),
          ) as ItemWeaponUpdateTypeEnum;
          result.type = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'damage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.damage = valueDes;
          break;
        case r'range':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemRangeEnum),
          ) as ItemRangeEnum;
          result.range = valueDes;
          break;
        case r'bonus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bonus = valueDes;
          break;
        case r'crit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.crit = valueDes;
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
  ItemWeaponUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemWeaponUpdateBuilder();
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

class ItemWeaponUpdateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WEAPON')
  static const ItemWeaponUpdateTypeEnum WEAPON = _$itemWeaponUpdateTypeEnum_WEAPON;

  static Serializer<ItemWeaponUpdateTypeEnum> get serializer => _$itemWeaponUpdateTypeEnumSerializer;

  const ItemWeaponUpdateTypeEnum._(String name): super(name);

  static BuiltSet<ItemWeaponUpdateTypeEnum> get values => _$itemWeaponUpdateTypeEnumValues;
  static ItemWeaponUpdateTypeEnum valueOf(String name) => _$itemWeaponUpdateTypeEnumValueOf(name);
}

