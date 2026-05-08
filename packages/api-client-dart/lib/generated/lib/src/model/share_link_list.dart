//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/share_link.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'share_link_list.g.dart';

/// ShareLinkList
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class ShareLinkList implements Built<ShareLinkList, ShareLinkListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ShareLink> get items;

  ShareLinkList._();

  factory ShareLinkList([void updates(ShareLinkListBuilder b)]) = _$ShareLinkList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShareLinkListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShareLinkList> get serializer => _$ShareLinkListSerializer();
}

class _$ShareLinkListSerializer implements PrimitiveSerializer<ShareLinkList> {
  @override
  final Iterable<Type> types = const [ShareLinkList, _$ShareLinkList];

  @override
  final String wireName = r'ShareLinkList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShareLinkList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ShareLink)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ShareLinkList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShareLinkListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ShareLink)]),
          ) as BuiltList<ShareLink>;
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
  ShareLinkList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShareLinkListBuilder();
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

