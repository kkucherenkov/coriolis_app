// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turn_advance_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TurnAdvanceResult extends TurnAdvanceResult {
  @override
  final String activeCombatantId;
  @override
  final int round;
  @override
  final bool isNewRound;

  factory _$TurnAdvanceResult(
          [void Function(TurnAdvanceResultBuilder)? updates]) =>
      (TurnAdvanceResultBuilder()..update(updates))._build();

  _$TurnAdvanceResult._(
      {required this.activeCombatantId,
      required this.round,
      required this.isNewRound})
      : super._();
  @override
  TurnAdvanceResult rebuild(void Function(TurnAdvanceResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TurnAdvanceResultBuilder toBuilder() =>
      TurnAdvanceResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TurnAdvanceResult &&
        activeCombatantId == other.activeCombatantId &&
        round == other.round &&
        isNewRound == other.isNewRound;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeCombatantId.hashCode);
    _$hash = $jc(_$hash, round.hashCode);
    _$hash = $jc(_$hash, isNewRound.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TurnAdvanceResult')
          ..add('activeCombatantId', activeCombatantId)
          ..add('round', round)
          ..add('isNewRound', isNewRound))
        .toString();
  }
}

class TurnAdvanceResultBuilder
    implements Builder<TurnAdvanceResult, TurnAdvanceResultBuilder> {
  _$TurnAdvanceResult? _$v;

  String? _activeCombatantId;
  String? get activeCombatantId => _$this._activeCombatantId;
  set activeCombatantId(String? activeCombatantId) =>
      _$this._activeCombatantId = activeCombatantId;

  int? _round;
  int? get round => _$this._round;
  set round(int? round) => _$this._round = round;

  bool? _isNewRound;
  bool? get isNewRound => _$this._isNewRound;
  set isNewRound(bool? isNewRound) => _$this._isNewRound = isNewRound;

  TurnAdvanceResultBuilder() {
    TurnAdvanceResult._defaults(this);
  }

  TurnAdvanceResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeCombatantId = $v.activeCombatantId;
      _round = $v.round;
      _isNewRound = $v.isNewRound;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TurnAdvanceResult other) {
    _$v = other as _$TurnAdvanceResult;
  }

  @override
  void update(void Function(TurnAdvanceResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TurnAdvanceResult build() => _build();

  _$TurnAdvanceResult _build() {
    final _$result = _$v ??
        _$TurnAdvanceResult._(
          activeCombatantId: BuiltValueNullFieldError.checkNotNull(
              activeCombatantId, r'TurnAdvanceResult', 'activeCombatantId'),
          round: BuiltValueNullFieldError.checkNotNull(
              round, r'TurnAdvanceResult', 'round'),
          isNewRound: BuiltValueNullFieldError.checkNotNull(
              isNewRound, r'TurnAdvanceResult', 'isNewRound'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
