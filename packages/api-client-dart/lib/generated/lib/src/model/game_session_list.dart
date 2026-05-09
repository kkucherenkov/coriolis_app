//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/game_session.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'game_session_list.g.dart';

/// GameSessionList
///
/// Properties:
/// * [items] 
/// * [nextCursor] - Cursor for the next page; null when there are no more results
@BuiltValue()
abstract class GameSessionList implements Built<GameSessionList, GameSessionListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GameSession> get items;

  /// Cursor for the next page; null when there are no more results
  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  GameSessionList._();

  factory GameSessionList([void updates(GameSessionListBuilder b)]) = _$GameSessionList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GameSessionListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GameSessionList> get serializer => _$GameSessionListSerializer();
}

class _$GameSessionListSerializer implements PrimitiveSerializer<GameSessionList> {
  @override
  final Iterable<Type> types = const [GameSessionList, _$GameSessionList];

  @override
  final String wireName = r'GameSessionList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GameSessionList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(GameSession)]),
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
    GameSessionList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GameSessionListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GameSession)]),
          ) as BuiltList<GameSession>;
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
  GameSessionList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GameSessionListBuilder();
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

