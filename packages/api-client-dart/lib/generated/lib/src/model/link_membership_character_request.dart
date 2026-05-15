//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'link_membership_character_request.g.dart';

/// LinkMembershipCharacterRequest
///
/// Properties:
/// * [characterId] - Character ID to link, or null to unlink
@BuiltValue()
abstract class LinkMembershipCharacterRequest implements Built<LinkMembershipCharacterRequest, LinkMembershipCharacterRequestBuilder> {
  /// Character ID to link, or null to unlink
  @BuiltValueField(wireName: r'characterId')
  String? get characterId;

  LinkMembershipCharacterRequest._();

  factory LinkMembershipCharacterRequest([void updates(LinkMembershipCharacterRequestBuilder b)]) = _$LinkMembershipCharacterRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LinkMembershipCharacterRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LinkMembershipCharacterRequest> get serializer => _$LinkMembershipCharacterRequestSerializer();
}

class _$LinkMembershipCharacterRequestSerializer implements PrimitiveSerializer<LinkMembershipCharacterRequest> {
  @override
  final Iterable<Type> types = const [LinkMembershipCharacterRequest, _$LinkMembershipCharacterRequest];

  @override
  final String wireName = r'LinkMembershipCharacterRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LinkMembershipCharacterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'characterId';
    yield object.characterId == null ? null : serializers.serialize(
      object.characterId,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LinkMembershipCharacterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LinkMembershipCharacterRequestBuilder result,
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
  LinkMembershipCharacterRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LinkMembershipCharacterRequestBuilder();
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

