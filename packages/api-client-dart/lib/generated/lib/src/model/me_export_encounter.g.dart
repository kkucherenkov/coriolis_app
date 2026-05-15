// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_export_encounter.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeExportEncounter extends MeExportEncounter {
  @override
  final BuiltList<Combatant> combatants;
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

  factory _$MeExportEncounter(
          [void Function(MeExportEncounterBuilder)? updates]) =>
      (MeExportEncounterBuilder()..update(updates))._build();

  _$MeExportEncounter._(
      {required this.combatants,
      required this.id,
      required this.gameSessionId,
      required this.name,
      required this.status,
      required this.round,
      this.activeCombatantId,
      this.notes,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  MeExportEncounter rebuild(void Function(MeExportEncounterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeExportEncounterBuilder toBuilder() =>
      MeExportEncounterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeExportEncounter &&
        combatants == other.combatants &&
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
    _$hash = $jc(_$hash, combatants.hashCode);
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
    return (newBuiltValueToStringHelper(r'MeExportEncounter')
          ..add('combatants', combatants)
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

class MeExportEncounterBuilder
    implements
        Builder<MeExportEncounter, MeExportEncounterBuilder>,
        EncounterBuilder {
  _$MeExportEncounter? _$v;

  ListBuilder<Combatant>? _combatants;
  ListBuilder<Combatant> get combatants =>
      _$this._combatants ??= ListBuilder<Combatant>();
  set combatants(covariant ListBuilder<Combatant>? combatants) =>
      _$this._combatants = combatants;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _gameSessionId;
  String? get gameSessionId => _$this._gameSessionId;
  set gameSessionId(covariant String? gameSessionId) =>
      _$this._gameSessionId = gameSessionId;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  EncounterStatus? _status;
  EncounterStatus? get status => _$this._status;
  set status(covariant EncounterStatus? status) => _$this._status = status;

  int? _round;
  int? get round => _$this._round;
  set round(covariant int? round) => _$this._round = round;

  String? _activeCombatantId;
  String? get activeCombatantId => _$this._activeCombatantId;
  set activeCombatantId(covariant String? activeCombatantId) =>
      _$this._activeCombatantId = activeCombatantId;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(covariant String? notes) => _$this._notes = notes;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(covariant DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(covariant DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  MeExportEncounterBuilder() {
    MeExportEncounter._defaults(this);
  }

  MeExportEncounterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _combatants = $v.combatants.toBuilder();
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
  void replace(covariant MeExportEncounter other) {
    _$v = other as _$MeExportEncounter;
  }

  @override
  void update(void Function(MeExportEncounterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeExportEncounter build() => _build();

  _$MeExportEncounter _build() {
    _$MeExportEncounter _$result;
    try {
      _$result = _$v ??
          _$MeExportEncounter._(
            combatants: combatants.build(),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'MeExportEncounter', 'id'),
            gameSessionId: BuiltValueNullFieldError.checkNotNull(
                gameSessionId, r'MeExportEncounter', 'gameSessionId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'MeExportEncounter', 'name'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'MeExportEncounter', 'status'),
            round: BuiltValueNullFieldError.checkNotNull(
                round, r'MeExportEncounter', 'round'),
            activeCombatantId: activeCombatantId,
            notes: notes,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'MeExportEncounter', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'MeExportEncounter', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'combatants';
        combatants.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MeExportEncounter', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
