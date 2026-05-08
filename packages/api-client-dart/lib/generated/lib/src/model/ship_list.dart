//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/ship.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_list.g.dart';

/// Cursor-paginated list of ships
///
/// Properties:
/// * [items] 
/// * [nextCursor] - Opaque cursor for the next page; null when this is the last page
@BuiltValue()
abstract class ShipList implements Built<ShipList, ShipListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Ship> get items;

  /// Opaque cursor for the next page; null when this is the last page
  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  ShipList._();

  factory ShipList([void updates(ShipListBuilder b)]) = _$ShipList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipList> get serializer => _$ShipListSerializer();
}

class _$ShipListSerializer implements PrimitiveSerializer<ShipList> {
  @override
  final Iterable<Type> types = const [ShipList, _$ShipList];

  @override
  final String wireName = r'ShipList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Ship)]),
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
    ShipList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Ship)]),
          ) as BuiltList<Ship>;
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
  ShipList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipListBuilder();
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

