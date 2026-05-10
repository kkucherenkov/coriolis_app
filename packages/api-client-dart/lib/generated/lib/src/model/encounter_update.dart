//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/encounter_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'encounter_update.g.dart';

/// PATCH payload for `PATCH /api/v1/encounters/{id}`. All fields are optional; omitted fields are left unchanged.  Supplying `status` triggers a state-machine transition validated by the server. See the endpoint description for the full transition table and the 422 error codes. 
///
/// Properties:
/// * [name] - Rename the encounter (allowed at any status)
/// * [status] 
/// * [notes] - Update GM notes in Markdown (allowed at any status)
@BuiltValue()
abstract class EncounterUpdate implements Built<EncounterUpdate, EncounterUpdateBuilder> {
  /// Rename the encounter (allowed at any status)
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'status')
  EncounterStatus? get status;
  // enum statusEnum {  setup,  active,  ended,  };

  /// Update GM notes in Markdown (allowed at any status)
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  EncounterUpdate._();

  factory EncounterUpdate([void updates(EncounterUpdateBuilder b)]) = _$EncounterUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EncounterUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EncounterUpdate> get serializer => _$EncounterUpdateSerializer();
}

class _$EncounterUpdateSerializer implements PrimitiveSerializer<EncounterUpdate> {
  @override
  final Iterable<Type> types = const [EncounterUpdate, _$EncounterUpdate];

  @override
  final String wireName = r'EncounterUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EncounterUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(EncounterStatus),
      );
    }
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
    EncounterUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EncounterUpdateBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EncounterStatus),
          ) as EncounterStatus;
          result.status = valueDes;
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
  EncounterUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EncounterUpdateBuilder();
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

