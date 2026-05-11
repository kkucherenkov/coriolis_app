//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/encounter.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/combatant.dart';
import 'package:app_api_client/src/model/encounter_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_export_encounter.g.dart';

/// Export-only wrapper. Composes `Encounter` via `allOf` and adds the `combatants` array that the base schema deliberately omits (combatants live on a separate sub-resource in normal API usage). 
///
/// Properties:
/// * [id] - Opaque encounter identifier (cuid2)
/// * [gameSessionId] - Identifier of the parent game session (cuid2)
/// * [name] - Short descriptive name for the encounter (1–80 characters)
/// * [status] 
/// * [round] - Current combat round. Starts at 0 while in `setup`. Bumped to 1 when the encounter transitions to `active`. Increments by 1 each time the turn order wraps back to the first combatant (Block 4 turn-advance operation). 
/// * [activeCombatantId] - Identifier of the combatant whose turn it currently is. Null when `status` is `setup` (initiative not yet rolled) or `ended` (combat closed). Set by the server on the `setup → active` transition and updated by the turn-advance operation (Block 4). 
/// * [notes] - Optional GM notes for the encounter in Markdown format (max 4096 characters). May be edited at any status. 
/// * [createdAt] 
/// * [updatedAt] 
/// * [combatants] 
@BuiltValue()
abstract class MeExportEncounter implements Encounter, Built<MeExportEncounter, MeExportEncounterBuilder> {
  @BuiltValueField(wireName: r'combatants')
  BuiltList<Combatant> get combatants;

  MeExportEncounter._();

  factory MeExportEncounter([void updates(MeExportEncounterBuilder b)]) = _$MeExportEncounter;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeExportEncounterBuilder b) => b
      ..round = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeExportEncounter> get serializer => _$MeExportEncounterSerializer();
}

class _$MeExportEncounterSerializer implements PrimitiveSerializer<MeExportEncounter> {
  @override
  final Iterable<Type> types = const [MeExportEncounter, _$MeExportEncounter];

  @override
  final String wireName = r'MeExportEncounter';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeExportEncounter object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'gameSessionId';
    yield serializers.serialize(
      object.gameSessionId,
      specifiedType: const FullType(String),
    );
    yield r'notes';
    yield object.notes == null ? null : serializers.serialize(
      object.notes,
      specifiedType: const FullType.nullable(String),
    );
    yield r'round';
    yield serializers.serialize(
      object.round,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'combatants';
    yield serializers.serialize(
      object.combatants,
      specifiedType: const FullType(BuiltList, [FullType(Combatant)]),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EncounterStatus),
    );
    yield r'activeCombatantId';
    yield object.activeCombatantId == null ? null : serializers.serialize(
      object.activeCombatantId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeExportEncounter object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeExportEncounterBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'gameSessionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.gameSessionId = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'round':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.round = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'combatants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Combatant)]),
          ) as BuiltList<Combatant>;
          result.combatants.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EncounterStatus),
          ) as EncounterStatus;
          result.status = valueDes;
          break;
        case r'activeCombatantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.activeCombatantId = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeExportEncounter deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeExportEncounterBuilder();
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

