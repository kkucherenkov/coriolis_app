// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talent_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TalentCreate extends TalentCreate {
  @override
  final String name;
  @override
  final String description;
  @override
  final int? rank;

  factory _$TalentCreate([void Function(TalentCreateBuilder)? updates]) =>
      (new TalentCreateBuilder()..update(updates))._build();

  _$TalentCreate._({required this.name, required this.description, this.rank})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, r'TalentCreate', 'name');
    BuiltValueNullFieldError.checkNotNull(
        description, r'TalentCreate', 'description');
  }

  @override
  TalentCreate rebuild(void Function(TalentCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TalentCreateBuilder toBuilder() => new TalentCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TalentCreate &&
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
    return (newBuiltValueToStringHelper(r'TalentCreate')
          ..add('name', name)
          ..add('description', description)
          ..add('rank', rank))
        .toString();
  }
}

class TalentCreateBuilder
    implements Builder<TalentCreate, TalentCreateBuilder> {
  _$TalentCreate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _rank;
  int? get rank => _$this._rank;
  set rank(int? rank) => _$this._rank = rank;

  TalentCreateBuilder() {
    TalentCreate._defaults(this);
  }

  TalentCreateBuilder get _$this {
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
  void replace(TalentCreate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$TalentCreate;
  }

  @override
  void update(void Function(TalentCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TalentCreate build() => _build();

  _$TalentCreate _build() {
    final _$result = _$v ??
        new _$TalentCreate._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'TalentCreate', 'name'),
            description: BuiltValueNullFieldError.checkNotNull(
                description, r'TalentCreate', 'description'),
            rank: rank);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
