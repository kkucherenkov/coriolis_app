//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/chat_message.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_message_list.g.dart';

/// ChatMessageList
///
/// Properties:
/// * [items] 
/// * [nextCursor] - Opaque base64url cursor; null = end of results
@BuiltValue()
abstract class ChatMessageList implements Built<ChatMessageList, ChatMessageListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ChatMessage> get items;

  /// Opaque base64url cursor; null = end of results
  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  ChatMessageList._();

  factory ChatMessageList([void updates(ChatMessageListBuilder b)]) = _$ChatMessageList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatMessageListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatMessageList> get serializer => _$ChatMessageListSerializer();
}

class _$ChatMessageListSerializer implements PrimitiveSerializer<ChatMessageList> {
  @override
  final Iterable<Type> types = const [ChatMessageList, _$ChatMessageList];

  @override
  final String wireName = r'ChatMessageList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatMessageList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ChatMessage)]),
    );
    yield r'nextCursor';
    yield object.nextCursor == null ? null : serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatMessageList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatMessageListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ChatMessage)]),
          ) as BuiltList<ChatMessage>;
          result.items.replace(valueDes);
          break;
        case r'nextCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatMessageList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatMessageListBuilder();
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

