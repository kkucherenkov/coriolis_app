// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combatant_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CombatantList extends CombatantList {
  @override
  final BuiltList<dynamic> items;

  factory _$CombatantList([void Function(CombatantListBuilder)? updates]) =>
      (CombatantListBuilder()..update(updates))._build();

  _$CombatantList._({required this.items}) : super._();
  @override
  CombatantList rebuild(void Function(CombatantListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CombatantListBuilder toBuilder() => CombatantListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CombatantList && items == other.items;
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
    return (newBuiltValueToStringHelper(
      r'CombatantList',
    )..add('items', items)).toString();
  }
}

class CombatantListBuilder
    implements Builder<CombatantList, CombatantListBuilder> {
  _$CombatantList? _$v;

  ListBuilder<dynamic>? _items;
  ListBuilder<dynamic> get items => _$this._items ??= ListBuilder<dynamic>();
  set items(ListBuilder<dynamic>? items) => _$this._items = items;

  CombatantListBuilder() {
    CombatantList._defaults(this);
  }

  CombatantListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CombatantList other) {
    _$v = other as _$CombatantList;
  }

  @override
  void update(void Function(CombatantListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CombatantList build() => _build();

  _$CombatantList _build() {
    _$CombatantList _$result;
    try {
      _$result = _$v ?? _$CombatantList._(items: items.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CombatantList',
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
