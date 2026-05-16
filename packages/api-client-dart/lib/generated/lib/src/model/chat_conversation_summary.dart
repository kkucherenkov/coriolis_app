//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_conversation_summary.g.dart';

/// ChatConversationSummary
///
/// Properties:
/// * [conversationKey] - 'broadcast' or a membershipId
/// * [kind] 
/// * [partnerMembershipId] 
/// * [partnerDisplayName] 
/// * [partnerCharacterName] 
/// * [lastMessageAt] 
/// * [unreadCount] 
@BuiltValue()
abstract class ChatConversationSummary implements Built<ChatConversationSummary, ChatConversationSummaryBuilder> {
  /// 'broadcast' or a membershipId
  @BuiltValueField(wireName: r'conversationKey')
  String get conversationKey;

  @BuiltValueField(wireName: r'kind')
  ChatConversationSummaryKindEnum get kind;
  // enum kindEnum {  broadcast,  whisper,  };

  @BuiltValueField(wireName: r'partnerMembershipId')
  String? get partnerMembershipId;

  @BuiltValueField(wireName: r'partnerDisplayName')
  String? get partnerDisplayName;

  @BuiltValueField(wireName: r'partnerCharacterName')
  String? get partnerCharacterName;

  @BuiltValueField(wireName: r'lastMessageAt')
  DateTime? get lastMessageAt;

  @BuiltValueField(wireName: r'unreadCount')
  int get unreadCount;

  ChatConversationSummary._();

  factory ChatConversationSummary([void updates(ChatConversationSummaryBuilder b)]) = _$ChatConversationSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatConversationSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatConversationSummary> get serializer => _$ChatConversationSummarySerializer();
}

class _$ChatConversationSummarySerializer implements PrimitiveSerializer<ChatConversationSummary> {
  @override
  final Iterable<Type> types = const [ChatConversationSummary, _$ChatConversationSummary];

  @override
  final String wireName = r'ChatConversationSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatConversationSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'conversationKey';
    yield serializers.serialize(
      object.conversationKey,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ChatConversationSummaryKindEnum),
    );
    if (object.partnerMembershipId != null) {
      yield r'partnerMembershipId';
      yield serializers.serialize(
        object.partnerMembershipId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.partnerDisplayName != null) {
      yield r'partnerDisplayName';
      yield serializers.serialize(
        object.partnerDisplayName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.partnerCharacterName != null) {
      yield r'partnerCharacterName';
      yield serializers.serialize(
        object.partnerCharacterName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'lastMessageAt';
    yield object.lastMessageAt == null ? null : serializers.serialize(
      object.lastMessageAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'unreadCount';
    yield serializers.serialize(
      object.unreadCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatConversationSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatConversationSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'conversationKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.conversationKey = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ChatConversationSummaryKindEnum),
          ) as ChatConversationSummaryKindEnum;
          result.kind = valueDes;
          break;
        case r'partnerMembershipId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.partnerMembershipId = valueDes;
          break;
        case r'partnerDisplayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.partnerDisplayName = valueDes;
          break;
        case r'partnerCharacterName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.partnerCharacterName = valueDes;
          break;
        case r'lastMessageAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastMessageAt = valueDes;
          break;
        case r'unreadCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unreadCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatConversationSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatConversationSummaryBuilder();
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

class ChatConversationSummaryKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'broadcast')
  static const ChatConversationSummaryKindEnum broadcast = _$chatConversationSummaryKindEnum_broadcast;
  @BuiltValueEnumConst(wireName: r'whisper')
  static const ChatConversationSummaryKindEnum whisper = _$chatConversationSummaryKindEnum_whisper;

  static Serializer<ChatConversationSummaryKindEnum> get serializer => _$chatConversationSummaryKindEnumSerializer;

  const ChatConversationSummaryKindEnum._(String name): super(name);

  static BuiltSet<ChatConversationSummaryKindEnum> get values => _$chatConversationSummaryKindEnumValues;
  static ChatConversationSummaryKindEnum valueOf(String name) => _$chatConversationSummaryKindEnumValueOf(name);
}

