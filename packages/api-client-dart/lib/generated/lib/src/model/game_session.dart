//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/game_session_membership.dart';
import 'package:app_api_client/src/model/game_session_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'game_session.g.dart';

/// A campaign session container owned by a GM.
///
/// Properties:
/// * [id] - Opaque session identifier (cuid2)
/// * [ownerId] - User identifier of the GM who owns this session
/// * [name] - Short name for the session
/// * [description] - Optional longer description
/// * [status] 
/// * [dpCount] - Darkness Points counter; mutated by Feature 7.3
/// * [shipId] - Optional ship linked to the session (Epic 8)
/// * [memberships] - Active members of this session. Always includes the GM row. Single source of truth for \"who is at this table\" since Phase 8 Stream E removed the legacy `characterIds` array. Each row optionally carries `characterId` — that's how a player (or GM) links a PC to their seat. 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue(instantiable: false)
abstract class GameSession  {
  /// Opaque session identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// User identifier of the GM who owns this session
  @BuiltValueField(wireName: r'ownerId')
  String get ownerId;

  /// Short name for the session
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Optional longer description
  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'status')
  GameSessionStatus get status;
  // enum statusEnum {  active,  archived,  };

  /// Darkness Points counter; mutated by Feature 7.3
  @BuiltValueField(wireName: r'dpCount')
  int get dpCount;

  /// Optional ship linked to the session (Epic 8)
  @BuiltValueField(wireName: r'shipId')
  String? get shipId;

  /// Active members of this session. Always includes the GM row. Single source of truth for \"who is at this table\" since Phase 8 Stream E removed the legacy `characterIds` array. Each row optionally carries `characterId` — that's how a player (or GM) links a PC to their seat. 
  @BuiltValueField(wireName: r'memberships')
  BuiltList<GameSessionMembership> get memberships;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueSerializer(custom: true)
  static Serializer<GameSession> get serializer => _$GameSessionSerializer();
}

class _$GameSessionSerializer implements PrimitiveSerializer<GameSession> {
  @override
  final Iterable<Type> types = const [GameSession];

  @override
  final String wireName = r'GameSession';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GameSession object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(GameSessionStatus),
    );
    yield r'dpCount';
    yield serializers.serialize(
      object.dpCount,
      specifiedType: const FullType(int),
    );
    if (object.shipId != null) {
      yield r'shipId';
      yield serializers.serialize(
        object.shipId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'memberships';
    yield serializers.serialize(
      object.memberships,
      specifiedType: const FullType(BuiltList, [FullType(GameSessionMembership)]),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
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
    GameSession object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  GameSession deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($GameSession)) as $GameSession;
  }
}

/// a concrete implementation of [GameSession], since [GameSession] is not instantiable
@BuiltValue(instantiable: true)
abstract class $GameSession implements GameSession, Built<$GameSession, $GameSessionBuilder> {
  $GameSession._();

  factory $GameSession([void Function($GameSessionBuilder)? updates]) = _$$GameSession;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($GameSessionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$GameSession> get serializer => _$$GameSessionSerializer();
}

class _$$GameSessionSerializer implements PrimitiveSerializer<$GameSession> {
  @override
  final Iterable<Type> types = const [$GameSession, _$$GameSession];

  @override
  final String wireName = r'$GameSession';

  @override
  Object serialize(
    Serializers serializers,
    $GameSession object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(GameSession))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GameSessionBuilder result,
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
        case r'ownerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ownerId = valueDes;
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GameSessionStatus),
          ) as GameSessionStatus;
          result.status = valueDes;
          break;
        case r'dpCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.dpCount = valueDes;
          break;
        case r'shipId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.shipId = valueDes;
          break;
        case r'memberships':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GameSessionMembership)]),
          ) as BuiltList<GameSessionMembership>;
          result.memberships.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
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
  $GameSession deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $GameSessionBuilder();
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

