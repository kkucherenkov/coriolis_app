//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/relationship_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'relationship.g.dart';

/// A relationship between a character and another person (NPC or PC)
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [targetName] - Name of the NPC or PC (free text)
/// * [kind] 
/// * [notes] - Optional notes about the relationship
@BuiltValue()
abstract class Relationship implements Built<Relationship, RelationshipBuilder> {
  /// Opaque identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Name of the NPC or PC (free text)
  @BuiltValueField(wireName: r'targetName')
  String get targetName;

  @BuiltValueField(wireName: r'kind')
  RelationshipKind get kind;
  // enum kindEnum {  ally,  rival,  family,  mentor,  debtor,  creditor,  };

  /// Optional notes about the relationship
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  Relationship._();

  factory Relationship([void updates(RelationshipBuilder b)]) = _$Relationship;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RelationshipBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Relationship> get serializer => _$RelationshipSerializer();
}

class _$RelationshipSerializer implements PrimitiveSerializer<Relationship> {
  @override
  final Iterable<Type> types = const [Relationship, _$Relationship];

  @override
  final String wireName = r'Relationship';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Relationship object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'targetName';
    yield serializers.serialize(
      object.targetName,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(RelationshipKind),
    );
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Relationship object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RelationshipBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'targetName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetName = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RelationshipKind),
          ) as RelationshipKind;
          result.kind = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Relationship deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RelationshipBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

