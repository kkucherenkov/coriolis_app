// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talent_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TalentUpdate extends TalentUpdate {
  @override
  final String? name;
  @override
  final String? description;
  @override
  final int? rank;

  factory _$TalentUpdate([void Function(TalentUpdateBuilder)? updates]) =>
      (TalentUpdateBuilder()..update(updates))._build();

  _$TalentUpdate._({this.name, this.description, this.rank}) : super._();
  @override
  TalentUpdate rebuild(void Function(TalentUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TalentUpdateBuilder toBuilder() => TalentUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TalentUpdate &&
        name == other.name &&
        description == other.description &&
        rank == other.rank;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, rank.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TalentUpdate')
          ..add('name', name)
          ..add('description', description)
          ..add('rank', rank))
        .toString();
  }
}

class TalentUpdateBuilder
    implements Builder<TalentUpdate, TalentUpdateBuilder> {
  _$TalentUpdate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _rank;
  int? get rank => _$this._rank;
  set rank(int? rank) => _$this._rank = rank;

  TalentUpdateBuilder() {
    TalentUpdate._defaults(this);
  }

  TalentUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _rank = $v.rank;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TalentUpdate other) {
    _$v = other as _$TalentUpdate;
  }

  @override
  void update(void Function(TalentUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TalentUpdate build() => _build();

  _$TalentUpdate _build() {
    final _$result =
        _$v ??
        _$TalentUpdate._(name: name, description: description, rank: rank);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
