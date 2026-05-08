//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/ship_module_slot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_other_create.g.dart';

/// Create payload for any other ship module slot type (BRIDGE, REACTOR, DRIVE, COMMS, HANGAR, QUARTERS, MEDICAL, WORKSHOP, CHAPEL, ESCAPE-PODS, CRYO, DOCKING, MINING, REPAIR, CONCEALED-HOLD, PROXY-DECK, OTHER). No `id` — server-assigned. 
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [notes] 
@BuiltValue()
abstract class ShipModuleOtherCreate implements Built<ShipModuleOtherCreate, ShipModuleOtherCreateBuilder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleSlot get slot;
  // enum slotEnum {  BRIDGE,  REACTOR,  DRIVE,  HOLD,  WEAPON,  TORPEDO,  SENSOR,  COMMS,  HANGAR,  QUARTERS,  MEDICAL,  WORKSHOP,  CHAPEL,  ESCAPE-PODS,  CRYO,  DOCKING,  MINING,  REPAIR,  CONCEALED-HOLD,  PROXY-DECK,  OTHER,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleOtherCreate._();

  factory ShipModuleOtherCreate([void updates(ShipModuleOtherCreateBuilder b)]) = _$ShipModuleOtherCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleOtherCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleOtherCreate> get serializer => _$ShipModuleOtherCreateSerializer();
}

class _$ShipModuleOtherCreateSerializer implements PrimitiveSerializer<ShipModuleOtherCreate> {
  @override
  final Iterable<Type> types = const [ShipModuleOtherCreate, _$ShipModuleOtherCreate];

  @override
  final String wireName = r'ShipModuleOtherCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleOtherCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    ShipModuleOtherCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleOtherCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  ShipModuleOtherCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleOtherCreateBuilder();
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

