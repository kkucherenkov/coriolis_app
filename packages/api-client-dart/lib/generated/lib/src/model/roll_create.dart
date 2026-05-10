//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'roll_create.g.dart';

/// Payload for POST /api/v1/characters/{id}/rolls
///
/// Properties:
/// * [label] - Human-readable roll label, e.g. \"Pilot · Evade\"
/// * [pool] - Number of d6 to roll. Must be between 0 and 20 inclusive. Condition pool penalties must be pre-applied by the caller before submitting.  «Ноль кубиков» (ГЛАВА 3 line 161): if modifiers reduce the pool to zero (or below), submit `pool: 0`. The engine then rolls 2d6 and counts a success only when both dice are 6.  PRD override — ST3001 does not name a hard upper bound. We cap at 20 to keep wire payloads bounded; realistic attribute + skill + gear + helpers stacks max out around 12–14. 
/// * [gameSessionId] - Optional game session identifier. Reserved for Feature 7.2. Pass null or omit until GameSession lands. 
@BuiltValue()
abstract class RollCreate implements Built<RollCreate, RollCreateBuilder> {
  /// Human-readable roll label, e.g. \"Pilot · Evade\"
  @BuiltValueField(wireName: r'label')
  String get label;

  /// Number of d6 to roll. Must be between 0 and 20 inclusive. Condition pool penalties must be pre-applied by the caller before submitting.  «Ноль кубиков» (ГЛАВА 3 line 161): if modifiers reduce the pool to zero (or below), submit `pool: 0`. The engine then rolls 2d6 and counts a success only when both dice are 6.  PRD override — ST3001 does not name a hard upper bound. We cap at 20 to keep wire payloads bounded; realistic attribute + skill + gear + helpers stacks max out around 12–14. 
  @BuiltValueField(wireName: r'pool')
  int get pool;

  /// Optional game session identifier. Reserved for Feature 7.2. Pass null or omit until GameSession lands. 
  @BuiltValueField(wireName: r'gameSessionId')
  String? get gameSessionId;

  RollCreate._();

  factory RollCreate([void updates(RollCreateBuilder b)]) = _$RollCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RollCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RollCreate> get serializer => _$RollCreateSerializer();
}

class _$RollCreateSerializer implements PrimitiveSerializer<RollCreate> {
  @override
  final Iterable<Type> types = const [RollCreate, _$RollCreate];

  @override
  final String wireName = r'RollCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RollCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'pool';
    yield serializers.serialize(
      object.pool,
      specifiedType: const FullType(int),
    );
    if (object.gameSessionId != null) {
      yield r'gameSessionId';
      yield serializers.serialize(
        object.gameSessionId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RollCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RollCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'pool':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pool = valueDes;
          break;
        case r'gameSessionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.gameSessionId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RollCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RollCreateBuilder();
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

