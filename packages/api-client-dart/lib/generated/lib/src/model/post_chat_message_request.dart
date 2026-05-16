//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_chat_message_request.g.dart';

/// PostChatMessageRequest
///
/// Properties:
/// * [kind] - Client-submitted messages must be of kind=text; system messages are server-generated only.
/// * [body] 
/// * [targetMembershipId] - null or omitted = broadcast; non-null = whisper to this membership
@BuiltValue()
abstract class PostChatMessageRequest implements Built<PostChatMessageRequest, PostChatMessageRequestBuilder> {
  /// Client-submitted messages must be of kind=text; system messages are server-generated only.
  @BuiltValueField(wireName: r'kind')
  PostChatMessageRequestKindEnum get kind;
  // enum kindEnum {  text,  };

  @BuiltValueField(wireName: r'body')
  String get body;

  /// null or omitted = broadcast; non-null = whisper to this membership
  @BuiltValueField(wireName: r'targetMembershipId')
  String? get targetMembershipId;

  PostChatMessageRequest._();

  factory PostChatMessageRequest([void updates(PostChatMessageRequestBuilder b)]) = _$PostChatMessageRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostChatMessageRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostChatMessageRequest> get serializer => _$PostChatMessageRequestSerializer();
}

class _$PostChatMessageRequestSerializer implements PrimitiveSerializer<PostChatMessageRequest> {
  @override
  final Iterable<Type> types = const [PostChatMessageRequest, _$PostChatMessageRequest];

  @override
  final String wireName = r'PostChatMessageRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostChatMessageRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(PostChatMessageRequestKindEnum),
    );
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    if (object.targetMembershipId != null) {
      yield r'targetMembershipId';
      yield serializers.serialize(
        object.targetMembershipId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostChatMessageRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostChatMessageRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostChatMessageRequestKindEnum),
          ) as PostChatMessageRequestKindEnum;
          result.kind = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'targetMembershipId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetMembershipId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostChatMessageRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostChatMessageRequestBuilder();
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

class PostChatMessageRequestKindEnum extends EnumClass {

  /// Client-submitted messages must be of kind=text; system messages are server-generated only.
  @BuiltValueEnumConst(wireName: r'text')
  static const PostChatMessageRequestKindEnum text = _$postChatMessageRequestKindEnum_text;

  static Serializer<PostChatMessageRequestKindEnum> get serializer => _$postChatMessageRequestKindEnumSerializer;

  const PostChatMessageRequestKindEnum._(String name): super(name);

  static BuiltSet<PostChatMessageRequestKindEnum> get values => _$postChatMessageRequestKindEnumValues;
  static PostChatMessageRequestKindEnum valueOf(String name) => _$postChatMessageRequestKindEnumValueOf(name);
}

