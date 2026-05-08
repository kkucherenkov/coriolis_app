//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/character.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character_list.g.dart';

/// Cursor-paginated list of characters
///
/// Properties:
/// * [items] 
/// * [nextCursor] - Opaque cursor for the next page; null when this is the last page
@BuiltValue()
abstract class CharacterList implements Built<CharacterList, CharacterListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Character> get items;

  /// Opaque cursor for the next page; null when this is the last page
  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  CharacterList._();

  factory CharacterList([void updates(CharacterListBuilder b)]) = _$CharacterList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CharacterList> get serializer => _$CharacterListSerializer();
}

class _$CharacterListSerializer implements PrimitiveSerializer<CharacterList> {
  @override
  final Iterable<Type> types = const [CharacterList, _$CharacterList];

  @override
  final String wireName = r'CharacterList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CharacterList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Character)]),
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
    CharacterList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CharacterListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Character)]),
          ) as BuiltList<Character>;
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
  CharacterList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CharacterListBuilder();
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

