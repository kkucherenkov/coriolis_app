// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Relationship extends Relationship {
  @override
  final String id;
  @override
  final String targetName;
  @override
  final RelationshipKind kind;
  @override
  final String? notes;

  factory _$Relationship([void Function(RelationshipBuilder)? updates]) =>
      (RelationshipBuilder()..update(updates))._build();

  _$Relationship._(
      {required this.id,
      required this.targetName,
      required this.kind,
      this.notes})
      : super._();
  @override
  Relationship rebuild(void Function(RelationshipBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RelationshipBuilder toBuilder() => RelationshipBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Relationship &&
        id == other.id &&
        targetName == other.targetName &&
        kind == other.kind &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, targetName.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Relationship')
          ..add('id', id)
          ..add('targetName', targetName)
          ..add('kind', kind)
          ..add('notes', notes))
        .toString();
  }
}

class RelationshipBuilder
    implements Builder<Relationship, RelationshipBuilder> {
  _$Relationship? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _targetName;
  String? get targetName => _$this._targetName;
  set targetName(String? targetName) => _$this._targetName = targetName;

  RelationshipKind? _kind;
  RelationshipKind? get kind => _$this._kind;
  set kind(RelationshipKind? kind) => _$this._kind = kind;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  RelationshipBuilder() {
    Relationship._defaults(this);
  }

  RelationshipBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _targetName = $v.targetName;
      _kind = $v.kind;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Relationship other) {
    _$v = other as _$Relationship;
  }

  @override
  void update(void Function(RelationshipBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Relationship build() => _build();

  _$Relationship _build() {
    final _$result = _$v ??
        _$Relationship._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Relationship', 'id'),
          targetName: BuiltValueNullFieldError.checkNotNull(
              targetName, r'Relationship', 'targetName'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'Relationship', 'kind'),
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
