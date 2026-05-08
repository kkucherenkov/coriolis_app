//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model42.g.dart';

/// Model42
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [notes] 
@BuiltValue()
abstract class Model42 implements Built<Model42, Model42Builder> {
  @BuiltValueField(wireName: r'slot')
  Model42SlotEnum get slot;
  // enum slotEnum {  BRIDGE,  REACTOR,  DRIVE,  COMMS,  HANGAR,  QUARTERS,  MEDICAL,  WORKSHOP,  CHAPEL,  ESCAPE-PODS,  CRYO,  DOCKING,  MINING,  REPAIR,  CONCEALED-HOLD,  PROXY-DECK,  OTHER,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  Model42._();

  factory Model42([void updates(Model42Builder b)]) = _$Model42;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Model42Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Model42> get serializer => _$Model42Serializer();
}

class _$Model42Serializer implements PrimitiveSerializer<Model42> {
  @override
  final Iterable<Type> types = const [Model42, _$Model42];

  @override
  final String wireName = r'Model42';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Model42 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(Model42SlotEnum),
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
    Model42 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Model42Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Model42SlotEnum),
          ) as Model42SlotEnum;
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
  Model42 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Model42Builder();
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

class Model42SlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'BRIDGE')
  static const Model42SlotEnum BRIDGE = _$model42SlotEnum_BRIDGE;
  @BuiltValueEnumConst(wireName: r'REACTOR')
  static const Model42SlotEnum REACTOR = _$model42SlotEnum_REACTOR;
  @BuiltValueEnumConst(wireName: r'DRIVE')
  static const Model42SlotEnum DRIVE = _$model42SlotEnum_DRIVE;
  @BuiltValueEnumConst(wireName: r'COMMS')
  static const Model42SlotEnum COMMS = _$model42SlotEnum_COMMS;
  @BuiltValueEnumConst(wireName: r'HANGAR')
  static const Model42SlotEnum HANGAR = _$model42SlotEnum_HANGAR;
  @BuiltValueEnumConst(wireName: r'QUARTERS')
  static const Model42SlotEnum QUARTERS = _$model42SlotEnum_QUARTERS;
  @BuiltValueEnumConst(wireName: r'MEDICAL')
  static const Model42SlotEnum MEDICAL = _$model42SlotEnum_MEDICAL;
  @BuiltValueEnumConst(wireName: r'WORKSHOP')
  static const Model42SlotEnum WORKSHOP = _$model42SlotEnum_WORKSHOP;
  @BuiltValueEnumConst(wireName: r'CHAPEL')
  static const Model42SlotEnum CHAPEL = _$model42SlotEnum_CHAPEL;
  @BuiltValueEnumConst(wireName: r'ESCAPE-PODS')
  static const Model42SlotEnum ESCAPE_PODS = _$model42SlotEnum_ESCAPE_PODS;
  @BuiltValueEnumConst(wireName: r'CRYO')
  static const Model42SlotEnum CRYO = _$model42SlotEnum_CRYO;
  @BuiltValueEnumConst(wireName: r'DOCKING')
  static const Model42SlotEnum DOCKING = _$model42SlotEnum_DOCKING;
  @BuiltValueEnumConst(wireName: r'MINING')
  static const Model42SlotEnum MINING = _$model42SlotEnum_MINING;
  @BuiltValueEnumConst(wireName: r'REPAIR')
  static const Model42SlotEnum REPAIR = _$model42SlotEnum_REPAIR;
  @BuiltValueEnumConst(wireName: r'CONCEALED-HOLD')
  static const Model42SlotEnum CONCEALED_HOLD = _$model42SlotEnum_CONCEALED_HOLD;
  @BuiltValueEnumConst(wireName: r'PROXY-DECK')
  static const Model42SlotEnum PROXY_DECK = _$model42SlotEnum_PROXY_DECK;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const Model42SlotEnum OTHER = _$model42SlotEnum_OTHER;

  static Serializer<Model42SlotEnum> get serializer => _$model42SlotEnumSerializer;

  const Model42SlotEnum._(String name): super(name);

  static BuiltSet<Model42SlotEnum> get values => _$model42SlotEnumValues;
  static Model42SlotEnum valueOf(String name) => _$model42SlotEnumValueOf(name);
}

