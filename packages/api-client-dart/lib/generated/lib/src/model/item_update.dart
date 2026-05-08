//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_slot_type.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/item_range_enum.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_update.g.dart';

/// PATCH payload for updating an item. The `type` discriminator must match the existing item type — changing it returns 400 `ITEM_TYPE_MISMATCH`. All fields are optional. 
///
/// Properties:
/// * [name] 
/// * [damage] - WEAPON only
/// * [range] - WEAPON only
/// * [bonus] - WEAPON only
/// * [crit] - WEAPON only
/// * [armorRating] - ARMOR only
/// * [weight] 
/// * [features] - WEAPON or ARMOR
/// * [equipped] - WEAPON or ARMOR
/// * [quantity] - GEAR only
/// * [notes] - GEAR or OTHER
/// * [bodyPoints] - CYBERNETIC only
/// * [effect] - CYBERNETIC or SHIP_MODULE
/// * [slot] - SHIP_MODULE only
@BuiltValue()
abstract class ItemUpdate implements Built<ItemUpdate, ItemUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  /// WEAPON only
  @BuiltValueField(wireName: r'damage')
  int? get damage;

  /// WEAPON only
  @BuiltValueField(wireName: r'range')
  ItemRangeEnum? get range;
  // enum rangeEnum {  arm,  near,  short,  long,  distant,  };

  /// WEAPON only
  @BuiltValueField(wireName: r'bonus')
  int? get bonus;

  /// WEAPON only
  @BuiltValueField(wireName: r'crit')
  int? get crit;

  /// ARMOR only
  @BuiltValueField(wireName: r'armorRating')
  int? get armorRating;

  @BuiltValueField(wireName: r'weight')
  num? get weight;

  /// WEAPON or ARMOR
  @BuiltValueField(wireName: r'features')
  BuiltList<String>? get features;

  /// WEAPON or ARMOR
  @BuiltValueField(wireName: r'equipped')
  bool? get equipped;

  /// GEAR only
  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  /// GEAR or OTHER
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// CYBERNETIC only
  @BuiltValueField(wireName: r'bodyPoints')
  int? get bodyPoints;

  /// CYBERNETIC or SHIP_MODULE
  @BuiltValueField(wireName: r'effect')
  String? get effect;

  /// SHIP_MODULE only
  @BuiltValueField(wireName: r'slot')
  ItemSlotType? get slot;
  // enum slotEnum {  bridge,  hull,  hold,  weapon,  drive,  sensor,  comms,  };

  ItemUpdate._();

  factory ItemUpdate([void updates(ItemUpdateBuilder b)]) = _$ItemUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemUpdate> get serializer => _$ItemUpdateSerializer();
}

class _$ItemUpdateSerializer implements PrimitiveSerializer<ItemUpdate> {
  @override
  final Iterable<Type> types = const [ItemUpdate, _$ItemUpdate];

  @override
  final String wireName = r'ItemUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.bodyPoints != null) {
      yield r'bodyPoints';
      yield serializers.serialize(
        object.bodyPoints,
        specifiedType: const FullType(int),
      );
    }
    if (object.effect != null) {
      yield r'effect';
      yield serializers.serialize(
        object.effect,
        specifiedType: const FullType(String),
      );
    }
    if (object.slot != null) {
      yield r'slot';
      yield serializers.serialize(
        object.slot,
        specifiedType: const FullType(ItemSlotType),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemUpdateBuilder result,
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
        case r'bodyPoints':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bodyPoints = valueDes;
          break;
        case r'effect':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.effect = valueDes;
          break;
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemSlotType),
          ) as ItemSlotType;
          result.slot = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItemUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemUpdateBuilder();
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

