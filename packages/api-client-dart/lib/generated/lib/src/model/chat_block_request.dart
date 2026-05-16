//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_block_request.g.dart';

/// ChatBlockRequest
///
/// Properties:
/// * [targetMembershipId] 
@BuiltValue()
abstract class ChatBlockRequest implements Built<ChatBlockRequest, ChatBlockRequestBuilder> {
  @BuiltValueField(wireName: r'targetMembershipId')
  String get targetMembershipId;

  ChatBlockRequest._();

  factory ChatBlockRequest([void updates(ChatBlockRequestBuilder b)]) = _$ChatBlockRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatBlockRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatBlockRequest> get serializer => _$ChatBlockRequestSerializer();
}

class _$ChatBlockRequestSerializer implements PrimitiveSerializer<ChatBlockRequest> {
  @override
  final Iterable<Type> types = const [ChatBlockRequest, _$ChatBlockRequest];

  @override
  final String wireName = r'ChatBlockRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatBlockRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'targetMembershipId';
    yield serializers.serialize(
      object.targetMembershipId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatBlockRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatBlockRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'targetMembershipId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  ChatBlockRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatBlockRequestBuilder();
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

