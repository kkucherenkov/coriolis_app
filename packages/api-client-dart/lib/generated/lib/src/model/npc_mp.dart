//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'npc_mp.g.dart';

/// Mind points — both current and max are GM-editable for NPCs
///
/// Properties:
/// * [current] - Current mind points
/// * [max] - Maximum mind points
@BuiltValue()
abstract class NpcMp implements Built<NpcMp, NpcMpBuilder> {
  /// Current mind points
  @BuiltValueField(wireName: r'current')
  int get current;

  /// Maximum mind points
  @BuiltValueField(wireName: r'max')
  int get max;

  NpcMp._();

  factory NpcMp([void updates(NpcMpBuilder b)]) = _$NpcMp;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NpcMpBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NpcMp> get serializer => _$NpcMpSerializer();
}

class _$NpcMpSerializer implements PrimitiveSerializer<NpcMp> {
  @override
  final Iterable<Type> types = const [NpcMp, _$NpcMp];

  @override
  final String wireName = r'NpcMp';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NpcMp object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'current';
    yield serializers.serialize(
      object.current,
      specifiedType: const FullType(int),
    );
    yield r'max';
    yield serializers.serialize(
      object.max,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NpcMp object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NpcMpBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.current = valueDes;
          break;
        case r'max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.max = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NpcMp deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NpcMpBuilder();
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

