//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/crew_position.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'assign_crew_request.g.dart';

/// AssignCrewRequest
///
/// Properties:
/// * [position] 
/// * [characterId] - ID of the character to assign (must be owned by caller)
@BuiltValue()
abstract class AssignCrewRequest implements Built<AssignCrewRequest, AssignCrewRequestBuilder> {
  @BuiltValueField(wireName: r'position')
  CrewPosition get position;
  // enum positionEnum {  captain,  pilot,  sensorOp,  gunner,  engineer,  serviceCrew,  };

  /// ID of the character to assign (must be owned by caller)
  @BuiltValueField(wireName: r'characterId')
  String get characterId;

  AssignCrewRequest._();

  factory AssignCrewRequest([void updates(AssignCrewRequestBuilder b)]) = _$AssignCrewRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AssignCrewRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AssignCrewRequest> get serializer => _$AssignCrewRequestSerializer();
}

class _$AssignCrewRequestSerializer implements PrimitiveSerializer<AssignCrewRequest> {
  @override
  final Iterable<Type> types = const [AssignCrewRequest, _$AssignCrewRequest];

  @override
  final String wireName = r'AssignCrewRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AssignCrewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(CrewPosition),
    );
    yield r'characterId';
    yield serializers.serialize(
      object.characterId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AssignCrewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AssignCrewRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CrewPosition),
          ) as CrewPosition;
          result.position = valueDes;
          break;
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
  AssignCrewRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AssignCrewRequestBuilder();
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

