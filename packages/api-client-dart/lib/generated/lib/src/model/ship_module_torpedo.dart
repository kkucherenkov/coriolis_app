//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_module_base.dart';
import 'package:app_api_client/src/model/ship_module_slot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_torpedo.g.dart';

/// ShipModuleTorpedo
///
/// Properties:
/// * [id] - Opaque module identifier (cuid2)
/// * [slot] 
/// * [name] - Module name (e.g. \"Graviton Projector\", \"Smuggler hold\")
/// * [energyUse] - Energy points consumed by this module when active
/// * [notes] - Free-text notes; used for damage state, special conditions, etc.
/// * [torpedoCount] - Number of torpedoes currently loaded
/// * [mineCount] - Number of mines currently loaded
@BuiltValue()
abstract class ShipModuleTorpedo implements ShipModuleBase, Built<ShipModuleTorpedo, ShipModuleTorpedoBuilder> {
  /// Number of mines currently loaded
  @BuiltValueField(wireName: r'mineCount')
  int? get mineCount;

  /// Number of torpedoes currently loaded
  @BuiltValueField(wireName: r'torpedoCount')
  int? get torpedoCount;

  ShipModuleTorpedo._();

  factory ShipModuleTorpedo([void updates(ShipModuleTorpedoBuilder b)]) = _$ShipModuleTorpedo;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleTorpedoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleTorpedo> get serializer => _$ShipModuleTorpedoSerializer();
}

class _$ShipModuleTorpedoSerializer implements PrimitiveSerializer<ShipModuleTorpedo> {
  @override
  final Iterable<Type> types = const [ShipModuleTorpedo, _$ShipModuleTorpedo];

  @override
  final String wireName = r'ShipModuleTorpedo';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleTorpedo object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.mineCount != null) {
      yield r'mineCount';
      yield serializers.serialize(
        object.mineCount,
        specifiedType: const FullType(int),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.torpedoCount != null) {
      yield r'torpedoCount';
      yield serializers.serialize(
        object.torpedoCount,
        specifiedType: const FullType(int),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleSlot),
    );
    yield r'energyUse';
    yield serializers.serialize(
      object.energyUse,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleTorpedo object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleTorpedoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'mineCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.mineCount = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'torpedoCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.torpedoCount = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleSlot),
          ) as ShipModuleSlot;
          result.slot = valueDes;
          break;
        case r'energyUse':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.energyUse = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShipModuleTorpedo deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleTorpedoBuilder();
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

class ShipModuleTorpedoSlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'TORPEDO')
  static const ShipModuleTorpedoSlotEnum TORPEDO = _$shipModuleTorpedoSlotEnum_TORPEDO;

  static Serializer<ShipModuleTorpedoSlotEnum> get serializer => _$shipModuleTorpedoSlotEnumSerializer;

  const ShipModuleTorpedoSlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleTorpedoSlotEnum> get values => _$shipModuleTorpedoSlotEnumValues;
  static ShipModuleTorpedoSlotEnum valueOf(String name) => _$shipModuleTorpedoSlotEnumValueOf(name);
}

