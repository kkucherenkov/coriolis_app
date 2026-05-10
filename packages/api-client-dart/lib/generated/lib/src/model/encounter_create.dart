//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'encounter_create.g.dart';

/// Payload for `POST /api/v1/game-sessions/{sessionId}/encounters`. Only `name` is required. The server seeds `status: setup`, `round: 0`, and `activeCombatantId: null`. 
///
/// Properties:
/// * [name] - Short descriptive name for the encounter (1–80 characters)
/// * [notes] - Optional GM notes in Markdown (max 4096 characters)
@BuiltValue()
abstract class EncounterCreate implements Built<EncounterCreate, EncounterCreateBuilder> {
  /// Short descriptive name for the encounter (1–80 characters)
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Optional GM notes in Markdown (max 4096 characters)
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  EncounterCreate._();

  factory EncounterCreate([void updates(EncounterCreateBuilder b)]) = _$EncounterCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EncounterCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EncounterCreate> get serializer => _$EncounterCreateSerializer();
}

class _$EncounterCreateSerializer implements PrimitiveSerializer<EncounterCreate> {
  @override
  final Iterable<Type> types = const [EncounterCreate, _$EncounterCreate];

  @override
  final String wireName = r'EncounterCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EncounterCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
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
    EncounterCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EncounterCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
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
  EncounterCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EncounterCreateBuilder();
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

