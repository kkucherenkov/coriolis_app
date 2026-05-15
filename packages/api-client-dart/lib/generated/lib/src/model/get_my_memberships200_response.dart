//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/my_membership_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_my_memberships200_response.g.dart';

/// GetMyMemberships200Response
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class GetMyMemberships200Response implements Built<GetMyMemberships200Response, GetMyMemberships200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<MyMembershipSummary> get items;

  GetMyMemberships200Response._();

  factory GetMyMemberships200Response([void updates(GetMyMemberships200ResponseBuilder b)]) = _$GetMyMemberships200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetMyMemberships200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetMyMemberships200Response> get serializer => _$GetMyMemberships200ResponseSerializer();
}

class _$GetMyMemberships200ResponseSerializer implements PrimitiveSerializer<GetMyMemberships200Response> {
  @override
  final Iterable<Type> types = const [GetMyMemberships200Response, _$GetMyMemberships200Response];

  @override
  final String wireName = r'GetMyMemberships200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetMyMemberships200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(MyMembershipSummary)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetMyMemberships200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetMyMemberships200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MyMembershipSummary)]),
          ) as BuiltList<MyMembershipSummary>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetMyMemberships200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetMyMemberships200ResponseBuilder();
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

