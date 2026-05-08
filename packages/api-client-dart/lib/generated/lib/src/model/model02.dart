//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_weapon_range.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model02.g.dart';

/// Model02
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [weaponBonus] 
/// * [weaponRange] 
/// * [weaponDamage] 
/// * [weaponCritThreshold] 
/// * [notes] 
@BuiltValue()
abstract class Model02 implements Built<Model02, Model02Builder> {
  @BuiltValueField(wireName: r'slot')
  Model02SlotEnum get slot;
  // enum slotEnum {  WEAPON,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  @BuiltValueField(wireName: r'weaponBonus')
  int get weaponBonus;

  @BuiltValueField(wireName: r'weaponRange')
  ShipWeaponRange get weaponRange;
  // enum weaponRangeEnum {  zero,  close,  medium,  long,  extreme,  };

  @BuiltValueField(wireName: r'weaponDamage')
  int get weaponDamage;

  @BuiltValueField(wireName: r'weaponCritThreshold')
  int get weaponCritThreshold;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  Model02._();

  factory Model02([void updates(Model02Builder b)]) = _$Model02;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Model02Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Model02> get serializer => _$Model02Serializer();
}

class _$Model02Serializer implements PrimitiveSerializer<Model02> {
  @override
  final Iterable<Type> types = const [Model02, _$Model02];

  @override
  final String wireName = r'Model02';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Model02 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(Model02SlotEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'energyUse';
    yield serializers.serialize(
      object.energyUse,
      specifiedType: const FullType(int),
    );
    yield r'weaponBonus';
    yield serializers.serialize(
      object.weaponBonus,
      specifiedType: const FullType(int),
    );
    yield r'weaponRange';
    yield serializers.serialize(
      object.weaponRange,
      specifiedType: const FullType(ShipWeaponRange),
    );
    yield r'weaponDamage';
    yield serializers.serialize(
      object.weaponDamage,
      specifiedType: const FullType(int),
    );
    yield r'weaponCritThreshold';
    yield serializers.serialize(
      object.weaponCritThreshold,
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
    Model02 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Model02Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Model02SlotEnum),
          ) as Model02SlotEnum;
          result.slot = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'energyUse':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.energyUse = valueDes;
          break;
        case r'weaponBonus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.weaponBonus = valueDes;
          break;
        case r'weaponRange':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipWeaponRange),
          ) as ShipWeaponRange;
          result.weaponRange = valueDes;
          break;
        case r'weaponDamage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.weaponDamage = valueDes;
          break;
        case r'weaponCritThreshold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.weaponCritThreshold = valueDes;
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
  Model02 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Model02Builder();
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

class Model02SlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WEAPON')
  static const Model02SlotEnum WEAPON = _$model02SlotEnum_WEAPON;

  static Serializer<Model02SlotEnum> get serializer => _$model02SlotEnumSerializer;

  const Model02SlotEnum._(String name): super(name);

  static BuiltSet<Model02SlotEnum> get values => _$model02SlotEnumValues;
  static Model02SlotEnum valueOf(String name) => _$model02SlotEnumValueOf(name);
}

