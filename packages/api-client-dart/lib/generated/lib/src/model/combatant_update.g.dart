// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combatant_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CombatantUpdate extends CombatantUpdate {
  @override
  final String? displayName;
  @override
  final int? hpCurrent;
  @override
  final int? armor;
  @override
  final int? signature;
  @override
  final BuiltList<String>? statusFlags;
  @override
  final String? notes;
  @override
  final int? initiative;
  @override
  final int? turnOrder;

  factory _$CombatantUpdate([void Function(CombatantUpdateBuilder)? updates]) =>
      (CombatantUpdateBuilder()..update(updates))._build();

  _$CombatantUpdate._(
      {this.displayName,
      this.hpCurrent,
      this.armor,
      this.signature,
      this.statusFlags,
      this.notes,
      this.initiative,
      this.turnOrder})
      : super._();
  @override
  CombatantUpdate rebuild(void Function(CombatantUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CombatantUpdateBuilder toBuilder() => CombatantUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CombatantUpdate &&
        displayName == other.displayName &&
        hpCurrent == other.hpCurrent &&
        armor == other.armor &&
        signature == other.signature &&
        statusFlags == other.statusFlags &&
        notes == other.notes &&
        initiative == other.initiative &&
        turnOrder == other.turnOrder;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, hpCurrent.hashCode);
    _$hash = $jc(_$hash, armor.hashCode);
    _$hash = $jc(_$hash, signature.hashCode);
    _$hash = $jc(_$hash, statusFlags.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, initiative.hashCode);
    _$hash = $jc(_$hash, turnOrder.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CombatantUpdate')
          ..add('displayName', displayName)
          ..add('hpCurrent', hpCurrent)
          ..add('armor', armor)
          ..add('signature', signature)
          ..add('statusFlags', statusFlags)
          ..add('notes', notes)
          ..add('initiative', initiative)
          ..add('turnOrder', turnOrder))
        .toString();
  }
}

class CombatantUpdateBuilder
    implements Builder<CombatantUpdate, CombatantUpdateBuilder> {
  _$CombatantUpdate? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  int? _hpCurrent;
  int? get hpCurrent => _$this._hpCurrent;
  set hpCurrent(int? hpCurrent) => _$this._hpCurrent = hpCurrent;

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

  int? _initiative;
  int? get initiative => _$this._initiative;
  set initiative(int? initiative) => _$this._initiative = initiative;

  int? _turnOrder;
  int? get turnOrder => _$this._turnOrder;
  set turnOrder(int? turnOrder) => _$this._turnOrder = turnOrder;

  CombatantUpdateBuilder() {
    CombatantUpdate._defaults(this);
  }

  CombatantUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _hpCurrent = $v.hpCurrent;
      _armor = $v.armor;
      _signature = $v.signature;
      _statusFlags = $v.statusFlags?.toBuilder();
      _notes = $v.notes;
      _initiative = $v.initiative;
      _turnOrder = $v.turnOrder;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CombatantUpdate other) {
    _$v = other as _$CombatantUpdate;
  }

  @override
  void update(void Function(CombatantUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CombatantUpdate build() => _build();

  _$CombatantUpdate _build() {
    _$CombatantUpdate _$result;
    try {
      _$result = _$v ??
          _$CombatantUpdate._(
            displayName: displayName,
            hpCurrent: hpCurrent,
            armor: armor,
            signature: signature,
            statusFlags: _statusFlags?.build(),
            notes: notes,
            initiative: initiative,
            turnOrder: turnOrder,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'statusFlags';
        _statusFlags?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CombatantUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
