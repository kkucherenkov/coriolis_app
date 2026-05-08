//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/ship_module_slot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_base.g.dart';

/// Fields common to every ship module variant
///
/// Properties:
/// * [id] - Opaque module identifier (cuid2)
/// * [slot] 
/// * [name] - Module name (e.g. \"Graviton Projector\", \"Smuggler hold\")
/// * [energyUse] - Energy points consumed by this module when active
/// * [notes] - Free-text notes; used for damage state, special conditions, etc.
@BuiltValue(instantiable: false)
abstract class ShipModuleBase  {
  /// Opaque module identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'slot')
  ShipModuleSlot get slot;
  // enum slotEnum {  BRIDGE,  REACTOR,  DRIVE,  HOLD,  WEAPON,  TORPEDO,  SENSOR,  COMMS,  HANGAR,  QUARTERS,  MEDICAL,  WORKSHOP,  CHAPEL,  ESCAPE-PODS,  CRYO,  DOCKING,  MINING,  REPAIR,  CONCEALED-HOLD,  PROXY-DECK,  OTHER,  };

  /// Module name (e.g. \"Graviton Projector\", \"Smuggler hold\")
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Energy points consumed by this module when active
  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  /// Free-text notes; used for damage state, special conditions, etc.
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleBase> get serializer => _$ShipModuleBaseSerializer();
}

class _$ShipModuleBaseSerializer implements PrimitiveSerializer<ShipModuleBase> {
  @override
  final Iterable<Type> types = const [ShipModuleBase];

  @override
  final String wireName = r'ShipModuleBase';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleBase object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    ShipModuleBase object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  ShipModuleBase deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($ShipModuleBase)) as $ShipModuleBase;
  }
}

/// a concrete implementation of [ShipModuleBase], since [ShipModuleBase] is not instantiable
@BuiltValue(instantiable: true)
abstract class $ShipModuleBase implements ShipModuleBase, Built<$ShipModuleBase, $ShipModuleBaseBuilder> {
  $ShipModuleBase._();

  factory $ShipModuleBase([void Function($ShipModuleBaseBuilder)? updates]) = _$$ShipModuleBase;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($ShipModuleBaseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$ShipModuleBase> get serializer => _$$ShipModuleBaseSerializer();
}

class _$$ShipModuleBaseSerializer implements PrimitiveSerializer<$ShipModuleBase> {
  @override
  final Iterable<Type> types = const [$ShipModuleBase, _$$ShipModuleBase];

  @override
  final String wireName = r'$ShipModuleBase';

  @override
  Object serialize(
    Serializers serializers,
    $ShipModuleBase object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(ShipModuleBase))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleBaseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  $ShipModuleBase deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $ShipModuleBaseBuilder();
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

