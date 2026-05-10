//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/combatant.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'initiative_roll_result.g.dart';

/// Returned by `POST /api/v1/encounters/{id}/initiative/roll` and `PATCH /api/v1/encounters/{id}/initiative`. Carries the full combatant list after initiative values and turn-order indices have been assigned, plus the current round counter.  **Tie-breaking rule (ST3001):** when two combatants share the same d10 initiative roll the server breaks the tie by `agility` descending — the source PC's `attributes.agility` for `pc` combatants, or `npcSnapshot.agility` for `npc` combatants. If `agility` is also equal the GM is expected to use the `PATCH /api/v1/encounters/{id}/initiative` reorder operation to set the final order manually.  **Side-effects of `rollInitiative`:** 1. Encounter status transitions `setup → active`. 2. `encounter.round` is set from 0 to 1. 3. `encounter.activeCombatantId` is set to the combatant at `turnOrder: 0`. The `PATCH` (reorder) variant does NOT re-roll dice and does NOT alter `activeCombatantId` — the GM is adjusting who acts next round, not restarting combat. 
///
/// Properties:
/// * [combatants] - Full updated combatant list sorted by `turnOrder` ascending (0 = acts first). Every combatant carries a non-null `initiative` and `turnOrder` after this operation. 
/// * [round] - Current combat round after the operation. For `rollInitiative` this is always 1 (the `setup → active` transition sets `round` from 0 to 1). For `reorderInitiative` this reflects the encounter's current round (unchanged by a reorder). 
@BuiltValue()
abstract class InitiativeRollResult implements Built<InitiativeRollResult, InitiativeRollResultBuilder> {
  /// Full updated combatant list sorted by `turnOrder` ascending (0 = acts first). Every combatant carries a non-null `initiative` and `turnOrder` after this operation. 
  @BuiltValueField(wireName: r'combatants')
  BuiltList<Combatant> get combatants;

  /// Current combat round after the operation. For `rollInitiative` this is always 1 (the `setup → active` transition sets `round` from 0 to 1). For `reorderInitiative` this reflects the encounter's current round (unchanged by a reorder). 
  @BuiltValueField(wireName: r'round')
  int get round;

  InitiativeRollResult._();

  factory InitiativeRollResult([void updates(InitiativeRollResultBuilder b)]) = _$InitiativeRollResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InitiativeRollResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InitiativeRollResult> get serializer => _$InitiativeRollResultSerializer();
}

class _$InitiativeRollResultSerializer implements PrimitiveSerializer<InitiativeRollResult> {
  @override
  final Iterable<Type> types = const [InitiativeRollResult, _$InitiativeRollResult];

  @override
  final String wireName = r'InitiativeRollResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InitiativeRollResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'combatants';
    yield serializers.serialize(
      object.combatants,
      specifiedType: const FullType(BuiltList, [FullType(Combatant)]),
    );
    yield r'round';
    yield serializers.serialize(
      object.round,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InitiativeRollResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InitiativeRollResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'combatants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Combatant)]),
          ) as BuiltList<Combatant>;
          result.combatants.replace(valueDes);
          break;
        case r'round':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.round = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InitiativeRollResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InitiativeRollResultBuilder();
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

