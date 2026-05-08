//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_hold_update.g.dart';

/// PATCH payload for a HOLD ship module. All fields optional.
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [cargoTons] 
/// * [concealed] 
/// * [notes] 
@BuiltValue()
abstract class ShipModuleHoldUpdate implements Built<ShipModuleHoldUpdate, ShipModuleHoldUpdateBuilder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleHoldUpdateSlotEnum? get slot;
  // enum slotEnum {  HOLD,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'energyUse')
  int? get energyUse;

  @BuiltValueField(wireName: r'cargoTons')
  int? get cargoTons;

  @BuiltValueField(wireName: r'concealed')
  bool? get concealed;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleHoldUpdate._();

  factory ShipModuleHoldUpdate([void updates(ShipModuleHoldUpdateBuilder b)]) = _$ShipModuleHoldUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleHoldUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleHoldUpdate> get serializer => _$ShipModuleHoldUpdateSerializer();
}

class _$ShipModuleHoldUpdateSerializer implements PrimitiveSerializer<ShipModuleHoldUpdate> {
  @override
  final Iterable<Type> types = const [ShipModuleHoldUpdate, _$ShipModuleHoldUpdate];

  @override
  final String wireName = r'ShipModuleHoldUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleHoldUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.slot != null) {
      yield r'slot';
      yield serializers.serialize(
        object.slot,
        specifiedType: const FullType(ShipModuleHoldUpdateSlotEnum),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.energyUse != null) {
      yield r'energyUse';
      yield serializers.serialize(
        object.energyUse,
        specifiedType: const FullType(int),
      );
    }
    if (object.cargoTons != null) {
      yield r'cargoTons';
      yield serializers.serialize(
        object.cargoTons,
        specifiedType: const FullType(int),
      );
    }
    if (object.concealed != null) {
      yield r'concealed';
      yield serializers.serialize(
        object.concealed,
        specifiedType: const FullType(bool),
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
    ShipModuleHoldUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleHoldUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleHoldUpdateSlotEnum),
          ) as ShipModuleHoldUpdateSlotEnum;
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
        case r'cargoTons':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cargoTons = valueDes;
          break;
        case r'concealed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.concealed = valueDes;
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
  ShipModuleHoldUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleHoldUpdateBuilder();
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

class ShipModuleHoldUpdateSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'HOLD')
  static const ShipModuleHoldUpdateSlotEnum HOLD = _$shipModuleHoldUpdateSlotEnum_HOLD;

  static Serializer<ShipModuleHoldUpdateSlotEnum> get serializer => _$shipModuleHoldUpdateSlotEnumSerializer;

  const ShipModuleHoldUpdateSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleHoldUpdateSlotEnum> get values => _$shipModuleHoldUpdateSlotEnumValues;
  static ShipModuleHoldUpdateSlotEnum valueOf(String name) => _$shipModuleHoldUpdateSlotEnumValueOf(name);
}

