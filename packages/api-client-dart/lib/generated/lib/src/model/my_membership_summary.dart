//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/game_session_member_role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'my_membership_summary.g.dart';

/// MyMembershipSummary
///
/// Properties:
/// * [membershipId] 
/// * [gameSessionId] 
/// * [sessionName] 
/// * [role] 
/// * [characterId] 
/// * [characterName] 
/// * [joinedAt] 
@BuiltValue()
abstract class MyMembershipSummary implements Built<MyMembershipSummary, MyMembershipSummaryBuilder> {
  @BuiltValueField(wireName: r'membershipId')
  String get membershipId;

  @BuiltValueField(wireName: r'gameSessionId')
  String get gameSessionId;

  @BuiltValueField(wireName: r'sessionName')
  String get sessionName;

  @BuiltValueField(wireName: r'role')
  GameSessionMemberRole get role;
  // enum roleEnum {  gm,  player,  };

  @BuiltValueField(wireName: r'characterId')
  String? get characterId;

  @BuiltValueField(wireName: r'characterName')
  String? get characterName;

  @BuiltValueField(wireName: r'joinedAt')
  DateTime get joinedAt;

  MyMembershipSummary._();

  factory MyMembershipSummary([void updates(MyMembershipSummaryBuilder b)]) = _$MyMembershipSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MyMembershipSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MyMembershipSummary> get serializer => _$MyMembershipSummarySerializer();
}

class _$MyMembershipSummarySerializer implements PrimitiveSerializer<MyMembershipSummary> {
  @override
  final Iterable<Type> types = const [MyMembershipSummary, _$MyMembershipSummary];

  @override
  final String wireName = r'MyMembershipSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MyMembershipSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'membershipId';
    yield serializers.serialize(
      object.membershipId,
      specifiedType: const FullType(String),
    );
    yield r'gameSessionId';
    yield serializers.serialize(
      object.gameSessionId,
      specifiedType: const FullType(String),
    );
    yield r'sessionName';
    yield serializers.serialize(
      object.sessionName,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(GameSessionMemberRole),
    );
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
  }

  @override
  Object serialize(
    Serializers serializers,
    MyMembershipSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MyMembershipSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'membershipId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.membershipId = valueDes;
          break;
        case r'gameSessionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.gameSessionId = valueDes;
          break;
        case r'sessionName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionName = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GameSessionMemberRole),
          ) as GameSessionMemberRole;
          result.role = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MyMembershipSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MyMembershipSummaryBuilder();
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

