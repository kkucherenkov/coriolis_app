//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/roll_kind.dart';
import 'package:app_api_client/src/model/roll_breakdown.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'roll_create.g.dart';

/// Payload for POST /api/v1/characters/{id}/rolls
///
/// Properties:
/// * [kind] - What kind of roll to create. Defaults to `skill` when omitted (back-compat for callers from before T-2026-05-10-015 landed). Once persisted, the kind is immutable. 
/// * [label] - Human-readable roll label, e.g. \"Pilot · Evade\"
/// * [pool] - Number of d6 to roll. Must be between 0 and 20 inclusive. Condition pool penalties must be pre-applied by the caller before submitting.  «Ноль кубиков» (ГЛАВА 3 line 161): if modifiers reduce the pool to zero (or below), submit `pool: 0`. The engine then rolls 2d6 and counts a success only when both dice are 6.  PRD override — ST3001 does not name a hard upper bound. We cap at 20 to keep wire payloads bounded; realistic attribute + skill + gear + helpers stacks max out around 12–14. 
/// * [gameSessionId] - Optional game session identifier. Reserved for Feature 7.2. Pass null or omit until GameSession lands. 
/// * [breakdown] 
@BuiltValue()
abstract class RollCreate implements Built<RollCreate, RollCreateBuilder> {
  /// What kind of roll to create. Defaults to `skill` when omitted (back-compat for callers from before T-2026-05-10-015 landed). Once persisted, the kind is immutable. 
  @BuiltValueField(wireName: r'kind')
  RollKind? get kind;
  // enum kindEnum {  skill,  save,  trauma,  initiative,  darkness,  };

  /// Human-readable roll label, e.g. \"Pilot · Evade\"
  @BuiltValueField(wireName: r'label')
  String get label;

  /// Number of d6 to roll. Must be between 0 and 20 inclusive. Condition pool penalties must be pre-applied by the caller before submitting.  «Ноль кубиков» (ГЛАВА 3 line 161): if modifiers reduce the pool to zero (or below), submit `pool: 0`. The engine then rolls 2d6 and counts a success only when both dice are 6.  PRD override — ST3001 does not name a hard upper bound. We cap at 20 to keep wire payloads bounded; realistic attribute + skill + gear + helpers stacks max out around 12–14. 
  @BuiltValueField(wireName: r'pool')
  int get pool;

  /// Optional game session identifier. Reserved for Feature 7.2. Pass null or omit until GameSession lands. 
  @BuiltValueField(wireName: r'gameSessionId')
  String? get gameSessionId;

  @BuiltValueField(wireName: r'breakdown')
  RollBreakdown? get breakdown;

  RollCreate._();

  factory RollCreate([void updates(RollCreateBuilder b)]) = _$RollCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RollCreateBuilder b) => b
      ..kind = RollKind.skill;

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
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(RollKind),
      );
    }
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
    if (object.breakdown != null) {
      yield r'breakdown';
      yield serializers.serialize(
        object.breakdown,
        specifiedType: const FullType.nullable(RollBreakdown),
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RollKind),
          ) as RollKind;
          result.kind = valueDes;
          break;
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
        case r'breakdown':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RollBreakdown),
          ) as RollBreakdown?;
          if (valueDes == null) continue;
          result.breakdown.replace(valueDes);
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

