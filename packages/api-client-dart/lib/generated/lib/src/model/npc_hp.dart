//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'npc_hp.g.dart';

/// Hit points — both current and max are GM-editable for NPCs
///
/// Properties:
/// * [current] - Current hit points
/// * [max] - Maximum hit points
@BuiltValue()
abstract class NpcHp implements Built<NpcHp, NpcHpBuilder> {
  /// Current hit points
  @BuiltValueField(wireName: r'current')
  int get current;

  /// Maximum hit points
  @BuiltValueField(wireName: r'max')
  int get max;

  NpcHp._();

  factory NpcHp([void updates(NpcHpBuilder b)]) = _$NpcHp;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NpcHpBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NpcHp> get serializer => _$NpcHpSerializer();
}

class _$NpcHpSerializer implements PrimitiveSerializer<NpcHp> {
  @override
  final Iterable<Type> types = const [NpcHp, _$NpcHp];

  @override
  final String wireName = r'NpcHp';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NpcHp object, {
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
    NpcHp object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NpcHpBuilder result,
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
  NpcHp deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NpcHpBuilder();
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

