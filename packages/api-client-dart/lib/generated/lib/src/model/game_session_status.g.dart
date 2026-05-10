// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GameSessionStatus _$active = const GameSessionStatus._('active');
const GameSessionStatus _$archived = const GameSessionStatus._('archived');

GameSessionStatus _$valueOf(String name) {
  switch (name) {
    case 'active':
      return _$active;
    case 'archived':
      return _$archived;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GameSessionStatus> _$values =
    new BuiltSet<GameSessionStatus>(const <GameSessionStatus>[
  _$active,
  _$archived,
]);

class _$GameSessionStatusMeta {
  const _$GameSessionStatusMeta();
  GameSessionStatus get active => _$active;
  GameSessionStatus get archived => _$archived;
  GameSessionStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<GameSessionStatus> get values => _$values;
}

abstract class _$GameSessionStatusMixin {
  // ignore: non_constant_identifier_names
  _$GameSessionStatusMeta get GameSessionStatus =>
      const _$GameSessionStatusMeta();
}

Serializer<GameSessionStatus> _$gameSessionStatusSerializer =
    new _$GameSessionStatusSerializer();

class _$GameSessionStatusSerializer
    implements PrimitiveSerializer<GameSessionStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'archived': 'archived',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'archived': 'archived',
  };

  @override
  final Iterable<Type> types = const <Type>[GameSessionStatus];
  @override
  final String wireName = 'GameSessionStatus';

  @override
  Object serialize(Serializers serializers, GameSessionStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GameSessionStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GameSessionStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
