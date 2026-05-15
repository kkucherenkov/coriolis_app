// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dp_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DpEvent extends DpEvent {
  @override
  final String id;
  @override
  final String gameSessionId;
  @override
  final int delta;
  @override
  final String? reason;
  @override
  final DpSource source_;
  @override
  final String? rollId;
  @override
  final DateTime createdAt;

  factory _$DpEvent([void Function(DpEventBuilder)? updates]) =>
      (DpEventBuilder()..update(updates))._build();

  _$DpEvent._(
      {required this.id,
      required this.gameSessionId,
      required this.delta,
      this.reason,
      required this.source_,
      this.rollId,
      required this.createdAt})
      : super._();
  @override
  DpEvent rebuild(void Function(DpEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DpEventBuilder toBuilder() => DpEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DpEvent &&
        id == other.id &&
        gameSessionId == other.gameSessionId &&
        delta == other.delta &&
        reason == other.reason &&
        source_ == other.source_ &&
        rollId == other.rollId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, gameSessionId.hashCode);
    _$hash = $jc(_$hash, delta.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, rollId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DpEvent')
          ..add('id', id)
          ..add('gameSessionId', gameSessionId)
          ..add('delta', delta)
          ..add('reason', reason)
          ..add('source_', source_)
          ..add('rollId', rollId)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class DpEventBuilder implements Builder<DpEvent, DpEventBuilder> {
  _$DpEvent? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _gameSessionId;
  String? get gameSessionId => _$this._gameSessionId;
  set gameSessionId(String? gameSessionId) =>
      _$this._gameSessionId = gameSessionId;

  int? _delta;
  int? get delta => _$this._delta;
  set delta(int? delta) => _$this._delta = delta;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DpSource? _source_;
  DpSource? get source_ => _$this._source_;
  set source_(DpSource? source_) => _$this._source_ = source_;

  String? _rollId;
  String? get rollId => _$this._rollId;
  set rollId(String? rollId) => _$this._rollId = rollId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DpEventBuilder() {
    DpEvent._defaults(this);
  }

  DpEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _gameSessionId = $v.gameSessionId;
      _delta = $v.delta;
      _reason = $v.reason;
      _source_ = $v.source_;
      _rollId = $v.rollId;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DpEvent other) {
    _$v = other as _$DpEvent;
  }

  @override
  void update(void Function(DpEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DpEvent build() => _build();

  _$DpEvent _build() {
    final _$result = _$v ??
        _$DpEvent._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'DpEvent', 'id'),
          gameSessionId: BuiltValueNullFieldError.checkNotNull(
              gameSessionId, r'DpEvent', 'gameSessionId'),
          delta:
              BuiltValueNullFieldError.checkNotNull(delta, r'DpEvent', 'delta'),
          reason: reason,
          source_: BuiltValueNullFieldError.checkNotNull(
              source_, r'DpEvent', 'source_'),
          rollId: rollId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'DpEvent', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
