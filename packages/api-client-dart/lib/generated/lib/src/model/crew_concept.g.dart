// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crew_concept.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CrewConcept _$freeTrader = const CrewConcept._('freeTrader');
const CrewConcept _$mercenary = const CrewConcept._('mercenary');
const CrewConcept _$explorer = const CrewConcept._('explorer');
const CrewConcept _$agents = const CrewConcept._('agents');
const CrewConcept _$pilgrim = const CrewConcept._('pilgrim');

CrewConcept _$valueOf(String name) {
  switch (name) {
    case 'freeTrader':
      return _$freeTrader;
    case 'mercenary':
      return _$mercenary;
    case 'explorer':
      return _$explorer;
    case 'agents':
      return _$agents;
    case 'pilgrim':
      return _$pilgrim;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<CrewConcept> _$values =
    new BuiltSet<CrewConcept>(const <CrewConcept>[
  _$freeTrader,
  _$mercenary,
  _$explorer,
  _$agents,
  _$pilgrim,
]);

class _$CrewConceptMeta {
  const _$CrewConceptMeta();
  CrewConcept get freeTrader => _$freeTrader;
  CrewConcept get mercenary => _$mercenary;
  CrewConcept get explorer => _$explorer;
  CrewConcept get agents => _$agents;
  CrewConcept get pilgrim => _$pilgrim;
  CrewConcept valueOf(String name) => _$valueOf(name);
  BuiltSet<CrewConcept> get values => _$values;
}

abstract class _$CrewConceptMixin {
  // ignore: non_constant_identifier_names
  _$CrewConceptMeta get CrewConcept => const _$CrewConceptMeta();
}

Serializer<CrewConcept> _$crewConceptSerializer = new _$CrewConceptSerializer();

class _$CrewConceptSerializer implements PrimitiveSerializer<CrewConcept> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'freeTrader': 'free-trader',
    'mercenary': 'mercenary',
    'explorer': 'explorer',
    'agents': 'agents',
    'pilgrim': 'pilgrim',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'free-trader': 'freeTrader',
    'mercenary': 'mercenary',
    'explorer': 'explorer',
    'agents': 'agents',
    'pilgrim': 'pilgrim',
  };

  @override
  final Iterable<Type> types = const <Type>[CrewConcept];
  @override
  final String wireName = 'CrewConcept';

  @override
  Object serialize(Serializers serializers, CrewConcept object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CrewConcept deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CrewConcept.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
