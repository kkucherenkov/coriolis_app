// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roll_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RollCreate extends RollCreate {
  @override
  final RollKind? kind;
  @override
  final String label;
  @override
  final int pool;
  @override
  final String? gameSessionId;
  @override
  final RollBreakdown? breakdown;

  factory _$RollCreate([void Function(RollCreateBuilder)? updates]) =>
      (RollCreateBuilder()..update(updates))._build();

  _$RollCreate._(
      {this.kind,
      required this.label,
      required this.pool,
      this.gameSessionId,
      this.breakdown})
      : super._();
  @override
  RollCreate rebuild(void Function(RollCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RollCreateBuilder toBuilder() => RollCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RollCreate &&
        kind == other.kind &&
        label == other.label &&
        pool == other.pool &&
        gameSessionId == other.gameSessionId &&
        breakdown == other.breakdown;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, pool.hashCode);
    _$hash = $jc(_$hash, gameSessionId.hashCode);
    _$hash = $jc(_$hash, breakdown.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RollCreate')
          ..add('kind', kind)
          ..add('label', label)
          ..add('pool', pool)
          ..add('gameSessionId', gameSessionId)
          ..add('breakdown', breakdown))
        .toString();
  }
}

class RollCreateBuilder implements Builder<RollCreate, RollCreateBuilder> {
  _$RollCreate? _$v;

  RollKind? _kind;
  RollKind? get kind => _$this._kind;
  set kind(RollKind? kind) => _$this._kind = kind;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  int? _pool;
  int? get pool => _$this._pool;
  set pool(int? pool) => _$this._pool = pool;

  String? _gameSessionId;
  String? get gameSessionId => _$this._gameSessionId;
  set gameSessionId(String? gameSessionId) =>
      _$this._gameSessionId = gameSessionId;

  RollBreakdownBuilder? _breakdown;
  RollBreakdownBuilder get breakdown =>
      _$this._breakdown ??= RollBreakdownBuilder();
  set breakdown(RollBreakdownBuilder? breakdown) =>
      _$this._breakdown = breakdown;

  RollCreateBuilder() {
    RollCreate._defaults(this);
  }

  RollCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _label = $v.label;
      _pool = $v.pool;
      _gameSessionId = $v.gameSessionId;
      _breakdown = $v.breakdown?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RollCreate other) {
    _$v = other as _$RollCreate;
  }

  @override
  void update(void Function(RollCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RollCreate build() => _build();

  _$RollCreate _build() {
    _$RollCreate _$result;
    try {
      _$result = _$v ??
          _$RollCreate._(
            kind: kind,
            label: BuiltValueNullFieldError.checkNotNull(
                label, r'RollCreate', 'label'),
            pool: BuiltValueNullFieldError.checkNotNull(
                pool, r'RollCreate', 'pool'),
            gameSessionId: gameSessionId,
            breakdown: _breakdown?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'breakdown';
        _breakdown?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RollCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
