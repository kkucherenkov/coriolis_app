// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combatant_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CombatantCreate extends CombatantCreate {
  @override
  final CombatantType combatantType;
  @override
  final String sourceId;
  @override
  final String? displayName;
  @override
  final String? notes;

  factory _$CombatantCreate([void Function(CombatantCreateBuilder)? updates]) =>
      (CombatantCreateBuilder()..update(updates))._build();

  _$CombatantCreate._(
      {required this.combatantType,
      required this.sourceId,
      this.displayName,
      this.notes})
      : super._();
  @override
  CombatantCreate rebuild(void Function(CombatantCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CombatantCreateBuilder toBuilder() => CombatantCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CombatantCreate &&
        combatantType == other.combatantType &&
        sourceId == other.sourceId &&
        displayName == other.displayName &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, combatantType.hashCode);
    _$hash = $jc(_$hash, sourceId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CombatantCreate')
          ..add('combatantType', combatantType)
          ..add('sourceId', sourceId)
          ..add('displayName', displayName)
          ..add('notes', notes))
        .toString();
  }
}

class CombatantCreateBuilder
    implements Builder<CombatantCreate, CombatantCreateBuilder> {
  _$CombatantCreate? _$v;

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

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  CombatantCreateBuilder() {
    CombatantCreate._defaults(this);
  }

  CombatantCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _combatantType = $v.combatantType;
      _sourceId = $v.sourceId;
      _displayName = $v.displayName;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CombatantCreate other) {
    _$v = other as _$CombatantCreate;
  }

  @override
  void update(void Function(CombatantCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CombatantCreate build() => _build();

  _$CombatantCreate _build() {
    final _$result = _$v ??
        _$CombatantCreate._(
          combatantType: BuiltValueNullFieldError.checkNotNull(
              combatantType, r'CombatantCreate', 'combatantType'),
          sourceId: BuiltValueNullFieldError.checkNotNull(
              sourceId, r'CombatantCreate', 'sourceId'),
          displayName: displayName,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
