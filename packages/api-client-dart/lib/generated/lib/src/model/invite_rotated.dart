//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invite_rotated.g.dart';

/// Response to POST /invite/rotate. Contains the plaintext URL exactly once; subsequent reads (GET /invite) return InviteMetadata without the URL. If the GM loses the URL they must rotate again. 
///
/// Properties:
/// * [url] - Absolute URL clients should share with players.
/// * [token] - The 22-char nanoid component of the URL.
/// * [rotatedAt] 
@BuiltValue()
abstract class InviteRotated implements Built<InviteRotated, InviteRotatedBuilder> {
  /// Absolute URL clients should share with players.
  @BuiltValueField(wireName: r'url')
  String get url;

  /// The 22-char nanoid component of the URL.
  @BuiltValueField(wireName: r'token')
  String get token;

  @BuiltValueField(wireName: r'rotatedAt')
  DateTime get rotatedAt;

  InviteRotated._();

  factory InviteRotated([void updates(InviteRotatedBuilder b)]) = _$InviteRotated;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InviteRotatedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InviteRotated> get serializer => _$InviteRotatedSerializer();
}

class _$InviteRotatedSerializer implements PrimitiveSerializer<InviteRotated> {
  @override
  final Iterable<Type> types = const [InviteRotated, _$InviteRotated];

  @override
  final String wireName = r'InviteRotated';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InviteRotated object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
    yield r'rotatedAt';
    yield serializers.serialize(
      object.rotatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InviteRotated object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InviteRotatedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        case r'rotatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
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
  InviteRotated deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InviteRotatedBuilder();
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

