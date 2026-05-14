// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipList extends ShipList {
  @override
  final BuiltList<Ship> items;
  @override
  final String? nextCursor;

  factory _$ShipList([void Function(ShipListBuilder)? updates]) =>
      (ShipListBuilder()..update(updates))._build();

  _$ShipList._({required this.items, this.nextCursor}) : super._();
  @override
  ShipList rebuild(void Function(ShipListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipListBuilder toBuilder() => ShipListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipList &&
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
    return (newBuiltValueToStringHelper(r'ShipList')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class ShipListBuilder implements Builder<ShipList, ShipListBuilder> {
  _$ShipList? _$v;

  ListBuilder<Ship>? _items;
  ListBuilder<Ship> get items => _$this._items ??= ListBuilder<Ship>();
  set items(ListBuilder<Ship>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  ShipListBuilder() {
    ShipList._defaults(this);
  }

  ShipListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipList other) {
    _$v = other as _$ShipList;
  }

  @override
  void update(void Function(ShipListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipList build() => _build();

  _$ShipList _build() {
    _$ShipList _$result;
    try {
      _$result = _$v ??
          _$ShipList._(
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
            r'ShipList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
