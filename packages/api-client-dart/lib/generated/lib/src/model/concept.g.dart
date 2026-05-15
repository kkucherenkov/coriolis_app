// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concept.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const Concept _$artist = const Concept._('artist');
const Concept _$networker = const Concept._('networker');
const Concept _$fugitive = const Concept._('fugitive');
const Concept _$negotiator = const Concept._('negotiator');
const Concept _$operative = const Concept._('operative');
const Concept _$pilot = const Concept._('pilot');
const Concept _$pioneer = const Concept._('pioneer');
const Concept _$preacher = const Concept._('preacher');
const Concept _$scientist = const Concept._('scientist');
const Concept _$sailor = const Concept._('sailor');
const Concept _$soldier = const Concept._('soldier');

Concept _$valueOf(String name) {
  switch (name) {
    case 'artist':
      return _$artist;
    case 'networker':
      return _$networker;
    case 'fugitive':
      return _$fugitive;
    case 'negotiator':
      return _$negotiator;
    case 'operative':
      return _$operative;
    case 'pilot':
      return _$pilot;
    case 'pioneer':
      return _$pioneer;
    case 'preacher':
      return _$preacher;
    case 'scientist':
      return _$scientist;
    case 'sailor':
      return _$sailor;
    case 'soldier':
      return _$soldier;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<Concept> _$values = BuiltSet<Concept>(const <Concept>[
  _$artist,
  _$networker,
  _$fugitive,
  _$negotiator,
  _$operative,
  _$pilot,
  _$pioneer,
  _$preacher,
  _$scientist,
  _$sailor,
  _$soldier,
]);

class _$ConceptMeta {
  const _$ConceptMeta();
  Concept get artist => _$artist;
  Concept get networker => _$networker;
  Concept get fugitive => _$fugitive;
  Concept get negotiator => _$negotiator;
  Concept get operative => _$operative;
  Concept get pilot => _$pilot;
  Concept get pioneer => _$pioneer;
  Concept get preacher => _$preacher;
  Concept get scientist => _$scientist;
  Concept get sailor => _$sailor;
  Concept get soldier => _$soldier;
  Concept valueOf(String name) => _$valueOf(name);
  BuiltSet<Concept> get values => _$values;
}

abstract class _$ConceptMixin {
  // ignore: non_constant_identifier_names
  _$ConceptMeta get Concept => const _$ConceptMeta();
}

Serializer<Concept> _$conceptSerializer = _$ConceptSerializer();

class _$ConceptSerializer implements PrimitiveSerializer<Concept> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'artist': 'artist',
    'networker': 'networker',
    'fugitive': 'fugitive',
    'negotiator': 'negotiator',
    'operative': 'operative',
    'pilot': 'pilot',
    'pioneer': 'pioneer',
    'preacher': 'preacher',
    'scientist': 'scientist',
    'sailor': 'sailor',
    'soldier': 'soldier',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'artist': 'artist',
    'networker': 'networker',
    'fugitive': 'fugitive',
    'negotiator': 'negotiator',
    'operative': 'operative',
    'pilot': 'pilot',
    'pioneer': 'pioneer',
    'preacher': 'preacher',
    'scientist': 'scientist',
    'sailor': 'sailor',
    'soldier': 'soldier',
  };

  @override
  final Iterable<Type> types = const <Type>[Concept];
  @override
  final String wireName = 'Concept';

  @override
  Object serialize(Serializers serializers, Concept object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  Concept deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      Concept.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
