// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crew_position.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CrewPosition _$captain = const CrewPosition._('captain');
const CrewPosition _$pilot = const CrewPosition._('pilot');
const CrewPosition _$sensorOp = const CrewPosition._('sensorOp');
const CrewPosition _$gunner = const CrewPosition._('gunner');
const CrewPosition _$engineer = const CrewPosition._('engineer');
const CrewPosition _$serviceCrew = const CrewPosition._('serviceCrew');

CrewPosition _$valueOf(String name) {
  switch (name) {
    case 'captain':
      return _$captain;
    case 'pilot':
      return _$pilot;
    case 'sensorOp':
      return _$sensorOp;
    case 'gunner':
      return _$gunner;
    case 'engineer':
      return _$engineer;
    case 'serviceCrew':
      return _$serviceCrew;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<CrewPosition> _$values =
    new BuiltSet<CrewPosition>(const <CrewPosition>[
  _$captain,
  _$pilot,
  _$sensorOp,
  _$gunner,
  _$engineer,
  _$serviceCrew,
]);

class _$CrewPositionMeta {
  const _$CrewPositionMeta();
  CrewPosition get captain => _$captain;
  CrewPosition get pilot => _$pilot;
  CrewPosition get sensorOp => _$sensorOp;
  CrewPosition get gunner => _$gunner;
  CrewPosition get engineer => _$engineer;
  CrewPosition get serviceCrew => _$serviceCrew;
  CrewPosition valueOf(String name) => _$valueOf(name);
  BuiltSet<CrewPosition> get values => _$values;
}

abstract class _$CrewPositionMixin {
  // ignore: non_constant_identifier_names
  _$CrewPositionMeta get CrewPosition => const _$CrewPositionMeta();
}

Serializer<CrewPosition> _$crewPositionSerializer =
    new _$CrewPositionSerializer();

class _$CrewPositionSerializer implements PrimitiveSerializer<CrewPosition> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'captain': 'captain',
    'pilot': 'pilot',
    'sensorOp': 'sensorOp',
    'gunner': 'gunner',
    'engineer': 'engineer',
    'serviceCrew': 'serviceCrew',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'captain': 'captain',
    'pilot': 'pilot',
    'sensorOp': 'sensorOp',
    'gunner': 'gunner',
    'engineer': 'engineer',
    'serviceCrew': 'serviceCrew',
  };

  @override
  final Iterable<Type> types = const <Type>[CrewPosition];
  @override
  final String wireName = 'CrewPosition';

  @override
  Object serialize(Serializers serializers, CrewPosition object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CrewPosition deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CrewPosition.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
