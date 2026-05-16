// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessageList extends ChatMessageList {
  @override
  final BuiltList<ChatMessage> items;
  @override
  final String? nextCursor;

  factory _$ChatMessageList([void Function(ChatMessageListBuilder)? updates]) =>
      (ChatMessageListBuilder()..update(updates))._build();

  _$ChatMessageList._({required this.items, this.nextCursor}) : super._();
  @override
  ChatMessageList rebuild(void Function(ChatMessageListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessageListBuilder toBuilder() => ChatMessageListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessageList &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMessageList')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class ChatMessageListBuilder
    implements Builder<ChatMessageList, ChatMessageListBuilder> {
  _$ChatMessageList? _$v;

  ListBuilder<ChatMessage>? _items;
  ListBuilder<ChatMessage> get items =>
      _$this._items ??= ListBuilder<ChatMessage>();
  set items(ListBuilder<ChatMessage>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  ChatMessageListBuilder() {
    ChatMessageList._defaults(this);
  }

  ChatMessageListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessageList other) {
    _$v = other as _$ChatMessageList;
  }

  @override
  void update(void Function(ChatMessageListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessageList build() => _build();

  _$ChatMessageList _build() {
    _$ChatMessageList _$result;
    try {
      _$result = _$v ??
          _$ChatMessageList._(
            items: items.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ChatMessageList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
