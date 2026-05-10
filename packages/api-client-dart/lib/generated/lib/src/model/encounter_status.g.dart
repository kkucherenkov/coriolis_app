// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encounter_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EncounterStatus _$setup = const EncounterStatus._('setup');
const EncounterStatus _$active = const EncounterStatus._('active');
const EncounterStatus _$ended = const EncounterStatus._('ended');

EncounterStatus _$valueOf(String name) {
  switch (name) {
    case 'setup':
      return _$setup;
    case 'active':
      return _$active;
    case 'ended':
      return _$ended;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EncounterStatus> _$values = BuiltSet<EncounterStatus>(
  const <EncounterStatus>[_$setup, _$active, _$ended],
);

class _$EncounterStatusMeta {
  const _$EncounterStatusMeta();
  EncounterStatus get setup => _$setup;
  EncounterStatus get active => _$active;
  EncounterStatus get ended => _$ended;
  EncounterStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<EncounterStatus> get values => _$values;
}

mixin _$EncounterStatusMixin {
  // ignore: non_constant_identifier_names
  _$EncounterStatusMeta get EncounterStatus => const _$EncounterStatusMeta();
}

Serializer<EncounterStatus> _$encounterStatusSerializer =
    _$EncounterStatusSerializer();

class _$EncounterStatusSerializer
    implements PrimitiveSerializer<EncounterStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'setup': 'setup',
    'active': 'active',
    'ended': 'ended',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'setup': 'setup',
    'active': 'active',
    'ended': 'ended',
  };

  @override
  final Iterable<Type> types = const <Type>[EncounterStatus];
  @override
  final String wireName = 'EncounterStatus';

  @override
  Object serialize(
    Serializers serializers,
    EncounterStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  EncounterStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => EncounterStatus.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
