// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icon_id.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IconId _$ladyOfTears = const IconId._('ladyOfTears');
const IconId _$traveler = const IconId._('traveler');
const IconId _$messenger = const IconId._('messenger');
const IconId _$merchant = const IconId._('merchant');
const IconId _$dancer = const IconId._('dancer');
const IconId _$gambler = const IconId._('gambler');
const IconId _$judge = const IconId._('judge');
const IconId _$facelessOne = const IconId._('facelessOne');
const IconId _$deckhand = const IconId._('deckhand');

IconId _$valueOf(String name) {
  switch (name) {
    case 'ladyOfTears':
      return _$ladyOfTears;
    case 'traveler':
      return _$traveler;
    case 'messenger':
      return _$messenger;
    case 'merchant':
      return _$merchant;
    case 'dancer':
      return _$dancer;
    case 'gambler':
      return _$gambler;
    case 'judge':
      return _$judge;
    case 'facelessOne':
      return _$facelessOne;
    case 'deckhand':
      return _$deckhand;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IconId> _$values = BuiltSet<IconId>(const <IconId>[
  _$ladyOfTears,
  _$traveler,
  _$messenger,
  _$merchant,
  _$dancer,
  _$gambler,
  _$judge,
  _$facelessOne,
  _$deckhand,
]);

class _$IconIdMeta {
  const _$IconIdMeta();
  IconId get ladyOfTears => _$ladyOfTears;
  IconId get traveler => _$traveler;
  IconId get messenger => _$messenger;
  IconId get merchant => _$merchant;
  IconId get dancer => _$dancer;
  IconId get gambler => _$gambler;
  IconId get judge => _$judge;
  IconId get facelessOne => _$facelessOne;
  IconId get deckhand => _$deckhand;
  IconId valueOf(String name) => _$valueOf(name);
  BuiltSet<IconId> get values => _$values;
}

abstract class _$IconIdMixin {
  // ignore: non_constant_identifier_names
  _$IconIdMeta get IconId => const _$IconIdMeta();
}

Serializer<IconId> _$iconIdSerializer = _$IconIdSerializer();

class _$IconIdSerializer implements PrimitiveSerializer<IconId> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ladyOfTears': 'lady-of-tears',
    'traveler': 'traveler',
    'messenger': 'messenger',
    'merchant': 'merchant',
    'dancer': 'dancer',
    'gambler': 'gambler',
    'judge': 'judge',
    'facelessOne': 'faceless-one',
    'deckhand': 'deckhand',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'lady-of-tears': 'ladyOfTears',
    'traveler': 'traveler',
    'messenger': 'messenger',
    'merchant': 'merchant',
    'dancer': 'dancer',
    'gambler': 'gambler',
    'judge': 'judge',
    'faceless-one': 'facelessOne',
    'deckhand': 'deckhand',
  };

  @override
  final Iterable<Type> types = const <Type>[IconId];
  @override
  final String wireName = 'IconId';

  @override
  Object serialize(Serializers serializers, IconId object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IconId deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IconId.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
