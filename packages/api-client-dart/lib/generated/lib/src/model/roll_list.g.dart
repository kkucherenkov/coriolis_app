// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roll_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RollList extends RollList {
  @override
  final BuiltList<Roll> items;

  factory _$RollList([void Function(RollListBuilder)? updates]) =>
      (new RollListBuilder()..update(updates))._build();

  _$RollList._({required this.items}) : super._() {
    BuiltValueNullFieldError.checkNotNull(items, r'RollList', 'items');
  }

  @override
  RollList rebuild(void Function(RollListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RollListBuilder toBuilder() => new RollListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RollList && items == other.items;
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
    return (newBuiltValueToStringHelper(r'RollList')..add('items', items))
        .toString();
  }
}

class RollListBuilder implements Builder<RollList, RollListBuilder> {
  _$RollList? _$v;

  ListBuilder<Roll>? _items;
  ListBuilder<Roll> get items => _$this._items ??= new ListBuilder<Roll>();
  set items(ListBuilder<Roll>? items) => _$this._items = items;

  RollListBuilder() {
    RollList._defaults(this);
  }

  RollListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RollList other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$RollList;
  }

  @override
  void update(void Function(RollListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RollList build() => _build();

  _$RollList _build() {
    _$RollList _$result;
    try {
      _$result = _$v ?? new _$RollList._(items: items.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'RollList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
