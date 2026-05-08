//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'condition_flags.g.dart';

/// Boolean flags for the four standard Coriolis conditions (PRD §5.2). Each active condition imposes a −1 die penalty on all rolls (capped at the character's pool size). Applied by the RulesEngine. 
///
/// Properties:
/// * [exhausted] - Exhausted condition — also blocks pushing rolls
/// * [sleepless] 
/// * [thirsty] 
/// * [hungry] 
@BuiltValue()
abstract class ConditionFlags implements Built<ConditionFlags, ConditionFlagsBuilder> {
  /// Exhausted condition — also blocks pushing rolls
  @BuiltValueField(wireName: r'exhausted')
  bool get exhausted;

  @BuiltValueField(wireName: r'sleepless')
  bool get sleepless;

  @BuiltValueField(wireName: r'thirsty')
  bool get thirsty;

  @BuiltValueField(wireName: r'hungry')
  bool get hungry;

  ConditionFlags._();

  factory ConditionFlags([void updates(ConditionFlagsBuilder b)]) = _$ConditionFlags;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConditionFlagsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConditionFlags> get serializer => _$ConditionFlagsSerializer();
}

class _$ConditionFlagsSerializer implements PrimitiveSerializer<ConditionFlags> {
  @override
  final Iterable<Type> types = const [ConditionFlags, _$ConditionFlags];

  @override
  final String wireName = r'ConditionFlags';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConditionFlags object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'exhausted';
    yield serializers.serialize(
      object.exhausted,
      specifiedType: const FullType(bool),
    );
    yield r'sleepless';
    yield serializers.serialize(
      object.sleepless,
      specifiedType: const FullType(bool),
    );
    yield r'thirsty';
    yield serializers.serialize(
      object.thirsty,
      specifiedType: const FullType(bool),
    );
    yield r'hungry';
    yield serializers.serialize(
      object.hungry,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConditionFlags object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConditionFlagsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'exhausted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.exhausted = valueDes;
          break;
        case r'sleepless':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.sleepless = valueDes;
          break;
        case r'thirsty':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.thirsty = valueDes;
          break;
        case r'hungry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hungry = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConditionFlags deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConditionFlagsBuilder();
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

