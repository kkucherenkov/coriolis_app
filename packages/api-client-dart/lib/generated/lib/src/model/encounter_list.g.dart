// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encounter_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EncounterList extends EncounterList {
  @override
  final BuiltList<Encounter> items;
  @override
  final String? nextCursor;

  factory _$EncounterList([void Function(EncounterListBuilder)? updates]) =>
      (new EncounterListBuilder()..update(updates))._build();

  _$EncounterList._({required this.items, this.nextCursor}) : super._() {
    BuiltValueNullFieldError.checkNotNull(items, r'EncounterList', 'items');
  }

  @override
  EncounterList rebuild(void Function(EncounterListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EncounterListBuilder toBuilder() => new EncounterListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EncounterList &&
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
    return (newBuiltValueToStringHelper(r'EncounterList')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class EncounterListBuilder
    implements Builder<EncounterList, EncounterListBuilder> {
  _$EncounterList? _$v;

  ListBuilder<Encounter>? _items;
  ListBuilder<Encounter> get items =>
      _$this._items ??= new ListBuilder<Encounter>();
  set items(ListBuilder<Encounter>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  EncounterListBuilder() {
    EncounterList._defaults(this);
  }

  EncounterListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EncounterList other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$EncounterList;
  }

  @override
  void update(void Function(EncounterListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EncounterList build() => _build();

  _$EncounterList _build() {
    _$EncounterList _$result;
    try {
      _$result = _$v ??
          new _$EncounterList._(items: items.build(), nextCursor: nextCursor);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'EncounterList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
