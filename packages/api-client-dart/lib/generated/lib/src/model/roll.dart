//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/roll_kind.dart';
import 'package:app_api_client/src/model/roll_breakdown.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'roll.g.dart';

/// A single Coriolis dice roll. Dice are rolled server-side using a cryptographically secure RNG. Hits = count of 6s. A roll can be pushed at most once (PRD §10). `gameSessionId` is null until Feature 7.2 lands. 
///
/// Properties:
/// * [id] - Opaque roll identifier (cuid2)
/// * [characterId] - Identifier of the character who made the roll
/// * [gameSessionId] - Game session this roll belongs to. Null until Feature 7.2 (GameSession resource) ships. Clients should tolerate null. 
/// * [kind] - What kind of roll this represents (see RollKind for the full taxonomy). Set at create-time and immutable. Drives the push-eligibility gate — only `skill` rolls accept POST `/rolls/{id}/push`.  The server always emits `kind`; clients SHOULD treat absence as `skill` for backward compatibility with ≤ 1.2 servers. 
/// * [label] - Human-readable roll label, e.g. \"Pilot · Evade\"
/// * [pool] - Number of d6 rolled (after condition penalties applied by caller). `0` triggers the «Ноль кубиков» rule (ГЛАВА 3 line 161): the engine still rolls 2d6, but the proverka counts as a success only when both dice come up 6. PRD override — Coriolis ST3001 does not name a hard upper bound. We cap at 20 to keep DB rows and wire payloads bounded; realistic attribute + skill + gear + helpers stacks max out around 12–14. 
/// * [dice] - Current face values of all dice. After a push, rerolled non-6 values are updated in place. Length normally equals `pool`; for the zero- dice case (`pool === 0`) the array always has 2 elements regardless. 
/// * [hits] - Number of 6s in the current dice array
/// * [pushed] - Whether this roll has been pushed. Once true, further pushes are rejected.
/// * [breakdown] 
/// * [createdAt] 
@BuiltValue()
abstract class Roll implements Built<Roll, RollBuilder> {
  /// Opaque roll identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Identifier of the character who made the roll
  @BuiltValueField(wireName: r'characterId')
  String get characterId;

  /// Game session this roll belongs to. Null until Feature 7.2 (GameSession resource) ships. Clients should tolerate null. 
  @BuiltValueField(wireName: r'gameSessionId')
  String? get gameSessionId;

  /// What kind of roll this represents (see RollKind for the full taxonomy). Set at create-time and immutable. Drives the push-eligibility gate — only `skill` rolls accept POST `/rolls/{id}/push`.  The server always emits `kind`; clients SHOULD treat absence as `skill` for backward compatibility with ≤ 1.2 servers. 
  @BuiltValueField(wireName: r'kind')
  RollKind get kind;
  // enum kindEnum {  skill,  save,  trauma,  initiative,  darkness,  };

  /// Human-readable roll label, e.g. \"Pilot · Evade\"
  @BuiltValueField(wireName: r'label')
  String get label;

  /// Number of d6 rolled (after condition penalties applied by caller). `0` triggers the «Ноль кубиков» rule (ГЛАВА 3 line 161): the engine still rolls 2d6, but the proverka counts as a success only when both dice come up 6. PRD override — Coriolis ST3001 does not name a hard upper bound. We cap at 20 to keep DB rows and wire payloads bounded; realistic attribute + skill + gear + helpers stacks max out around 12–14. 
  @BuiltValueField(wireName: r'pool')
  int get pool;

  /// Current face values of all dice. After a push, rerolled non-6 values are updated in place. Length normally equals `pool`; for the zero- dice case (`pool === 0`) the array always has 2 elements regardless. 
  @BuiltValueField(wireName: r'dice')
  BuiltList<int> get dice;

  /// Number of 6s in the current dice array
  @BuiltValueField(wireName: r'hits')
  int get hits;

  /// Whether this roll has been pushed. Once true, further pushes are rejected.
  @BuiltValueField(wireName: r'pushed')
  bool get pushed;

  @BuiltValueField(wireName: r'breakdown')
  RollBreakdown? get breakdown;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  Roll._();

  factory Roll([void updates(RollBuilder b)]) = _$Roll;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RollBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Roll> get serializer => _$RollSerializer();
}

class _$RollSerializer implements PrimitiveSerializer<Roll> {
  @override
  final Iterable<Type> types = const [Roll, _$Roll];

  @override
  final String wireName = r'Roll';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Roll object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'characterId';
    yield serializers.serialize(
      object.characterId,
      specifiedType: const FullType(String),
    );
    if (object.gameSessionId != null) {
      yield r'gameSessionId';
      yield serializers.serialize(
        object.gameSessionId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(RollKind),
    );
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
    yield r'dice';
    yield serializers.serialize(
      object.dice,
      specifiedType: const FullType(BuiltList, [FullType(int)]),
    );
    yield r'hits';
    yield serializers.serialize(
      object.hits,
      specifiedType: const FullType(int),
    );
    yield r'pushed';
    yield serializers.serialize(
      object.pushed,
      specifiedType: const FullType(bool),
    );
    if (object.breakdown != null) {
      yield r'breakdown';
      yield serializers.serialize(
        object.breakdown,
        specifiedType: const FullType.nullable(RollBreakdown),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Roll object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RollBuilder result,
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
        case r'characterId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.characterId = valueDes;
          break;
        case r'gameSessionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.gameSessionId = valueDes;
          break;
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
        case r'dice':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(int)]),
          ) as BuiltList<int>;
          result.dice.replace(valueDes);
          break;
        case r'hits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.hits = valueDes;
          break;
        case r'pushed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pushed = valueDes;
          break;
        case r'breakdown':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RollBreakdown),
          ) as RollBreakdown?;
          if (valueDes == null) continue;
          result.breakdown.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Roll deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RollBuilder();
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

