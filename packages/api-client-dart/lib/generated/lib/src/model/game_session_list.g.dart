// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GameSessionList extends GameSessionList {
  @override
  final BuiltList<GameSession> items;
  @override
  final String? nextCursor;

  factory _$GameSessionList([void Function(GameSessionListBuilder)? updates]) =>
      (GameSessionListBuilder()..update(updates))._build();

  _$GameSessionList._({required this.items, this.nextCursor}) : super._();
  @override
  GameSessionList rebuild(void Function(GameSessionListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GameSessionListBuilder toBuilder() => GameSessionListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GameSessionList &&
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
    return (newBuiltValueToStringHelper(r'GameSessionList')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GameSessionListBuilder
    implements Builder<GameSessionList, GameSessionListBuilder> {
  _$GameSessionList? _$v;

  ListBuilder<GameSession>? _items;
  ListBuilder<GameSession> get items =>
      _$this._items ??= ListBuilder<GameSession>();
  set items(ListBuilder<GameSession>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GameSessionListBuilder() {
    GameSessionList._defaults(this);
  }

  GameSessionListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GameSessionList other) {
    _$v = other as _$GameSessionList;
  }

  @override
  void update(void Function(GameSessionListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GameSessionList build() => _build();

  _$GameSessionList _build() {
    _$GameSessionList _$result;
    try {
      _$result = _$v ??
          _$GameSessionList._(
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
            r'GameSessionList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
