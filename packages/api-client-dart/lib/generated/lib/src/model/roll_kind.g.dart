// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roll_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RollKind _$skill = const RollKind._('skill');
const RollKind _$save = const RollKind._('save');
const RollKind _$trauma = const RollKind._('trauma');
const RollKind _$initiative = const RollKind._('initiative');
const RollKind _$darkness = const RollKind._('darkness');

RollKind _$valueOf(String name) {
  switch (name) {
    case 'skill':
      return _$skill;
    case 'save':
      return _$save;
    case 'trauma':
      return _$trauma;
    case 'initiative':
      return _$initiative;
    case 'darkness':
      return _$darkness;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RollKind> _$values = BuiltSet<RollKind>(const <RollKind>[
  _$skill,
  _$save,
  _$trauma,
  _$initiative,
  _$darkness,
]);

class _$RollKindMeta {
  const _$RollKindMeta();
  RollKind get skill => _$skill;
  RollKind get save => _$save;
  RollKind get trauma => _$trauma;
  RollKind get initiative => _$initiative;
  RollKind get darkness => _$darkness;
  RollKind valueOf(String name) => _$valueOf(name);
  BuiltSet<RollKind> get values => _$values;
}

abstract class _$RollKindMixin {
  // ignore: non_constant_identifier_names
  _$RollKindMeta get RollKind => const _$RollKindMeta();
}

Serializer<RollKind> _$rollKindSerializer = _$RollKindSerializer();

class _$RollKindSerializer implements PrimitiveSerializer<RollKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'skill': 'skill',
    'save': 'save',
    'trauma': 'trauma',
    'initiative': 'initiative',
    'darkness': 'darkness',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'skill': 'skill',
    'save': 'save',
    'trauma': 'trauma',
    'initiative': 'initiative',
    'darkness': 'darkness',
  };

  @override
  final Iterable<Type> types = const <Type>[RollKind];
  @override
  final String wireName = 'RollKind';

  @override
  Object serialize(Serializers serializers, RollKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RollKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RollKind.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
