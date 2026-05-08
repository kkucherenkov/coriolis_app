//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/crew_position.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'crew_slot.g.dart';

/// A crew position on a ship. Positions without an assigned character are vacant (open berth). Multiple characters may not share one position. 
///
/// Properties:
/// * [position] 
/// * [assignedCharacterId] - ID of the assigned Character. Null when the berth is vacant. The character must be owned by the same user as the ship. 
@BuiltValue()
abstract class CrewSlot implements Built<CrewSlot, CrewSlotBuilder> {
  @BuiltValueField(wireName: r'position')
  CrewPosition get position;
  // enum positionEnum {  captain,  pilot,  sensorOp,  gunner,  engineer,  serviceCrew,  };

  /// ID of the assigned Character. Null when the berth is vacant. The character must be owned by the same user as the ship. 
  @BuiltValueField(wireName: r'assignedCharacterId')
  String? get assignedCharacterId;

  CrewSlot._();

  factory CrewSlot([void updates(CrewSlotBuilder b)]) = _$CrewSlot;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CrewSlotBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CrewSlot> get serializer => _$CrewSlotSerializer();
}

class _$CrewSlotSerializer implements PrimitiveSerializer<CrewSlot> {
  @override
  final Iterable<Type> types = const [CrewSlot, _$CrewSlot];

  @override
  final String wireName = r'CrewSlot';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CrewSlot object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(CrewPosition),
    );
    if (object.assignedCharacterId != null) {
      yield r'assignedCharacterId';
      yield serializers.serialize(
        object.assignedCharacterId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CrewSlot object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CrewSlotBuilder result,
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
        case r'assignedCharacterId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assignedCharacterId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CrewSlot deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CrewSlotBuilder();
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

