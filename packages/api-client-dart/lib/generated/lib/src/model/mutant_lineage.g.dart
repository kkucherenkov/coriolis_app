// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mutant_lineage.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MutantLineage _$zirba = const MutantLineage._('zirba');
const MutantLineage _$shingura = const MutantLineage._('shingura');
const MutantLineage _$nerida = const MutantLineage._('nerida');

MutantLineage _$valueOf(String name) {
  switch (name) {
    case 'zirba':
      return _$zirba;
    case 'shingura':
      return _$shingura;
    case 'nerida':
      return _$nerida;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MutantLineage> _$values =
    BuiltSet<MutantLineage>(const <MutantLineage>[
  _$zirba,
  _$shingura,
  _$nerida,
]);

class _$MutantLineageMeta {
  const _$MutantLineageMeta();
  MutantLineage get zirba => _$zirba;
  MutantLineage get shingura => _$shingura;
  MutantLineage get nerida => _$nerida;
  MutantLineage valueOf(String name) => _$valueOf(name);
  BuiltSet<MutantLineage> get values => _$values;
}

abstract class _$MutantLineageMixin {
  // ignore: non_constant_identifier_names
  _$MutantLineageMeta get MutantLineage => const _$MutantLineageMeta();
}

Serializer<MutantLineage> _$mutantLineageSerializer =
    _$MutantLineageSerializer();

class _$MutantLineageSerializer implements PrimitiveSerializer<MutantLineage> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'zirba': 'zirba',
    'shingura': 'shingura',
    'nerida': 'nerida',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'zirba': 'zirba',
    'shingura': 'shingura',
    'nerida': 'nerida',
  };

  @override
  final Iterable<Type> types = const <Type>[MutantLineage];
  @override
  final String wireName = 'MutantLineage';

  @override
  Object serialize(Serializers serializers, MutantLineage object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MutantLineage deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MutantLineage.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
