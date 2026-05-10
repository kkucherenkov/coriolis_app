//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'initiative_reorder_request.g.dart';

/// Request body for `PATCH /api/v1/encounters/{id}/initiative`. The GM supplies the full desired turn order as an ordered array of combatant ids. The server reassigns `turnOrder` indices (0-based) matching the array position.  **Validation — the array must contain every combatant id from the encounter exactly once.** Any violation returns 422 with one of: - `INITIATIVE_INCOMPLETE` — at least one combatant id from the encounter   is absent from the array. - `INITIATIVE_DUPLICATE` — the same id appears two or more times. - `INITIATIVE_UNKNOWN_COMBATANT` — an id in the array does not belong to   this encounter.  The `PATCH` does NOT re-roll initiative dice and does NOT change `activeCombatantId` — it only rearranges the turn-order index so the GM can correct ties or unexpected results without restarting combat. 
///
/// Properties:
/// * [combatantIds] - Ordered list of combatant ids. Position 0 acts first. Must include every combatant in the encounter exactly once. 
@BuiltValue()
abstract class InitiativeReorderRequest implements Built<InitiativeReorderRequest, InitiativeReorderRequestBuilder> {
  /// Ordered list of combatant ids. Position 0 acts first. Must include every combatant in the encounter exactly once. 
  @BuiltValueField(wireName: r'combatantIds')
  BuiltList<String> get combatantIds;

  InitiativeReorderRequest._();

  factory InitiativeReorderRequest([void updates(InitiativeReorderRequestBuilder b)]) = _$InitiativeReorderRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InitiativeReorderRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InitiativeReorderRequest> get serializer => _$InitiativeReorderRequestSerializer();
}

class _$InitiativeReorderRequestSerializer implements PrimitiveSerializer<InitiativeReorderRequest> {
  @override
  final Iterable<Type> types = const [InitiativeReorderRequest, _$InitiativeReorderRequest];

  @override
  final String wireName = r'InitiativeReorderRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InitiativeReorderRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'combatantIds';
    yield serializers.serialize(
      object.combatantIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InitiativeReorderRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InitiativeReorderRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'combatantIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.combatantIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InitiativeReorderRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InitiativeReorderRequestBuilder();
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

