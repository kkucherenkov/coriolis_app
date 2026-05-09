//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'assign_character_to_session.g.dart';

/// AssignCharacterToSession
///
/// Properties:
/// * [characterId] - Identifier of the character to assign
@BuiltValue()
abstract class AssignCharacterToSession implements Built<AssignCharacterToSession, AssignCharacterToSessionBuilder> {
  /// Identifier of the character to assign
  @BuiltValueField(wireName: r'characterId')
  String get characterId;

  AssignCharacterToSession._();

  factory AssignCharacterToSession([void updates(AssignCharacterToSessionBuilder b)]) = _$AssignCharacterToSession;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AssignCharacterToSessionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AssignCharacterToSession> get serializer => _$AssignCharacterToSessionSerializer();
}

class _$AssignCharacterToSessionSerializer implements PrimitiveSerializer<AssignCharacterToSession> {
  @override
  final Iterable<Type> types = const [AssignCharacterToSession, _$AssignCharacterToSession];

  @override
  final String wireName = r'AssignCharacterToSession';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AssignCharacterToSession object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'characterId';
    yield serializers.serialize(
      object.characterId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AssignCharacterToSession object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AssignCharacterToSessionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'characterId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.characterId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AssignCharacterToSession deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AssignCharacterToSessionBuilder();
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

