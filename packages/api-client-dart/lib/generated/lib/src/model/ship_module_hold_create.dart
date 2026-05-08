//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_hold_create.g.dart';

/// Create payload for a HOLD ship module. No `id` — server-assigned.
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [cargoTons] - Cargo capacity in tonnes
/// * [concealed] - True for a concealed hold
/// * [notes] 
@BuiltValue()
abstract class ShipModuleHoldCreate implements Built<ShipModuleHoldCreate, ShipModuleHoldCreateBuilder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleHoldCreateSlotEnum get slot;
  // enum slotEnum {  HOLD,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  /// Cargo capacity in tonnes
  @BuiltValueField(wireName: r'cargoTons')
  int? get cargoTons;

  /// True for a concealed hold
  @BuiltValueField(wireName: r'concealed')
  bool? get concealed;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleHoldCreate._();

  factory ShipModuleHoldCreate([void updates(ShipModuleHoldCreateBuilder b)]) = _$ShipModuleHoldCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleHoldCreateBuilder b) => b
      ..cargoTons = 0
      ..concealed = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleHoldCreate> get serializer => _$ShipModuleHoldCreateSerializer();
}

class _$ShipModuleHoldCreateSerializer implements PrimitiveSerializer<ShipModuleHoldCreate> {
  @override
  final Iterable<Type> types = const [ShipModuleHoldCreate, _$ShipModuleHoldCreate];

  @override
  final String wireName = r'ShipModuleHoldCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleHoldCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleHoldCreateSlotEnum),
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
    ShipModuleHoldCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleHoldCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleHoldCreateSlotEnum),
          ) as ShipModuleHoldCreateSlotEnum;
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
  ShipModuleHoldCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleHoldCreateBuilder();
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

class ShipModuleHoldCreateSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'HOLD')
  static const ShipModuleHoldCreateSlotEnum HOLD = _$shipModuleHoldCreateSlotEnum_HOLD;

  static Serializer<ShipModuleHoldCreateSlotEnum> get serializer => _$shipModuleHoldCreateSlotEnumSerializer;

  const ShipModuleHoldCreateSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleHoldCreateSlotEnum> get values => _$shipModuleHoldCreateSlotEnumValues;
  static ShipModuleHoldCreateSlotEnum valueOf(String name) => _$shipModuleHoldCreateSlotEnumValueOf(name);
}

