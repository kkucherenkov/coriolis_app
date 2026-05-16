// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ChatMessageKind _$text = const ChatMessageKind._('text');
const ChatMessageKind _$system = const ChatMessageKind._('system');

ChatMessageKind _$valueOf(String name) {
  switch (name) {
    case 'text':
      return _$text;
    case 'system':
      return _$system;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ChatMessageKind> _$values =
    BuiltSet<ChatMessageKind>(const <ChatMessageKind>[
  _$text,
  _$system,
]);

class _$ChatMessageKindMeta {
  const _$ChatMessageKindMeta();
  ChatMessageKind get text => _$text;
  ChatMessageKind get system => _$system;
  ChatMessageKind valueOf(String name) => _$valueOf(name);
  BuiltSet<ChatMessageKind> get values => _$values;
}

abstract class _$ChatMessageKindMixin {
  // ignore: non_constant_identifier_names
  _$ChatMessageKindMeta get ChatMessageKind => const _$ChatMessageKindMeta();
}

Serializer<ChatMessageKind> _$chatMessageKindSerializer =
    _$ChatMessageKindSerializer();

class _$ChatMessageKindSerializer
    implements PrimitiveSerializer<ChatMessageKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'text': 'text',
    'system': 'system',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'text': 'text',
    'system': 'system',
  };

  @override
  final Iterable<Type> types = const <Type>[ChatMessageKind];
  @override
  final String wireName = 'ChatMessageKind';

  @override
  Object serialize(Serializers serializers, ChatMessageKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ChatMessageKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ChatMessageKind.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
