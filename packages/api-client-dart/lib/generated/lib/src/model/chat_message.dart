//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/chat_message_kind.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_message.g.dart';

/// ChatMessage
///
/// Properties:
/// * [id] 
/// * [gameSessionId] 
/// * [authorMembershipId] - GameSessionMembership.id; null for system messages
/// * [authorDisplayName] - Denormalised at read time
/// * [targetMembershipId] - null = broadcast; non-null = whisper
/// * [kind] 
/// * [body] - null for kind=system; non-empty trimmed text for kind=text
/// * [systemKey] - i18n key for kind=system, e.g. chat.system.member_joined
/// * [systemParams] 
/// * [createdAt] 
/// * [editedAt] 
/// * [deletedAt] 
@BuiltValue()
abstract class ChatMessage implements Built<ChatMessage, ChatMessageBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'gameSessionId')
  String get gameSessionId;

  /// GameSessionMembership.id; null for system messages
  @BuiltValueField(wireName: r'authorMembershipId')
  String? get authorMembershipId;

  /// Denormalised at read time
  @BuiltValueField(wireName: r'authorDisplayName')
  String? get authorDisplayName;

  /// null = broadcast; non-null = whisper
  @BuiltValueField(wireName: r'targetMembershipId')
  String? get targetMembershipId;

  @BuiltValueField(wireName: r'kind')
  ChatMessageKind get kind;
  // enum kindEnum {  text,  system,  };

  /// null for kind=system; non-empty trimmed text for kind=text
  @BuiltValueField(wireName: r'body')
  String? get body;

  /// i18n key for kind=system, e.g. chat.system.member_joined
  @BuiltValueField(wireName: r'systemKey')
  String? get systemKey;

  @BuiltValueField(wireName: r'systemParams')
  BuiltMap<String, JsonObject?>? get systemParams;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'editedAt')
  DateTime? get editedAt;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  ChatMessage._();

  factory ChatMessage([void updates(ChatMessageBuilder b)]) = _$ChatMessage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatMessageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatMessage> get serializer => _$ChatMessageSerializer();
}

class _$ChatMessageSerializer implements PrimitiveSerializer<ChatMessage> {
  @override
  final Iterable<Type> types = const [ChatMessage, _$ChatMessage];

  @override
  final String wireName = r'ChatMessage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatMessage object, {
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
    yield r'authorMembershipId';
    yield object.authorMembershipId == null ? null : serializers.serialize(
      object.authorMembershipId,
      specifiedType: const FullType.nullable(String),
    );
    if (object.authorDisplayName != null) {
      yield r'authorDisplayName';
      yield serializers.serialize(
        object.authorDisplayName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'targetMembershipId';
    yield object.targetMembershipId == null ? null : serializers.serialize(
      object.targetMembershipId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ChatMessageKind),
    );
    if (object.body != null) {
      yield r'body';
      yield serializers.serialize(
        object.body,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.systemKey != null) {
      yield r'systemKey';
      yield serializers.serialize(
        object.systemKey,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.systemParams != null) {
      yield r'systemParams';
      yield serializers.serialize(
        object.systemParams,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.editedAt != null) {
      yield r'editedAt';
      yield serializers.serialize(
        object.editedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.deletedAt != null) {
      yield r'deletedAt';
      yield serializers.serialize(
        object.deletedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatMessage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatMessageBuilder result,
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
        case r'authorMembershipId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.authorMembershipId = valueDes;
          break;
        case r'authorDisplayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.authorDisplayName = valueDes;
          break;
        case r'targetMembershipId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetMembershipId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ChatMessageKind),
          ) as ChatMessageKind;
          result.kind = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.body = valueDes;
          break;
        case r'systemKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.systemKey = valueDes;
          break;
        case r'systemParams':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.systemParams.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'editedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.editedAt = valueDes;
          break;
        case r'deletedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatMessage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatMessageBuilder();
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

