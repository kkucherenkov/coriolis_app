// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encounter_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EncounterCreate extends EncounterCreate {
  @override
  final String name;
  @override
  final String? notes;

  factory _$EncounterCreate([void Function(EncounterCreateBuilder)? updates]) =>
      (EncounterCreateBuilder()..update(updates))._build();

  _$EncounterCreate._({required this.name, this.notes}) : super._();
  @override
  EncounterCreate rebuild(void Function(EncounterCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EncounterCreateBuilder toBuilder() => EncounterCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EncounterCreate &&
        name == other.name &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EncounterCreate')
          ..add('name', name)
          ..add('notes', notes))
        .toString();
  }
}

class EncounterCreateBuilder
    implements Builder<EncounterCreate, EncounterCreateBuilder> {
  _$EncounterCreate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  EncounterCreateBuilder() {
    EncounterCreate._defaults(this);
  }

  EncounterCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EncounterCreate other) {
    _$v = other as _$EncounterCreate;
  }

  @override
  void update(void Function(EncounterCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EncounterCreate build() => _build();

  _$EncounterCreate _build() {
    final _$result =
        _$v ??
        _$EncounterCreate._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'EncounterCreate',
            'name',
          ),
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
