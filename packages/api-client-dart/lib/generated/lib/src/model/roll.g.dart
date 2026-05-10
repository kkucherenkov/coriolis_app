// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roll.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Roll extends Roll {
  @override
  final String id;
  @override
  final String characterId;
  @override
  final String? gameSessionId;
  @override
  final String label;
  @override
  final int pool;
  @override
  final BuiltList<int> dice;
  @override
  final int hits;
  @override
  final bool pushed;
  @override
  final DateTime createdAt;

  factory _$Roll([void Function(RollBuilder)? updates]) =>
      (RollBuilder()..update(updates))._build();

  _$Roll._({
    required this.id,
    required this.characterId,
    this.gameSessionId,
    required this.label,
    required this.pool,
    required this.dice,
    required this.hits,
    required this.pushed,
    required this.createdAt,
  }) : super._();
  @override
  Roll rebuild(void Function(RollBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RollBuilder toBuilder() => RollBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Roll &&
        id == other.id &&
        characterId == other.characterId &&
        gameSessionId == other.gameSessionId &&
        label == other.label &&
        pool == other.pool &&
        dice == other.dice &&
        hits == other.hits &&
        pushed == other.pushed &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, characterId.hashCode);
    _$hash = $jc(_$hash, gameSessionId.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, pool.hashCode);
    _$hash = $jc(_$hash, dice.hashCode);
    _$hash = $jc(_$hash, hits.hashCode);
    _$hash = $jc(_$hash, pushed.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Roll')
          ..add('id', id)
          ..add('characterId', characterId)
          ..add('gameSessionId', gameSessionId)
          ..add('label', label)
          ..add('pool', pool)
          ..add('dice', dice)
          ..add('hits', hits)
          ..add('pushed', pushed)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class RollBuilder implements Builder<Roll, RollBuilder> {
  _$Roll? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _characterId;
  String? get characterId => _$this._characterId;
  set characterId(String? characterId) => _$this._characterId = characterId;

  String? _gameSessionId;
  String? get gameSessionId => _$this._gameSessionId;
  set gameSessionId(String? gameSessionId) =>
      _$this._gameSessionId = gameSessionId;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  int? _pool;
  int? get pool => _$this._pool;
  set pool(int? pool) => _$this._pool = pool;

  ListBuilder<int>? _dice;
  ListBuilder<int> get dice => _$this._dice ??= ListBuilder<int>();
  set dice(ListBuilder<int>? dice) => _$this._dice = dice;

  int? _hits;
  int? get hits => _$this._hits;
  set hits(int? hits) => _$this._hits = hits;

  bool? _pushed;
  bool? get pushed => _$this._pushed;
  set pushed(bool? pushed) => _$this._pushed = pushed;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  RollBuilder() {
    Roll._defaults(this);
  }

  RollBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _characterId = $v.characterId;
      _gameSessionId = $v.gameSessionId;
      _label = $v.label;
      _pool = $v.pool;
      _dice = $v.dice.toBuilder();
      _hits = $v.hits;
      _pushed = $v.pushed;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Roll other) {
    _$v = other as _$Roll;
  }

  @override
  void update(void Function(RollBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Roll build() => _build();

  _$Roll _build() {
    _$Roll _$result;
    try {
      _$result =
          _$v ??
          _$Roll._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Roll', 'id'),
            characterId: BuiltValueNullFieldError.checkNotNull(
              characterId,
              r'Roll',
              'characterId',
            ),
            gameSessionId: gameSessionId,
            label: BuiltValueNullFieldError.checkNotNull(
              label,
              r'Roll',
              'label',
            ),
            pool: BuiltValueNullFieldError.checkNotNull(pool, r'Roll', 'pool'),
            dice: dice.build(),
            hits: BuiltValueNullFieldError.checkNotNull(hits, r'Roll', 'hits'),
            pushed: BuiltValueNullFieldError.checkNotNull(
              pushed,
              r'Roll',
              'pushed',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'Roll',
              'createdAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dice';
        dice.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Roll', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
