//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/chat_block_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_blocks200_response.g.dart';

/// ListBlocks200Response
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class ListBlocks200Response implements Built<ListBlocks200Response, ListBlocks200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ChatBlockSummary> get items;

  ListBlocks200Response._();

  factory ListBlocks200Response([void updates(ListBlocks200ResponseBuilder b)]) = _$ListBlocks200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListBlocks200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListBlocks200Response> get serializer => _$ListBlocks200ResponseSerializer();
}

class _$ListBlocks200ResponseSerializer implements PrimitiveSerializer<ListBlocks200Response> {
  @override
  final Iterable<Type> types = const [ListBlocks200Response, _$ListBlocks200Response];

  @override
  final String wireName = r'ListBlocks200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListBlocks200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ChatBlockSummary)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListBlocks200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListBlocks200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ChatBlockSummary)]),
          ) as BuiltList<ChatBlockSummary>;
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
  ListBlocks200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListBlocks200ResponseBuilder();
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

