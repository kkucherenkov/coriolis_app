// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatConversationList extends ChatConversationList {
  @override
  final BuiltList<ChatConversationSummary> items;

  factory _$ChatConversationList(
          [void Function(ChatConversationListBuilder)? updates]) =>
      (ChatConversationListBuilder()..update(updates))._build();

  _$ChatConversationList._({required this.items}) : super._();
  @override
  ChatConversationList rebuild(
          void Function(ChatConversationListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatConversationListBuilder toBuilder() =>
      ChatConversationListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatConversationList && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatConversationList')
          ..add('items', items))
        .toString();
  }
}

class ChatConversationListBuilder
    implements Builder<ChatConversationList, ChatConversationListBuilder> {
  _$ChatConversationList? _$v;

  ListBuilder<ChatConversationSummary>? _items;
  ListBuilder<ChatConversationSummary> get items =>
      _$this._items ??= ListBuilder<ChatConversationSummary>();
  set items(ListBuilder<ChatConversationSummary>? items) =>
      _$this._items = items;

  ChatConversationListBuilder() {
    ChatConversationList._defaults(this);
  }

  ChatConversationListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatConversationList other) {
    _$v = other as _$ChatConversationList;
  }

  @override
  void update(void Function(ChatConversationListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatConversationList build() => _build();

  _$ChatConversationList _build() {
    _$ChatConversationList _$result;
    try {
      _$result = _$v ??
          _$ChatConversationList._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ChatConversationList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
