// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dp_source.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DpSource _$gmManual = const DpSource._('gmManual');
const DpSource _$rollPush = const DpSource._('rollPush');
const DpSource _$system = const DpSource._('system');

DpSource _$valueOf(String name) {
  switch (name) {
    case 'gmManual':
      return _$gmManual;
    case 'rollPush':
      return _$rollPush;
    case 'system':
      return _$system;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DpSource> _$values = BuiltSet<DpSource>(const <DpSource>[
  _$gmManual,
  _$rollPush,
  _$system,
]);

class _$DpSourceMeta {
  const _$DpSourceMeta();
  DpSource get gmManual => _$gmManual;
  DpSource get rollPush => _$rollPush;
  DpSource get system => _$system;
  DpSource valueOf(String name) => _$valueOf(name);
  BuiltSet<DpSource> get values => _$values;
}

mixin _$DpSourceMixin {
  // ignore: non_constant_identifier_names
  _$DpSourceMeta get DpSource => const _$DpSourceMeta();
}

Serializer<DpSource> _$dpSourceSerializer = _$DpSourceSerializer();

class _$DpSourceSerializer implements PrimitiveSerializer<DpSource> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'gmManual': 'gm-manual',
    'rollPush': 'roll-push',
    'system': 'system',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'gm-manual': 'gmManual',
    'roll-push': 'rollPush',
    'system': 'system',
  };

  @override
  final Iterable<Type> types = const <Type>[DpSource];
  @override
  final String wireName = 'DpSource';

  @override
  Object serialize(
    Serializers serializers,
    DpSource object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DpSource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DpSource.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
