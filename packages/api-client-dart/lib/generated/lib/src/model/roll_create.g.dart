// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roll_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RollCreate extends RollCreate {
  @override
  final String label;
  @override
  final int pool;
  @override
  final String? gameSessionId;

  factory _$RollCreate([void Function(RollCreateBuilder)? updates]) =>
      (new RollCreateBuilder()..update(updates))._build();

  _$RollCreate._({required this.label, required this.pool, this.gameSessionId})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(label, r'RollCreate', 'label');
    BuiltValueNullFieldError.checkNotNull(pool, r'RollCreate', 'pool');
  }

  @override
  RollCreate rebuild(void Function(RollCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RollCreateBuilder toBuilder() => new RollCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RollCreate &&
        label == other.label &&
        pool == other.pool &&
        gameSessionId == other.gameSessionId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, pool.hashCode);
    _$hash = $jc(_$hash, gameSessionId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RollCreate')
          ..add('label', label)
          ..add('pool', pool)
          ..add('gameSessionId', gameSessionId))
        .toString();
  }
}

class RollCreateBuilder implements Builder<RollCreate, RollCreateBuilder> {
  _$RollCreate? _$v;

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

  RollCreateBuilder() {
    RollCreate._defaults(this);
  }

  RollCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _label = $v.label;
      _pool = $v.pool;
      _gameSessionId = $v.gameSessionId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RollCreate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$RollCreate;
  }

  @override
  void update(void Function(RollCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RollCreate build() => _build();

  _$RollCreate _build() {
    final _$result = _$v ??
        new _$RollCreate._(
            label: BuiltValueNullFieldError.checkNotNull(
                label, r'RollCreate', 'label'),
            pool: BuiltValueNullFieldError.checkNotNull(
                pool, r'RollCreate', 'pool'),
            gameSessionId: gameSessionId);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
