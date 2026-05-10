//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'turn_advance_result.g.dart';

/// Returned by `POST /api/v1/encounters/{id}/turn/advance`. Identifies the combatant whose turn is now active after the advance, the current round counter, and whether advancing wrapped past the last combatant (which triggers a round increment).  **Wrap behaviour:** the server advances `activeCombatantId` from the current `turnOrder` index to `(currentIndex + 1) % combatants.length`. When `currentIndex + 1` equals `combatants.length` the turn wraps to index 0 and `round` is incremented by 1; `isNewRound` is `true` in that case. 
///
/// Properties:
/// * [activeCombatantId] - Id of the combatant whose turn is now active (the new `encounter.activeCombatantId` after the advance). 
/// * [round] - Current combat round after the advance. Incremented by 1 when the turn wraps from the last combatant back to index 0. 
/// * [isNewRound] - `true` when the advance wrapped past the last combatant and started a new round; `false` when the next combatant is within the same round. 
@BuiltValue()
abstract class TurnAdvanceResult implements Built<TurnAdvanceResult, TurnAdvanceResultBuilder> {
  /// Id of the combatant whose turn is now active (the new `encounter.activeCombatantId` after the advance). 
  @BuiltValueField(wireName: r'activeCombatantId')
  String get activeCombatantId;

  /// Current combat round after the advance. Incremented by 1 when the turn wraps from the last combatant back to index 0. 
  @BuiltValueField(wireName: r'round')
  int get round;

  /// `true` when the advance wrapped past the last combatant and started a new round; `false` when the next combatant is within the same round. 
  @BuiltValueField(wireName: r'isNewRound')
  bool get isNewRound;

  TurnAdvanceResult._();

  factory TurnAdvanceResult([void updates(TurnAdvanceResultBuilder b)]) = _$TurnAdvanceResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TurnAdvanceResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TurnAdvanceResult> get serializer => _$TurnAdvanceResultSerializer();
}

class _$TurnAdvanceResultSerializer implements PrimitiveSerializer<TurnAdvanceResult> {
  @override
  final Iterable<Type> types = const [TurnAdvanceResult, _$TurnAdvanceResult];

  @override
  final String wireName = r'TurnAdvanceResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TurnAdvanceResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'activeCombatantId';
    yield serializers.serialize(
      object.activeCombatantId,
      specifiedType: const FullType(String),
    );
    yield r'round';
    yield serializers.serialize(
      object.round,
      specifiedType: const FullType(int),
    );
    yield r'isNewRound';
    yield serializers.serialize(
      object.isNewRound,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TurnAdvanceResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TurnAdvanceResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'activeCombatantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.activeCombatantId = valueDes;
          break;
        case r'round':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.round = valueDes;
          break;
        case r'isNewRound':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isNewRound = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TurnAdvanceResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TurnAdvanceResultBuilder();
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

