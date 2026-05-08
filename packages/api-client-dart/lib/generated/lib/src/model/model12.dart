//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'model12.g.dart';

/// Model12
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [torpedoCount] 
/// * [mineCount] 
/// * [notes] 
@BuiltValue()
abstract class Model12 implements Built<Model12, Model12Builder> {
  @BuiltValueField(wireName: r'slot')
  Model12SlotEnum get slot;
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

  Model12._();

  factory Model12([void updates(Model12Builder b)]) = _$Model12;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Model12Builder b) => b
      ..torpedoCount = 0
      ..mineCount = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<Model12> get serializer => _$Model12Serializer();
}

class _$Model12Serializer implements PrimitiveSerializer<Model12> {
  @override
  final Iterable<Type> types = const [Model12, _$Model12];

  @override
  final String wireName = r'Model12';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Model12 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(Model12SlotEnum),
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
    Model12 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Model12Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Model12SlotEnum),
          ) as Model12SlotEnum;
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
  Model12 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Model12Builder();
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

class Model12SlotEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'TORPEDO')
  static const Model12SlotEnum TORPEDO = _$model12SlotEnum_TORPEDO;

  static Serializer<Model12SlotEnum> get serializer => _$model12SlotEnumSerializer;

  const Model12SlotEnum._(String name): super(name);

  static BuiltSet<Model12SlotEnum> get values => _$model12SlotEnumValues;
  static Model12SlotEnum valueOf(String name) => _$model12SlotEnumValueOf(name);
}

