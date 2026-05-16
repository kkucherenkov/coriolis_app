//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mark_read_request.g.dart';

/// MarkReadRequest
///
/// Properties:
/// * [lastReadAt] 
@BuiltValue()
abstract class MarkReadRequest implements Built<MarkReadRequest, MarkReadRequestBuilder> {
  @BuiltValueField(wireName: r'lastReadAt')
  DateTime get lastReadAt;

  MarkReadRequest._();

  factory MarkReadRequest([void updates(MarkReadRequestBuilder b)]) = _$MarkReadRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MarkReadRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MarkReadRequest> get serializer => _$MarkReadRequestSerializer();
}

class _$MarkReadRequestSerializer implements PrimitiveSerializer<MarkReadRequest> {
  @override
  final Iterable<Type> types = const [MarkReadRequest, _$MarkReadRequest];

  @override
  final String wireName = r'MarkReadRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MarkReadRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'lastReadAt';
    yield serializers.serialize(
      object.lastReadAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MarkReadRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MarkReadRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'lastReadAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastReadAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MarkReadRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MarkReadRequestBuilder();
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

