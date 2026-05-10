//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/npc.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'npc_list.g.dart';

/// Cursor-paginated list of NPCs
///
/// Properties:
/// * [items] 
/// * [nextCursor] - Cursor for the next page; null when there are no more results
@BuiltValue()
abstract class NpcList implements Built<NpcList, NpcListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Npc> get items;

  /// Cursor for the next page; null when there are no more results
  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  NpcList._();

  factory NpcList([void updates(NpcListBuilder b)]) = _$NpcList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NpcListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NpcList> get serializer => _$NpcListSerializer();
}

class _$NpcListSerializer implements PrimitiveSerializer<NpcList> {
  @override
  final Iterable<Type> types = const [NpcList, _$NpcList];

  @override
  final String wireName = r'NpcList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NpcList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Npc)]),
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
    NpcList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NpcListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Npc)]),
          ) as BuiltList<Npc>;
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
  NpcList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NpcListBuilder();
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

