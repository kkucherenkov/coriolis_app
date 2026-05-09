//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/dp_source.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dp_event.g.dart';

/// A single Darkness Points audit event
///
/// Properties:
/// * [id] - Opaque event identifier (cuid2)
/// * [gameSessionId] - Session the event belongs to
/// * [delta] - How many DP were added (positive) or removed (negative)
/// * [reason] - Optional human-readable reason
/// * [source_] 
/// * [rollId] - Roll identifier when source is roll-push
/// * [createdAt] 
@BuiltValue()
abstract class DpEvent implements Built<DpEvent, DpEventBuilder> {
  /// Opaque event identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Session the event belongs to
  @BuiltValueField(wireName: r'gameSessionId')
  String get gameSessionId;

  /// How many DP were added (positive) or removed (negative)
  @BuiltValueField(wireName: r'delta')
  int get delta;

  /// Optional human-readable reason
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'source')
  DpSource get source_;
  // enum source_Enum {  gm-manual,  roll-push,  system,  };

  /// Roll identifier when source is roll-push
  @BuiltValueField(wireName: r'rollId')
  String? get rollId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  DpEvent._();

  factory DpEvent([void updates(DpEventBuilder b)]) = _$DpEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DpEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DpEvent> get serializer => _$DpEventSerializer();
}

class _$DpEventSerializer implements PrimitiveSerializer<DpEvent> {
  @override
  final Iterable<Type> types = const [DpEvent, _$DpEvent];

  @override
  final String wireName = r'DpEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DpEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'gameSessionId';
    yield serializers.serialize(
      object.gameSessionId,
      specifiedType: const FullType(String),
    );
    yield r'delta';
    yield serializers.serialize(
      object.delta,
      specifiedType: const FullType(int),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(DpSource),
    );
    if (object.rollId != null) {
      yield r'rollId';
      yield serializers.serialize(
        object.rollId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DpEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DpEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'gameSessionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.gameSessionId = valueDes;
          break;
        case r'delta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.delta = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DpSource),
          ) as DpSource;
          result.source_ = valueDes;
          break;
        case r'rollId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.rollId = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DpEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DpEventBuilder();
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

