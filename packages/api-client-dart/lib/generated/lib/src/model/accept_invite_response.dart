//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/game_session_membership.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'accept_invite_response.g.dart';

/// AcceptInviteResponse
///
/// Properties:
/// * [membership] 
@BuiltValue()
abstract class AcceptInviteResponse implements Built<AcceptInviteResponse, AcceptInviteResponseBuilder> {
  @BuiltValueField(wireName: r'membership')
  GameSessionMembership get membership;

  AcceptInviteResponse._();

  factory AcceptInviteResponse([void updates(AcceptInviteResponseBuilder b)]) = _$AcceptInviteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AcceptInviteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AcceptInviteResponse> get serializer => _$AcceptInviteResponseSerializer();
}

class _$AcceptInviteResponseSerializer implements PrimitiveSerializer<AcceptInviteResponse> {
  @override
  final Iterable<Type> types = const [AcceptInviteResponse, _$AcceptInviteResponse];

  @override
  final String wireName = r'AcceptInviteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AcceptInviteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'membership';
    yield serializers.serialize(
      object.membership,
      specifiedType: const FullType(GameSessionMembership),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AcceptInviteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AcceptInviteResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'membership':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GameSessionMembership),
          ) as GameSessionMembership;
          result.membership.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AcceptInviteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AcceptInviteResponseBuilder();
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

