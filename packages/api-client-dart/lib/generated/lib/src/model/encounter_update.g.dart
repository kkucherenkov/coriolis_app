// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encounter_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EncounterUpdate extends EncounterUpdate {
  @override
  final String? name;
  @override
  final EncounterStatus? status;
  @override
  final String? notes;

  factory _$EncounterUpdate([void Function(EncounterUpdateBuilder)? updates]) =>
      (EncounterUpdateBuilder()..update(updates))._build();

  _$EncounterUpdate._({this.name, this.status, this.notes}) : super._();
  @override
  EncounterUpdate rebuild(void Function(EncounterUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EncounterUpdateBuilder toBuilder() => EncounterUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EncounterUpdate &&
        name == other.name &&
        status == other.status &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EncounterUpdate')
          ..add('name', name)
          ..add('status', status)
          ..add('notes', notes))
        .toString();
  }
}

class EncounterUpdateBuilder
    implements Builder<EncounterUpdate, EncounterUpdateBuilder> {
  _$EncounterUpdate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  EncounterStatus? _status;
  EncounterStatus? get status => _$this._status;
  set status(EncounterStatus? status) => _$this._status = status;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  EncounterUpdateBuilder() {
    EncounterUpdate._defaults(this);
  }

  EncounterUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _status = $v.status;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EncounterUpdate other) {
    _$v = other as _$EncounterUpdate;
  }

  @override
  void update(void Function(EncounterUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EncounterUpdate build() => _build();

  _$EncounterUpdate _build() {
    final _$result = _$v ??
        _$EncounterUpdate._(
          name: name,
          status: status,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
