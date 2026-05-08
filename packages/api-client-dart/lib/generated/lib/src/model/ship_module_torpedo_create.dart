//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_torpedo_create.g.dart';

/// Create payload for a TORPEDO ship module. No `id` — server-assigned.
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [torpedoCount] - Number of torpedoes currently loaded
/// * [mineCount] - Number of mines currently loaded
/// * [notes] 
@BuiltValue()
abstract class ShipModuleTorpedoCreate implements Built<ShipModuleTorpedoCreate, ShipModuleTorpedoCreateBuilder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleTorpedoCreateSlotEnum get slot;
  // enum slotEnum {  TORPEDO,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  /// Number of torpedoes currently loaded
  @BuiltValueField(wireName: r'torpedoCount')
  int? get torpedoCount;

  /// Number of mines currently loaded
  @BuiltValueField(wireName: r'mineCount')
  int? get mineCount;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleTorpedoCreate._();

  factory ShipModuleTorpedoCreate([void updates(ShipModuleTorpedoCreateBuilder b)]) = _$ShipModuleTorpedoCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleTorpedoCreateBuilder b) => b
      ..torpedoCount = 0
      ..mineCount = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleTorpedoCreate> get serializer => _$ShipModuleTorpedoCreateSerializer();
}

class _$ShipModuleTorpedoCreateSerializer implements PrimitiveSerializer<ShipModuleTorpedoCreate> {
  @override
  final Iterable<Type> types = const [ShipModuleTorpedoCreate, _$ShipModuleTorpedoCreate];

  @override
  final String wireName = r'ShipModuleTorpedoCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleTorpedoCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleTorpedoCreateSlotEnum),
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
    ShipModuleTorpedoCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleTorpedoCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleTorpedoCreateSlotEnum),
          ) as ShipModuleTorpedoCreateSlotEnum;
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
  ShipModuleTorpedoCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleTorpedoCreateBuilder();
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

class ShipModuleTorpedoCreateSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'TORPEDO')
  static const ShipModuleTorpedoCreateSlotEnum TORPEDO = _$shipModuleTorpedoCreateSlotEnum_TORPEDO;

  static Serializer<ShipModuleTorpedoCreateSlotEnum> get serializer => _$shipModuleTorpedoCreateSlotEnumSerializer;

  const ShipModuleTorpedoCreateSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleTorpedoCreateSlotEnum> get values => _$shipModuleTorpedoCreateSlotEnumValues;
  static ShipModuleTorpedoCreateSlotEnum valueOf(String name) => _$shipModuleTorpedoCreateSlotEnumValueOf(name);
}

