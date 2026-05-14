// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combatant.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Combatant extends Combatant {
  @override
  final String id;
  @override
  final String encounterId;
  @override
  final CombatantType combatantType;
  @override
  final String sourceId;
  @override
  final String displayName;
  @override
  final int? initiative;
  @override
  final int? turnOrder;
  @override
  final int hpCurrent;
  @override
  final int hpMax;
  @override
  final int armor;
  @override
  final int signature;
  @override
  final BuiltList<String> statusFlags;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$Combatant([void Function(CombatantBuilder)? updates]) =>
      (CombatantBuilder()..update(updates))._build();

  _$Combatant._(
      {required this.id,
      required this.encounterId,
      required this.combatantType,
      required this.sourceId,
      required this.displayName,
      this.initiative,
      this.turnOrder,
      required this.hpCurrent,
      required this.hpMax,
      required this.armor,
      required this.signature,
      required this.statusFlags,
      this.notes,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  Combatant rebuild(void Function(CombatantBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CombatantBuilder toBuilder() => CombatantBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Combatant &&
        id == other.id &&
        encounterId == other.encounterId &&
        combatantType == other.combatantType &&
        sourceId == other.sourceId &&
        displayName == other.displayName &&
        initiative == other.initiative &&
        turnOrder == other.turnOrder &&
        hpCurrent == other.hpCurrent &&
        hpMax == other.hpMax &&
        armor == other.armor &&
        signature == other.signature &&
        statusFlags == other.statusFlags &&
        notes == other.notes &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, encounterId.hashCode);
    _$hash = $jc(_$hash, combatantType.hashCode);
    _$hash = $jc(_$hash, sourceId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, initiative.hashCode);
    _$hash = $jc(_$hash, turnOrder.hashCode);
    _$hash = $jc(_$hash, hpCurrent.hashCode);
    _$hash = $jc(_$hash, hpMax.hashCode);
    _$hash = $jc(_$hash, armor.hashCode);
    _$hash = $jc(_$hash, signature.hashCode);
    _$hash = $jc(_$hash, statusFlags.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Combatant')
          ..add('id', id)
          ..add('encounterId', encounterId)
          ..add('combatantType', combatantType)
          ..add('sourceId', sourceId)
          ..add('displayName', displayName)
          ..add('initiative', initiative)
          ..add('turnOrder', turnOrder)
          ..add('hpCurrent', hpCurrent)
          ..add('hpMax', hpMax)
          ..add('armor', armor)
          ..add('signature', signature)
          ..add('statusFlags', statusFlags)
          ..add('notes', notes)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CombatantBuilder implements Builder<Combatant, CombatantBuilder> {
  _$Combatant? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _encounterId;
  String? get encounterId => _$this._encounterId;
  set encounterId(String? encounterId) => _$this._encounterId = encounterId;

  CombatantType? _combatantType;
  CombatantType? get combatantType => _$this._combatantType;
  set combatantType(CombatantType? combatantType) =>
      _$this._combatantType = combatantType;

  String? _sourceId;
  String? get sourceId => _$this._sourceId;
  set sourceId(String? sourceId) => _$this._sourceId = sourceId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  int? _initiative;
  int? get initiative => _$this._initiative;
  set initiative(int? initiative) => _$this._initiative = initiative;

  int? _turnOrder;
  int? get turnOrder => _$this._turnOrder;
  set turnOrder(int? turnOrder) => _$this._turnOrder = turnOrder;

  int? _hpCurrent;
  int? get hpCurrent => _$this._hpCurrent;
  set hpCurrent(int? hpCurrent) => _$this._hpCurrent = hpCurrent;

  int? _hpMax;
  int? get hpMax => _$this._hpMax;
  set hpMax(int? hpMax) => _$this._hpMax = hpMax;

  int? _armor;
  int? get armor => _$this._armor;
  set armor(int? armor) => _$this._armor = armor;

  int? _signature;
  int? get signature => _$this._signature;
  set signature(int? signature) => _$this._signature = signature;

  ListBuilder<String>? _statusFlags;
  ListBuilder<String> get statusFlags =>
      _$this._statusFlags ??= ListBuilder<String>();
  set statusFlags(ListBuilder<String>? statusFlags) =>
      _$this._statusFlags = statusFlags;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CombatantBuilder() {
    Combatant._defaults(this);
  }

  CombatantBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _encounterId = $v.encounterId;
      _combatantType = $v.combatantType;
      _sourceId = $v.sourceId;
      _displayName = $v.displayName;
      _initiative = $v.initiative;
      _turnOrder = $v.turnOrder;
      _hpCurrent = $v.hpCurrent;
      _hpMax = $v.hpMax;
      _armor = $v.armor;
      _signature = $v.signature;
      _statusFlags = $v.statusFlags.toBuilder();
      _notes = $v.notes;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Combatant other) {
    _$v = other as _$Combatant;
  }

  @override
  void update(void Function(CombatantBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Combatant build() => _build();

  _$Combatant _build() {
    _$Combatant _$result;
    try {
      _$result = _$v ??
          _$Combatant._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Combatant', 'id'),
            encounterId: BuiltValueNullFieldError.checkNotNull(
                encounterId, r'Combatant', 'encounterId'),
            combatantType: BuiltValueNullFieldError.checkNotNull(
                combatantType, r'Combatant', 'combatantType'),
            sourceId: BuiltValueNullFieldError.checkNotNull(
                sourceId, r'Combatant', 'sourceId'),
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'Combatant', 'displayName'),
            initiative: initiative,
            turnOrder: turnOrder,
            hpCurrent: BuiltValueNullFieldError.checkNotNull(
                hpCurrent, r'Combatant', 'hpCurrent'),
            hpMax: BuiltValueNullFieldError.checkNotNull(
                hpMax, r'Combatant', 'hpMax'),
            armor: BuiltValueNullFieldError.checkNotNull(
                armor, r'Combatant', 'armor'),
            signature: BuiltValueNullFieldError.checkNotNull(
                signature, r'Combatant', 'signature'),
            statusFlags: statusFlags.build(),
            notes: notes,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Combatant', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'Combatant', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'statusFlags';
        statusFlags.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Combatant', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
