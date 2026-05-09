//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/dp_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dp_event_list.g.dart';

/// DpEventList
///
/// Properties:
/// * [items] 
/// * [nextCursor] - Cursor for the next page; null when there are no more results
@BuiltValue()
abstract class DpEventList implements Built<DpEventList, DpEventListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<DpEvent> get items;

  /// Cursor for the next page; null when there are no more results
  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  DpEventList._();

  factory DpEventList([void updates(DpEventListBuilder b)]) = _$DpEventList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DpEventListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DpEventList> get serializer => _$DpEventListSerializer();
}

class _$DpEventListSerializer implements PrimitiveSerializer<DpEventList> {
  @override
  final Iterable<Type> types = const [DpEventList, _$DpEventList];

  @override
  final String wireName = r'DpEventList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DpEventList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(DpEvent)]),
    );
    yield r'nextCursor';
    yield object.nextCursor == null ? null : serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DpEventList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DpEventListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DpEvent)]),
          ) as BuiltList<DpEvent>;
          result.items.replace(valueDes);
          break;
        case r'nextCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DpEventList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DpEventListBuilder();
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

