//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_create_one_of1.g.dart';

/// ShipModuleCreateOneOf1
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [torpedoCount] 
/// * [mineCount] 
/// * [notes] 
@BuiltValue()
abstract class ShipModuleCreateOneOf1 implements Built<ShipModuleCreateOneOf1, ShipModuleCreateOneOf1Builder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleCreateOneOf1SlotEnum get slot;
  // enum slotEnum {  TORPEDO,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'energyUse')
  int get energyUse;

  @BuiltValueField(wireName: r'torpedoCount')
  int? get torpedoCount;

  @BuiltValueField(wireName: r'mineCount')
  int? get mineCount;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleCreateOneOf1._();

  factory ShipModuleCreateOneOf1([void updates(ShipModuleCreateOneOf1Builder b)]) = _$ShipModuleCreateOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleCreateOneOf1Builder b) => b
      ..torpedoCount = 0
      ..mineCount = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleCreateOneOf1> get serializer => _$ShipModuleCreateOneOf1Serializer();
}

class _$ShipModuleCreateOneOf1Serializer implements PrimitiveSerializer<ShipModuleCreateOneOf1> {
  @override
  final Iterable<Type> types = const [ShipModuleCreateOneOf1, _$ShipModuleCreateOneOf1];

  @override
  final String wireName = r'ShipModuleCreateOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleCreateOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleCreateOneOf1SlotEnum),
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
    ShipModuleCreateOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleCreateOneOf1Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleCreateOneOf1SlotEnum),
          ) as ShipModuleCreateOneOf1SlotEnum;
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
  ShipModuleCreateOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleCreateOneOf1Builder();
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

class ShipModuleCreateOneOf1SlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'TORPEDO')
  static const ShipModuleCreateOneOf1SlotEnum TORPEDO = _$shipModuleCreateOneOf1SlotEnum_TORPEDO;

  static Serializer<ShipModuleCreateOneOf1SlotEnum> get serializer => _$shipModuleCreateOneOf1SlotEnumSerializer;

  const ShipModuleCreateOneOf1SlotEnum._(String name): super(name);

  static BuiltSet<ShipModuleCreateOneOf1SlotEnum> get values => _$shipModuleCreateOneOf1SlotEnumValues;
  static ShipModuleCreateOneOf1SlotEnum valueOf(String name) => _$shipModuleCreateOneOf1SlotEnumValueOf(name);
}

