// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RelationshipKind _$ally = const RelationshipKind._('ally');
const RelationshipKind _$rival = const RelationshipKind._('rival');
const RelationshipKind _$family = const RelationshipKind._('family');
const RelationshipKind _$mentor = const RelationshipKind._('mentor');
const RelationshipKind _$debtor = const RelationshipKind._('debtor');
const RelationshipKind _$creditor = const RelationshipKind._('creditor');

RelationshipKind _$valueOf(String name) {
  switch (name) {
    case 'ally':
      return _$ally;
    case 'rival':
      return _$rival;
    case 'family':
      return _$family;
    case 'mentor':
      return _$mentor;
    case 'debtor':
      return _$debtor;
    case 'creditor':
      return _$creditor;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RelationshipKind> _$values =
    BuiltSet<RelationshipKind>(const <RelationshipKind>[
  _$ally,
  _$rival,
  _$family,
  _$mentor,
  _$debtor,
  _$creditor,
]);

class _$RelationshipKindMeta {
  const _$RelationshipKindMeta();
  RelationshipKind get ally => _$ally;
  RelationshipKind get rival => _$rival;
  RelationshipKind get family => _$family;
  RelationshipKind get mentor => _$mentor;
  RelationshipKind get debtor => _$debtor;
  RelationshipKind get creditor => _$creditor;
  RelationshipKind valueOf(String name) => _$valueOf(name);
  BuiltSet<RelationshipKind> get values => _$values;
}

abstract class _$RelationshipKindMixin {
  // ignore: non_constant_identifier_names
  _$RelationshipKindMeta get RelationshipKind => const _$RelationshipKindMeta();
}

Serializer<RelationshipKind> _$relationshipKindSerializer =
    _$RelationshipKindSerializer();

class _$RelationshipKindSerializer
    implements PrimitiveSerializer<RelationshipKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ally': 'ally',
    'rival': 'rival',
    'family': 'family',
    'mentor': 'mentor',
    'debtor': 'debtor',
    'creditor': 'creditor',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ally': 'ally',
    'rival': 'rival',
    'family': 'family',
    'mentor': 'mentor',
    'debtor': 'debtor',
    'creditor': 'creditor',
  };

  @override
  final Iterable<Type> types = const <Type>[RelationshipKind];
  @override
  final String wireName = 'RelationshipKind';

  @override
  Object serialize(Serializers serializers, RelationshipKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RelationshipKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RelationshipKind.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
