// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encounter.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Encounter extends Encounter {
  @override
  final String id;
  @override
  final String gameSessionId;
  @override
  final String name;
  @override
  final EncounterStatus status;
  @override
  final int round;
  @override
  final String? activeCombatantId;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$Encounter([void Function(EncounterBuilder)? updates]) =>
      (new EncounterBuilder()..update(updates))._build();

  _$Encounter._(
      {required this.id,
      required this.gameSessionId,
      required this.name,
      required this.status,
      required this.round,
      this.activeCombatantId,
      this.notes,
      required this.createdAt,
      required this.updatedAt})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'Encounter', 'id');
    BuiltValueNullFieldError.checkNotNull(
        gameSessionId, r'Encounter', 'gameSessionId');
    BuiltValueNullFieldError.checkNotNull(name, r'Encounter', 'name');
    BuiltValueNullFieldError.checkNotNull(status, r'Encounter', 'status');
    BuiltValueNullFieldError.checkNotNull(round, r'Encounter', 'round');
    BuiltValueNullFieldError.checkNotNull(createdAt, r'Encounter', 'createdAt');
    BuiltValueNullFieldError.checkNotNull(updatedAt, r'Encounter', 'updatedAt');
  }

  @override
  Encounter rebuild(void Function(EncounterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EncounterBuilder toBuilder() => new EncounterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Encounter &&
        id == other.id &&
        gameSessionId == other.gameSessionId &&
        name == other.name &&
        status == other.status &&
        round == other.round &&
        activeCombatantId == other.activeCombatantId &&
        notes == other.notes &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, gameSessionId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, round.hashCode);
    _$hash = $jc(_$hash, activeCombatantId.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Encounter')
          ..add('id', id)
          ..add('gameSessionId', gameSessionId)
          ..add('name', name)
          ..add('status', status)
          ..add('round', round)
          ..add('activeCombatantId', activeCombatantId)
          ..add('notes', notes)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class EncounterBuilder implements Builder<Encounter, EncounterBuilder> {
  _$Encounter? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _gameSessionId;
  String? get gameSessionId => _$this._gameSessionId;
  set gameSessionId(String? gameSessionId) =>
      _$this._gameSessionId = gameSessionId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  EncounterStatus? _status;
  EncounterStatus? get status => _$this._status;
  set status(EncounterStatus? status) => _$this._status = status;

  int? _round;
  int? get round => _$this._round;
  set round(int? round) => _$this._round = round;

  String? _activeCombatantId;
  String? get activeCombatantId => _$this._activeCombatantId;
  set activeCombatantId(String? activeCombatantId) =>
      _$this._activeCombatantId = activeCombatantId;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  EncounterBuilder() {
    Encounter._defaults(this);
  }

  EncounterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _gameSessionId = $v.gameSessionId;
      _name = $v.name;
      _status = $v.status;
      _round = $v.round;
      _activeCombatantId = $v.activeCombatantId;
      _notes = $v.notes;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Encounter other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Encounter;
  }

  @override
  void update(void Function(EncounterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Encounter build() => _build();

  _$Encounter _build() {
    final _$result = _$v ??
        new _$Encounter._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Encounter', 'id'),
            gameSessionId: BuiltValueNullFieldError.checkNotNull(
                gameSessionId, r'Encounter', 'gameSessionId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'Encounter', 'name'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Encounter', 'status'),
            round: BuiltValueNullFieldError.checkNotNull(
                round, r'Encounter', 'round'),
            activeCombatantId: activeCombatantId,
            notes: notes,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Encounter', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'Encounter', 'updatedAt'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
