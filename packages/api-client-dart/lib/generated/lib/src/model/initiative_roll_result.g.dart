// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initiative_roll_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InitiativeRollResult extends InitiativeRollResult {
  @override
  final BuiltList<Combatant> combatants;
  @override
  final int round;

  factory _$InitiativeRollResult(
          [void Function(InitiativeRollResultBuilder)? updates]) =>
      (InitiativeRollResultBuilder()..update(updates))._build();

  _$InitiativeRollResult._({required this.combatants, required this.round})
      : super._();
  @override
  InitiativeRollResult rebuild(
          void Function(InitiativeRollResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InitiativeRollResultBuilder toBuilder() =>
      InitiativeRollResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InitiativeRollResult &&
        combatants == other.combatants &&
        round == other.round;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, combatants.hashCode);
    _$hash = $jc(_$hash, round.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InitiativeRollResult')
          ..add('combatants', combatants)
          ..add('round', round))
        .toString();
  }
}

class InitiativeRollResultBuilder
    implements Builder<InitiativeRollResult, InitiativeRollResultBuilder> {
  _$InitiativeRollResult? _$v;

  ListBuilder<Combatant>? _combatants;
  ListBuilder<Combatant> get combatants =>
      _$this._combatants ??= ListBuilder<Combatant>();
  set combatants(ListBuilder<Combatant>? combatants) =>
      _$this._combatants = combatants;

  int? _round;
  int? get round => _$this._round;
  set round(int? round) => _$this._round = round;

  InitiativeRollResultBuilder() {
    InitiativeRollResult._defaults(this);
  }

  InitiativeRollResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _combatants = $v.combatants.toBuilder();
      _round = $v.round;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InitiativeRollResult other) {
    _$v = other as _$InitiativeRollResult;
  }

  @override
  void update(void Function(InitiativeRollResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InitiativeRollResult build() => _build();

  _$InitiativeRollResult _build() {
    _$InitiativeRollResult _$result;
    try {
      _$result = _$v ??
          _$InitiativeRollResult._(
            combatants: combatants.build(),
            round: BuiltValueNullFieldError.checkNotNull(
                round, r'InitiativeRollResult', 'round'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'combatants';
        combatants.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'InitiativeRollResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
