//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/combatant_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'combatant_create.g.dart';

/// POST payload for `POST /api/v1/encounters/{id}/combatants`.  `combatantType` and `sourceId` are required. The server snapshots `hpCurrent`, `hpMax`, `armor`, and `signature` from the source entity on add; these fields are absent from the request payload and populated in the response. `initiative` and `turnOrder` are server-controlled and remain null until the Block 4 initiative-roll operation.  `displayName` is optional — when omitted the server uses the source entity's `name` field.  422 error codes: - `COMBATANT_SOURCE_NOT_FOUND` — `sourceId` does not exist - `COMBATANT_SOURCE_NOT_OWNED` — caller does not own the source entity - `COMBATANT_DUPLICATE` — same `(combatantType, sourceId)` already present - `ENCOUNTER_LOCKED_FOR_COMBAT` — encounter is not in `setup` status 
///
/// Properties:
/// * [combatantType] 
/// * [sourceId] - Identifier of the source entity. Must be a `Character.id` when `combatantType` is `pc`, or an `Npc.id` when `combatantType` is `npc`. 
/// * [displayName] - Optional override for the combatant display name. When omitted the server copies the source entity's `name`. 
/// * [notes] - Optional GM notes in Markdown (max 500 characters).
@BuiltValue()
abstract class CombatantCreate implements Built<CombatantCreate, CombatantCreateBuilder> {
  @BuiltValueField(wireName: r'combatantType')
  CombatantType get combatantType;
  // enum combatantTypeEnum {  pc,  npc,  };

  /// Identifier of the source entity. Must be a `Character.id` when `combatantType` is `pc`, or an `Npc.id` when `combatantType` is `npc`. 
  @BuiltValueField(wireName: r'sourceId')
  String get sourceId;

  /// Optional override for the combatant display name. When omitted the server copies the source entity's `name`. 
  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  /// Optional GM notes in Markdown (max 500 characters).
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  CombatantCreate._();

  factory CombatantCreate([void updates(CombatantCreateBuilder b)]) = _$CombatantCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CombatantCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CombatantCreate> get serializer => _$CombatantCreateSerializer();
}

class _$CombatantCreateSerializer implements PrimitiveSerializer<CombatantCreate> {
  @override
  final Iterable<Type> types = const [CombatantCreate, _$CombatantCreate];

  @override
  final String wireName = r'CombatantCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CombatantCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'combatantType';
    yield serializers.serialize(
      object.combatantType,
      specifiedType: const FullType(CombatantType),
    );
    yield r'sourceId';
    yield serializers.serialize(
      object.sourceId,
      specifiedType: const FullType(String),
    );
    if (object.displayName != null) {
      yield r'displayName';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType(String),
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
    CombatantCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CombatantCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'combatantType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CombatantType),
          ) as CombatantType;
          result.combatantType = valueDes;
          break;
        case r'sourceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceId = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
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
  CombatantCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CombatantCreateBuilder();
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

