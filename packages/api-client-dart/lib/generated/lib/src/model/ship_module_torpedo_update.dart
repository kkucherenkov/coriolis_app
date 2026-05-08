//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_torpedo_update.g.dart';

/// PATCH payload for a TORPEDO ship module. All fields optional.
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [torpedoCount] 
/// * [mineCount] 
/// * [notes] 
@BuiltValue()
abstract class ShipModuleTorpedoUpdate implements Built<ShipModuleTorpedoUpdate, ShipModuleTorpedoUpdateBuilder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleTorpedoUpdateSlotEnum? get slot;
  // enum slotEnum {  TORPEDO,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'energyUse')
  int? get energyUse;

  @BuiltValueField(wireName: r'torpedoCount')
  int? get torpedoCount;

  @BuiltValueField(wireName: r'mineCount')
  int? get mineCount;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleTorpedoUpdate._();

  factory ShipModuleTorpedoUpdate([void updates(ShipModuleTorpedoUpdateBuilder b)]) = _$ShipModuleTorpedoUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleTorpedoUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleTorpedoUpdate> get serializer => _$ShipModuleTorpedoUpdateSerializer();
}

class _$ShipModuleTorpedoUpdateSerializer implements PrimitiveSerializer<ShipModuleTorpedoUpdate> {
  @override
  final Iterable<Type> types = const [ShipModuleTorpedoUpdate, _$ShipModuleTorpedoUpdate];

  @override
  final String wireName = r'ShipModuleTorpedoUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleTorpedoUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.slot != null) {
      yield r'slot';
      yield serializers.serialize(
        object.slot,
        specifiedType: const FullType(ShipModuleTorpedoUpdateSlotEnum),
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
    if (object.torpedoCount != null) {
      yield r'torpedoCount';
      yield serializers.serialize(
        object.torpedoCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.mineCount != null) {
      yield r'mineCount';
      yield serializers.serialize(
        object.mineCount,
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
    ShipModuleTorpedoUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleTorpedoUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleTorpedoUpdateSlotEnum),
          ) as ShipModuleTorpedoUpdateSlotEnum;
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
        case r'torpedoCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.torpedoCount = valueDes;
          break;
        case r'mineCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.mineCount = valueDes;
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
  ShipModuleTorpedoUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleTorpedoUpdateBuilder();
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

class ShipModuleTorpedoUpdateSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'TORPEDO')
  static const ShipModuleTorpedoUpdateSlotEnum TORPEDO = _$shipModuleTorpedoUpdateSlotEnum_TORPEDO;

  static Serializer<ShipModuleTorpedoUpdateSlotEnum> get serializer => _$shipModuleTorpedoUpdateSlotEnumSerializer;

  const ShipModuleTorpedoUpdateSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleTorpedoUpdateSlotEnum> get values => _$shipModuleTorpedoUpdateSlotEnumValues;
  static ShipModuleTorpedoUpdateSlotEnum valueOf(String name) => _$shipModuleTorpedoUpdateSlotEnumValueOf(name);
}

