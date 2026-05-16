//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'edit_chat_message_request.g.dart';

/// EditChatMessageRequest
///
/// Properties:
/// * [body] 
@BuiltValue()
abstract class EditChatMessageRequest implements Built<EditChatMessageRequest, EditChatMessageRequestBuilder> {
  @BuiltValueField(wireName: r'body')
  String get body;

  EditChatMessageRequest._();

  factory EditChatMessageRequest([void updates(EditChatMessageRequestBuilder b)]) = _$EditChatMessageRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditChatMessageRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EditChatMessageRequest> get serializer => _$EditChatMessageRequestSerializer();
}

class _$EditChatMessageRequestSerializer implements PrimitiveSerializer<EditChatMessageRequest> {
  @override
  final Iterable<Type> types = const [EditChatMessageRequest, _$EditChatMessageRequest];

  @override
  final String wireName = r'EditChatMessageRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditChatMessageRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EditChatMessageRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EditChatMessageRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EditChatMessageRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditChatMessageRequestBuilder();
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

