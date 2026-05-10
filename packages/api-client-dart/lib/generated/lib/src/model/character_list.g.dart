// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CharacterList extends CharacterList {
  @override
  final BuiltList<dynamic> items;
  @override
  final String? nextCursor;

  factory _$CharacterList([void Function(CharacterListBuilder)? updates]) =>
      (CharacterListBuilder()..update(updates))._build();

  _$CharacterList._({required this.items, this.nextCursor}) : super._();
  @override
  CharacterList rebuild(void Function(CharacterListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterListBuilder toBuilder() => CharacterListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CharacterList &&
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
    return (newBuiltValueToStringHelper(r'CharacterList')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class CharacterListBuilder
    implements Builder<CharacterList, CharacterListBuilder> {
  _$CharacterList? _$v;

  ListBuilder<dynamic>? _items;
  ListBuilder<dynamic> get items => _$this._items ??= ListBuilder<dynamic>();
  set items(ListBuilder<dynamic>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  CharacterListBuilder() {
    CharacterList._defaults(this);
  }

  CharacterListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CharacterList other) {
    _$v = other as _$CharacterList;
  }

  @override
  void update(void Function(CharacterListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CharacterList build() => _build();

  _$CharacterList _build() {
    _$CharacterList _$result;
    try {
      _$result =
          _$v ??
          _$CharacterList._(items: items.build(), nextCursor: nextCursor);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CharacterList',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
