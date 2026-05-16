//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/chat_conversation_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_conversation_list.g.dart';

/// ChatConversationList
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class ChatConversationList implements Built<ChatConversationList, ChatConversationListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ChatConversationSummary> get items;

  ChatConversationList._();

  factory ChatConversationList([void updates(ChatConversationListBuilder b)]) = _$ChatConversationList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatConversationListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatConversationList> get serializer => _$ChatConversationListSerializer();
}

class _$ChatConversationListSerializer implements PrimitiveSerializer<ChatConversationList> {
  @override
  final Iterable<Type> types = const [ChatConversationList, _$ChatConversationList];

  @override
  final String wireName = r'ChatConversationList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatConversationList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ChatConversationSummary)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatConversationList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatConversationListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ChatConversationSummary)]),
          ) as BuiltList<ChatConversationSummary>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatConversationList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatConversationListBuilder();
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

