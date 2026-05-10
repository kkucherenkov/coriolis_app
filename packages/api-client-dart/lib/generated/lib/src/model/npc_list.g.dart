// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NpcList extends NpcList {
  @override
  final BuiltList<Npc> items;
  @override
  final String? nextCursor;

  factory _$NpcList([void Function(NpcListBuilder)? updates]) =>
      (new NpcListBuilder()..update(updates))._build();

  _$NpcList._({required this.items, this.nextCursor}) : super._() {
    BuiltValueNullFieldError.checkNotNull(items, r'NpcList', 'items');
  }

  @override
  NpcList rebuild(void Function(NpcListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NpcListBuilder toBuilder() => new NpcListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NpcList &&
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
    return (newBuiltValueToStringHelper(r'NpcList')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class NpcListBuilder implements Builder<NpcList, NpcListBuilder> {
  _$NpcList? _$v;

  ListBuilder<Npc>? _items;
  ListBuilder<Npc> get items => _$this._items ??= new ListBuilder<Npc>();
  set items(ListBuilder<Npc>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  NpcListBuilder() {
    NpcList._defaults(this);
  }

  NpcListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NpcList other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$NpcList;
  }

  @override
  void update(void Function(NpcListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NpcList build() => _build();

  _$NpcList _build() {
    _$NpcList _$result;
    try {
      _$result =
          _$v ?? new _$NpcList._(items: items.build(), nextCursor: nextCursor);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'NpcList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
