// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'critical_injury_severity.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CriticalInjurySeverity _$light = const CriticalInjurySeverity._('light');
const CriticalInjurySeverity _$severe =
    const CriticalInjurySeverity._('severe');
const CriticalInjurySeverity _$critical =
    const CriticalInjurySeverity._('critical');

CriticalInjurySeverity _$valueOf(String name) {
  switch (name) {
    case 'light':
      return _$light;
    case 'severe':
      return _$severe;
    case 'critical':
      return _$critical;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<CriticalInjurySeverity> _$values =
    new BuiltSet<CriticalInjurySeverity>(const <CriticalInjurySeverity>[
  _$light,
  _$severe,
  _$critical,
]);

class _$CriticalInjurySeverityMeta {
  const _$CriticalInjurySeverityMeta();
  CriticalInjurySeverity get light => _$light;
  CriticalInjurySeverity get severe => _$severe;
  CriticalInjurySeverity get critical => _$critical;
  CriticalInjurySeverity valueOf(String name) => _$valueOf(name);
  BuiltSet<CriticalInjurySeverity> get values => _$values;
}

abstract class _$CriticalInjurySeverityMixin {
  // ignore: non_constant_identifier_names
  _$CriticalInjurySeverityMeta get CriticalInjurySeverity =>
      const _$CriticalInjurySeverityMeta();
}

Serializer<CriticalInjurySeverity> _$criticalInjurySeveritySerializer =
    new _$CriticalInjurySeveritySerializer();

class _$CriticalInjurySeveritySerializer
    implements PrimitiveSerializer<CriticalInjurySeverity> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'light': 'light',
    'severe': 'severe',
    'critical': 'critical',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'light': 'light',
    'severe': 'severe',
    'critical': 'critical',
  };

  @override
  final Iterable<Type> types = const <Type>[CriticalInjurySeverity];
  @override
  final String wireName = 'CriticalInjurySeverity';

  @override
  Object serialize(Serializers serializers, CriticalInjurySeverity object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CriticalInjurySeverity deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CriticalInjurySeverity.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
