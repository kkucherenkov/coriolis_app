// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combatant_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CombatantType _$pc = const CombatantType._('pc');
const CombatantType _$npc = const CombatantType._('npc');

CombatantType _$valueOf(String name) {
  switch (name) {
    case 'pc':
      return _$pc;
    case 'npc':
      return _$npc;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CombatantType> _$values =
    BuiltSet<CombatantType>(const <CombatantType>[
  _$pc,
  _$npc,
]);

class _$CombatantTypeMeta {
  const _$CombatantTypeMeta();
  CombatantType get pc => _$pc;
  CombatantType get npc => _$npc;
  CombatantType valueOf(String name) => _$valueOf(name);
  BuiltSet<CombatantType> get values => _$values;
}

abstract class _$CombatantTypeMixin {
  // ignore: non_constant_identifier_names
  _$CombatantTypeMeta get CombatantType => const _$CombatantTypeMeta();
}

Serializer<CombatantType> _$combatantTypeSerializer =
    _$CombatantTypeSerializer();

class _$CombatantTypeSerializer implements PrimitiveSerializer<CombatantType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pc': 'pc',
    'npc': 'npc',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pc': 'pc',
    'npc': 'npc',
  };

  @override
  final Iterable<Type> types = const <Type>[CombatantType];
  @override
  final String wireName = 'CombatantType';

  @override
  Object serialize(Serializers serializers, CombatantType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CombatantType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CombatantType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
