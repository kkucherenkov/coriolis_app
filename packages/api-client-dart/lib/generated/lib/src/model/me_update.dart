//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_update.g.dart';

/// Partial update payload for PATCH /api/v1/me. Only `displayName` is mutable. Omitting a property leaves the corresponding field unchanged. Setting `displayName` to null clears the field. 
///
/// Properties:
/// * [displayName] - User-chosen display name. Must be 1–80 characters when non-null. Set to null to clear the field. 
@BuiltValue()
abstract class MeUpdate implements Built<MeUpdate, MeUpdateBuilder> {
  /// User-chosen display name. Must be 1–80 characters when non-null. Set to null to clear the field. 
  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  MeUpdate._();

  factory MeUpdate([void updates(MeUpdateBuilder b)]) = _$MeUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeUpdate> get serializer => _$MeUpdateSerializer();
}

class _$MeUpdateSerializer implements PrimitiveSerializer<MeUpdate> {
  @override
  final Iterable<Type> types = const [MeUpdate, _$MeUpdate];

  @override
  final String wireName = r'MeUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.displayName != null) {
      yield r'displayName';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MeUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.displayName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeUpdateBuilder();
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

