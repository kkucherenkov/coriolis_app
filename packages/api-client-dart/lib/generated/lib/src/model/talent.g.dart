// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talent.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Talent extends Talent {
  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final int rank;
  @override
  final DateTime acquiredAt;

  factory _$Talent([void Function(TalentBuilder)? updates]) =>
      (new TalentBuilder()..update(updates))._build();

  _$Talent._(
      {required this.id,
      required this.name,
      required this.description,
      required this.rank,
      required this.acquiredAt})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'Talent', 'id');
    BuiltValueNullFieldError.checkNotNull(name, r'Talent', 'name');
    BuiltValueNullFieldError.checkNotNull(
        description, r'Talent', 'description');
    BuiltValueNullFieldError.checkNotNull(rank, r'Talent', 'rank');
    BuiltValueNullFieldError.checkNotNull(acquiredAt, r'Talent', 'acquiredAt');
  }

  @override
  Talent rebuild(void Function(TalentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TalentBuilder toBuilder() => new TalentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Talent &&
        id == other.id &&
        name == other.name &&
        description == other.description &&
        rank == other.rank &&
        acquiredAt == other.acquiredAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, rank.hashCode);
    _$hash = $jc(_$hash, acquiredAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Talent')
          ..add('id', id)
          ..add('name', name)
          ..add('description', description)
          ..add('rank', rank)
          ..add('acquiredAt', acquiredAt))
        .toString();
  }
}

class TalentBuilder implements Builder<Talent, TalentBuilder> {
  _$Talent? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _rank;
  int? get rank => _$this._rank;
  set rank(int? rank) => _$this._rank = rank;

  DateTime? _acquiredAt;
  DateTime? get acquiredAt => _$this._acquiredAt;
  set acquiredAt(DateTime? acquiredAt) => _$this._acquiredAt = acquiredAt;

  TalentBuilder() {
    Talent._defaults(this);
  }

  TalentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _description = $v.description;
      _rank = $v.rank;
      _acquiredAt = $v.acquiredAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Talent other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Talent;
  }

  @override
  void update(void Function(TalentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Talent build() => _build();

  _$Talent _build() {
    final _$result = _$v ??
        new _$Talent._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Talent', 'id'),
            name:
                BuiltValueNullFieldError.checkNotNull(name, r'Talent', 'name'),
            description: BuiltValueNullFieldError.checkNotNull(
                description, r'Talent', 'description'),
            rank:
                BuiltValueNullFieldError.checkNotNull(rank, r'Talent', 'rank'),
            acquiredAt: BuiltValueNullFieldError.checkNotNull(
                acquiredAt, r'Talent', 'acquiredAt'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
