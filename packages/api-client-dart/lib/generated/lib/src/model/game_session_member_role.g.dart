// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_member_role.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GameSessionMemberRole _$gm = const GameSessionMemberRole._('gm');
const GameSessionMemberRole _$player = const GameSessionMemberRole._('player');

GameSessionMemberRole _$valueOf(String name) {
  switch (name) {
    case 'gm':
      return _$gm;
    case 'player':
      return _$player;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GameSessionMemberRole> _$values =
    BuiltSet<GameSessionMemberRole>(const <GameSessionMemberRole>[
  _$gm,
  _$player,
]);

class _$GameSessionMemberRoleMeta {
  const _$GameSessionMemberRoleMeta();
  GameSessionMemberRole get gm => _$gm;
  GameSessionMemberRole get player => _$player;
  GameSessionMemberRole valueOf(String name) => _$valueOf(name);
  BuiltSet<GameSessionMemberRole> get values => _$values;
}

abstract class _$GameSessionMemberRoleMixin {
  // ignore: non_constant_identifier_names
  _$GameSessionMemberRoleMeta get GameSessionMemberRole =>
      const _$GameSessionMemberRoleMeta();
}

Serializer<GameSessionMemberRole> _$gameSessionMemberRoleSerializer =
    _$GameSessionMemberRoleSerializer();

class _$GameSessionMemberRoleSerializer
    implements PrimitiveSerializer<GameSessionMemberRole> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'gm': 'gm',
    'player': 'player',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'gm': 'gm',
    'player': 'player',
  };

  @override
  final Iterable<Type> types = const <Type>[GameSessionMemberRole];
  @override
  final String wireName = 'GameSessionMemberRole';

  @override
  Object serialize(Serializers serializers, GameSessionMemberRole object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GameSessionMemberRole deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GameSessionMemberRole.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
