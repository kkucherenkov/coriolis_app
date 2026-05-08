//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_create_one_of2.g.dart';

/// ShipModuleCreateOneOf2
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [cargoTons] 
/// * [concealed] 
/// * [notes] 
@BuiltValue()
abstract class ShipModuleCreateOneOf2 implements Built<ShipModuleCreateOneOf2, ShipModuleCreateOneOf2Builder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleCreateOneOf2SlotEnum get slot;
  // enum slotEnum {  HOLD,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  @BuiltValueField(wireName: r'cargoTons')
  int? get cargoTons;

  @BuiltValueField(wireName: r'concealed')
  bool? get concealed;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleCreateOneOf2._();

  factory ShipModuleCreateOneOf2([void updates(ShipModuleCreateOneOf2Builder b)]) = _$ShipModuleCreateOneOf2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleCreateOneOf2Builder b) => b
      ..cargoTons = 0
      ..concealed = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleCreateOneOf2> get serializer => _$ShipModuleCreateOneOf2Serializer();
}

class _$ShipModuleCreateOneOf2Serializer implements PrimitiveSerializer<ShipModuleCreateOneOf2> {
  @override
  final Iterable<Type> types = const [ShipModuleCreateOneOf2, _$ShipModuleCreateOneOf2];

  @override
  final String wireName = r'ShipModuleCreateOneOf2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleCreateOneOf2 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleCreateOneOf2SlotEnum),
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
    ShipModuleCreateOneOf2 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleCreateOneOf2Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleCreateOneOf2SlotEnum),
          ) as ShipModuleCreateOneOf2SlotEnum;
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
  ShipModuleCreateOneOf2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleCreateOneOf2Builder();
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

class ShipModuleCreateOneOf2SlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'HOLD')
  static const ShipModuleCreateOneOf2SlotEnum HOLD = _$shipModuleCreateOneOf2SlotEnum_HOLD;

  static Serializer<ShipModuleCreateOneOf2SlotEnum> get serializer => _$shipModuleCreateOneOf2SlotEnumSerializer;

  const ShipModuleCreateOneOf2SlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleCreateOneOf2SlotEnum> get values => _$shipModuleCreateOneOf2SlotEnumValues;
  static ShipModuleCreateOneOf2SlotEnum valueOf(String name) => _$shipModuleCreateOneOf2SlotEnumValueOf(name);
}

