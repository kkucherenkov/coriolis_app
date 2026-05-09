//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/game_session_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'game_session_update.g.dart';

/// PATCH payload for a game session — all fields optional
///
/// Properties:
/// * [name] 
/// * [description] 
/// * [status] 
/// * [shipId] 
@BuiltValue()
abstract class GameSessionUpdate implements Built<GameSessionUpdate, GameSessionUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'status')
  GameSessionStatus? get status;
  // enum statusEnum {  active,  archived,  };

  @BuiltValueField(wireName: r'shipId')
  String? get shipId;

  GameSessionUpdate._();

  factory GameSessionUpdate([void updates(GameSessionUpdateBuilder b)]) = _$GameSessionUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GameSessionUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GameSessionUpdate> get serializer => _$GameSessionUpdateSerializer();
}

class _$GameSessionUpdateSerializer implements PrimitiveSerializer<GameSessionUpdate> {
  @override
  final Iterable<Type> types = const [GameSessionUpdate, _$GameSessionUpdate];

  @override
  final String wireName = r'GameSessionUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GameSessionUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GameSessionStatus),
      );
    }
    if (object.shipId != null) {
      yield r'shipId';
      yield serializers.serialize(
        object.shipId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GameSessionUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GameSessionUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GameSessionStatus),
          ) as GameSessionStatus;
          result.status = valueDes;
          break;
        case r'shipId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.shipId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GameSessionUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GameSessionUpdateBuilder();
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

