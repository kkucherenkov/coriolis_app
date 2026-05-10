// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talent_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TalentKind _$personal = const TalentKind._('personal');
const TalentKind _$crew = const TalentKind._('crew');
const TalentKind _$iconGift = const TalentKind._('iconGift');
const TalentKind _$stigma = const TalentKind._('stigma');

TalentKind _$valueOf(String name) {
  switch (name) {
    case 'personal':
      return _$personal;
    case 'crew':
      return _$crew;
    case 'iconGift':
      return _$iconGift;
    case 'stigma':
      return _$stigma;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<TalentKind> _$values =
    new BuiltSet<TalentKind>(const <TalentKind>[
  _$personal,
  _$crew,
  _$iconGift,
  _$stigma,
]);

class _$TalentKindMeta {
  const _$TalentKindMeta();
  TalentKind get personal => _$personal;
  TalentKind get crew => _$crew;
  TalentKind get iconGift => _$iconGift;
  TalentKind get stigma => _$stigma;
  TalentKind valueOf(String name) => _$valueOf(name);
  BuiltSet<TalentKind> get values => _$values;
}

abstract class _$TalentKindMixin {
  // ignore: non_constant_identifier_names
  _$TalentKindMeta get TalentKind => const _$TalentKindMeta();
}

Serializer<TalentKind> _$talentKindSerializer = new _$TalentKindSerializer();

class _$TalentKindSerializer implements PrimitiveSerializer<TalentKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'personal': 'personal',
    'crew': 'crew',
    'iconGift': 'iconGift',
    'stigma': 'stigma',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'personal': 'personal',
    'crew': 'crew',
    'iconGift': 'iconGift',
    'stigma': 'stigma',
  };

  @override
  final Iterable<Type> types = const <Type>[TalentKind];
  @override
  final String wireName = 'TalentKind';

  @override
  Object serialize(Serializers serializers, TalentKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TalentKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TalentKind.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
