// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GameSessionUpdate extends GameSessionUpdate {
  @override
  final String? name;
  @override
  final String? description;
  @override
  final GameSessionStatus? status;
  @override
  final String? shipId;

  factory _$GameSessionUpdate(
          [void Function(GameSessionUpdateBuilder)? updates]) =>
      (new GameSessionUpdateBuilder()..update(updates))._build();

  _$GameSessionUpdate._({this.name, this.description, this.status, this.shipId})
      : super._();

  @override
  GameSessionUpdate rebuild(void Function(GameSessionUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GameSessionUpdateBuilder toBuilder() =>
      new GameSessionUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GameSessionUpdate &&
        name == other.name &&
        description == other.description &&
        status == other.status &&
        shipId == other.shipId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, shipId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GameSessionUpdate')
          ..add('name', name)
          ..add('description', description)
          ..add('status', status)
          ..add('shipId', shipId))
        .toString();
  }
}

class GameSessionUpdateBuilder
    implements Builder<GameSessionUpdate, GameSessionUpdateBuilder> {
  _$GameSessionUpdate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  GameSessionStatus? _status;
  GameSessionStatus? get status => _$this._status;
  set status(GameSessionStatus? status) => _$this._status = status;

  String? _shipId;
  String? get shipId => _$this._shipId;
  set shipId(String? shipId) => _$this._shipId = shipId;

  GameSessionUpdateBuilder() {
    GameSessionUpdate._defaults(this);
  }

  GameSessionUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _status = $v.status;
      _shipId = $v.shipId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GameSessionUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GameSessionUpdate;
  }

  @override
  void update(void Function(GameSessionUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GameSessionUpdate build() => _build();

  _$GameSessionUpdate _build() {
    final _$result = _$v ??
        new _$GameSessionUpdate._(
            name: name,
            description: description,
            status: status,
            shipId: shipId);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
