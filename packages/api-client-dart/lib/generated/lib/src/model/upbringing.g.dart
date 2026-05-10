// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upbringing.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const Upbringing _$plebeian = const Upbringing._('plebeian');
const Upbringing _$stationary = const Upbringing._('stationary');
const Upbringing _$aristocrat = const Upbringing._('aristocrat');

Upbringing _$valueOf(String name) {
  switch (name) {
    case 'plebeian':
      return _$plebeian;
    case 'stationary':
      return _$stationary;
    case 'aristocrat':
      return _$aristocrat;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<Upbringing> _$values = BuiltSet<Upbringing>(const <Upbringing>[
  _$plebeian,
  _$stationary,
  _$aristocrat,
]);

class _$UpbringingMeta {
  const _$UpbringingMeta();
  Upbringing get plebeian => _$plebeian;
  Upbringing get stationary => _$stationary;
  Upbringing get aristocrat => _$aristocrat;
  Upbringing valueOf(String name) => _$valueOf(name);
  BuiltSet<Upbringing> get values => _$values;
}

mixin _$UpbringingMixin {
  // ignore: non_constant_identifier_names
  _$UpbringingMeta get Upbringing => const _$UpbringingMeta();
}

Serializer<Upbringing> _$upbringingSerializer = _$UpbringingSerializer();

class _$UpbringingSerializer implements PrimitiveSerializer<Upbringing> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'plebeian': 'plebeian',
    'stationary': 'stationary',
    'aristocrat': 'aristocrat',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'plebeian': 'plebeian',
    'stationary': 'stationary',
    'aristocrat': 'aristocrat',
  };

  @override
  final Iterable<Type> types = const <Type>[Upbringing];
  @override
  final String wireName = 'Upbringing';

  @override
  Object serialize(
    Serializers serializers,
    Upbringing object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  Upbringing deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => Upbringing.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
