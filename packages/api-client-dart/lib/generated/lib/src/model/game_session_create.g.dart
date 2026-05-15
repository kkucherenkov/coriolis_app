// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GameSessionCreate extends GameSessionCreate {
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? shipId;

  factory _$GameSessionCreate(
          [void Function(GameSessionCreateBuilder)? updates]) =>
      (GameSessionCreateBuilder()..update(updates))._build();

  _$GameSessionCreate._({required this.name, this.description, this.shipId})
      : super._();
  @override
  GameSessionCreate rebuild(void Function(GameSessionCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GameSessionCreateBuilder toBuilder() =>
      GameSessionCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GameSessionCreate &&
        name == other.name &&
        description == other.description &&
        shipId == other.shipId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, shipId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GameSessionCreate')
          ..add('name', name)
          ..add('description', description)
          ..add('shipId', shipId))
        .toString();
  }
}

class GameSessionCreateBuilder
    implements Builder<GameSessionCreate, GameSessionCreateBuilder> {
  _$GameSessionCreate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _shipId;
  String? get shipId => _$this._shipId;
  set shipId(String? shipId) => _$this._shipId = shipId;

  GameSessionCreateBuilder() {
    GameSessionCreate._defaults(this);
  }

  GameSessionCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _shipId = $v.shipId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GameSessionCreate other) {
    _$v = other as _$GameSessionCreate;
  }

  @override
  void update(void Function(GameSessionCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GameSessionCreate build() => _build();

  _$GameSessionCreate _build() {
    final _$result = _$v ??
        _$GameSessionCreate._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GameSessionCreate', 'name'),
          description: description,
          shipId: shipId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
