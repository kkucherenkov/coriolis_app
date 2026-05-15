//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'accept_invite_body.g.dart';

/// AcceptInviteBody
///
/// Properties:
/// * [characterId] - Optional character to link at join time.
@BuiltValue()
abstract class AcceptInviteBody implements Built<AcceptInviteBody, AcceptInviteBodyBuilder> {
  /// Optional character to link at join time.
  @BuiltValueField(wireName: r'characterId')
  String? get characterId;

  AcceptInviteBody._();

  factory AcceptInviteBody([void updates(AcceptInviteBodyBuilder b)]) = _$AcceptInviteBody;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AcceptInviteBodyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AcceptInviteBody> get serializer => _$AcceptInviteBodySerializer();
}

class _$AcceptInviteBodySerializer implements PrimitiveSerializer<AcceptInviteBody> {
  @override
  final Iterable<Type> types = const [AcceptInviteBody, _$AcceptInviteBody];

  @override
  final String wireName = r'AcceptInviteBody';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AcceptInviteBody object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.characterId != null) {
      yield r'characterId';
      yield serializers.serialize(
        object.characterId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AcceptInviteBody object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AcceptInviteBodyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'characterId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  AcceptInviteBody deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AcceptInviteBodyBuilder();
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

