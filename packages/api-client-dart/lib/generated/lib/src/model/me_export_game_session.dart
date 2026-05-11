//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/game_session.dart';
import 'package:app_api_client/src/model/me_export_encounter.dart';
import 'package:app_api_client/src/model/game_session_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_export_game_session.g.dart';

/// Export-only wrapper. Composes `GameSession` via `allOf` and adds the `encounters` array (the encounter list uses the encounter wrapper so per-encounter combatants are inlined).  NPCs are deliberately NOT nested here: in this codebase NPCs are user-owned (not session-owned), so they appear once at the bundle top level rather than duplicated per session. 
///
/// Properties:
/// * [id] - Opaque session identifier (cuid2)
/// * [ownerId] - User identifier of the GM who owns this session
/// * [name] - Short name for the session
/// * [description] - Optional longer description
/// * [status] 
/// * [dpCount] - Darkness Points counter; mutated by Feature 7.3
/// * [characterIds] - Character ids assigned to this session. Manage via the join endpoint (POST / DELETE on /game-sessions/{id}/characters). 
/// * [shipId] - Optional ship linked to the session (Epic 8)
/// * [createdAt] 
/// * [updatedAt] 
/// * [encounters] 
@BuiltValue()
abstract class MeExportGameSession implements GameSession, Built<MeExportGameSession, MeExportGameSessionBuilder> {
  @BuiltValueField(wireName: r'encounters')
  BuiltList<MeExportEncounter> get encounters;

  MeExportGameSession._();

  factory MeExportGameSession([void updates(MeExportGameSessionBuilder b)]) = _$MeExportGameSession;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeExportGameSessionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeExportGameSession> get serializer => _$MeExportGameSessionSerializer();
}

class _$MeExportGameSessionSerializer implements PrimitiveSerializer<MeExportGameSession> {
  @override
  final Iterable<Type> types = const [MeExportGameSession, _$MeExportGameSession];

  @override
  final String wireName = r'MeExportGameSession';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeExportGameSession object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'dpCount';
    yield serializers.serialize(
      object.dpCount,
      specifiedType: const FullType(int),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'encounters';
    yield serializers.serialize(
      object.encounters,
      specifiedType: const FullType(BuiltList, [FullType(MeExportEncounter)]),
    );
    yield r'characterIds';
    yield serializers.serialize(
      object.characterIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'ownerId';
    yield serializers.serialize(
      object.ownerId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(GameSessionStatus),
    );
    if (object.shipId != null) {
      yield r'shipId';
      yield serializers.serialize(
        object.shipId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeExportGameSession object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeExportGameSessionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dpCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.dpCount = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'encounters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MeExportEncounter)]),
          ) as BuiltList<MeExportEncounter>;
          result.encounters.replace(valueDes);
          break;
        case r'characterIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.characterIds.replace(valueDes);
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'ownerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ownerId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GameSessionStatus),
          ) as GameSessionStatus;
          result.status = valueDes;
          break;
        case r'shipId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.shipId = valueDes;
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
  MeExportGameSession deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeExportGameSessionBuilder();
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

