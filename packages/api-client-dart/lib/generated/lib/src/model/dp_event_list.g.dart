// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dp_event_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DpEventList extends DpEventList {
  @override
  final BuiltList<dynamic> items;
  @override
  final String? nextCursor;

  factory _$DpEventList([void Function(DpEventListBuilder)? updates]) =>
      (DpEventListBuilder()..update(updates))._build();

  _$DpEventList._({required this.items, this.nextCursor}) : super._();
  @override
  DpEventList rebuild(void Function(DpEventListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DpEventListBuilder toBuilder() => DpEventListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DpEventList &&
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
    return (newBuiltValueToStringHelper(r'DpEventList')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class DpEventListBuilder implements Builder<DpEventList, DpEventListBuilder> {
  _$DpEventList? _$v;

  ListBuilder<dynamic>? _items;
  ListBuilder<dynamic> get items => _$this._items ??= ListBuilder<dynamic>();
  set items(ListBuilder<dynamic>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  DpEventListBuilder() {
    DpEventList._defaults(this);
  }

  DpEventListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DpEventList other) {
    _$v = other as _$DpEventList;
  }

  @override
  void update(void Function(DpEventListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DpEventList build() => _build();

  _$DpEventList _build() {
    _$DpEventList _$result;
    try {
      _$result =
          _$v ?? _$DpEventList._(items: items.build(), nextCursor: nextCursor);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DpEventList',
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
