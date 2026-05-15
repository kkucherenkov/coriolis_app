//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invite_metadata.g.dart';

/// Metadata about a GameSession's current invite link. The plaintext URL is returned only once, by POST /invite/rotate — this endpoint only exposes whether an invite is active and when it was rotated. 
///
/// Properties:
/// * [active] 
/// * [rotatedAt] 
@BuiltValue()
abstract class InviteMetadata implements Built<InviteMetadata, InviteMetadataBuilder> {
  @BuiltValueField(wireName: r'active')
  bool get active;

  @BuiltValueField(wireName: r'rotatedAt')
  DateTime? get rotatedAt;

  InviteMetadata._();

  factory InviteMetadata([void updates(InviteMetadataBuilder b)]) = _$InviteMetadata;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InviteMetadataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InviteMetadata> get serializer => _$InviteMetadataSerializer();
}

class _$InviteMetadataSerializer implements PrimitiveSerializer<InviteMetadata> {
  @override
  final Iterable<Type> types = const [InviteMetadata, _$InviteMetadata];

  @override
  final String wireName = r'InviteMetadata';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InviteMetadata object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
    if (object.rotatedAt != null) {
      yield r'rotatedAt';
      yield serializers.serialize(
        object.rotatedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InviteMetadata object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InviteMetadataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
          break;
        case r'rotatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.rotatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InviteMetadata deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InviteMetadataBuilder();
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

