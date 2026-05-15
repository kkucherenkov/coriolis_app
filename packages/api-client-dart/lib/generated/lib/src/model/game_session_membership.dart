//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/game_session_member_role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'game_session_membership.g.dart';

/// A row in the GameSessionMembership join table. Identifies a user's participation in a GameSession with a role and an optionally-linked character. 
///
/// Properties:
/// * [id] - Stable cuid; used as targetMembershipId in chat whispers.
/// * [gameSessionId] 
/// * [userId] 
/// * [role] 
/// * [displayName] - Cached display name of the user (denormalised for UI).
/// * [characterId] 
/// * [characterName] 
/// * [joinedAt] 
/// * [leftAt] 
@BuiltValue()
abstract class GameSessionMembership implements Built<GameSessionMembership, GameSessionMembershipBuilder> {
  /// Stable cuid; used as targetMembershipId in chat whispers.
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'gameSessionId')
  String get gameSessionId;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'role')
  GameSessionMemberRole get role;
  // enum roleEnum {  gm,  player,  };

  /// Cached display name of the user (denormalised for UI).
  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  @BuiltValueField(wireName: r'characterId')
  String? get characterId;

  @BuiltValueField(wireName: r'characterName')
  String? get characterName;

  @BuiltValueField(wireName: r'joinedAt')
  DateTime get joinedAt;

  @BuiltValueField(wireName: r'leftAt')
  DateTime? get leftAt;

  GameSessionMembership._();

  factory GameSessionMembership([void updates(GameSessionMembershipBuilder b)]) = _$GameSessionMembership;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GameSessionMembershipBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GameSessionMembership> get serializer => _$GameSessionMembershipSerializer();
}

class _$GameSessionMembershipSerializer implements PrimitiveSerializer<GameSessionMembership> {
  @override
  final Iterable<Type> types = const [GameSessionMembership, _$GameSessionMembership];

  @override
  final String wireName = r'GameSessionMembership';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GameSessionMembership object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'gameSessionId';
    yield serializers.serialize(
      object.gameSessionId,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(GameSessionMemberRole),
    );
    if (object.displayName != null) {
      yield r'displayName';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.characterId != null) {
      yield r'characterId';
      yield serializers.serialize(
        object.characterId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.characterName != null) {
      yield r'characterName';
      yield serializers.serialize(
        object.characterName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'joinedAt';
    yield serializers.serialize(
      object.joinedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.leftAt != null) {
      yield r'leftAt';
      yield serializers.serialize(
        object.leftAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GameSessionMembership object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GameSessionMembershipBuilder result,
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
        case r'gameSessionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.gameSessionId = valueDes;
          break;
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GameSessionMemberRole),
          ) as GameSessionMemberRole;
          result.role = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.displayName = valueDes;
          break;
        case r'characterId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.characterId = valueDes;
          break;
        case r'characterName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.characterName = valueDes;
          break;
        case r'joinedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.joinedAt = valueDes;
          break;
        case r'leftAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.leftAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GameSessionMembership deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GameSessionMembershipBuilder();
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

