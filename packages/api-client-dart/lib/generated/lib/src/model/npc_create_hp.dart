//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'npc_create_hp.g.dart';

/// Hit points; defaults to {current: 4, max: 4} when omitted
///
/// Properties:
/// * [current] 
/// * [max] 
@BuiltValue()
abstract class NpcCreateHp implements Built<NpcCreateHp, NpcCreateHpBuilder> {
  @BuiltValueField(wireName: r'current')
  int? get current;

  @BuiltValueField(wireName: r'max')
  int? get max;

  NpcCreateHp._();

  factory NpcCreateHp([void updates(NpcCreateHpBuilder b)]) = _$NpcCreateHp;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NpcCreateHpBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NpcCreateHp> get serializer => _$NpcCreateHpSerializer();
}

class _$NpcCreateHpSerializer implements PrimitiveSerializer<NpcCreateHp> {
  @override
  final Iterable<Type> types = const [NpcCreateHp, _$NpcCreateHp];

  @override
  final String wireName = r'NpcCreateHp';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NpcCreateHp object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.current != null) {
      yield r'current';
      yield serializers.serialize(
        object.current,
        specifiedType: const FullType(int),
      );
    }
    if (object.max != null) {
      yield r'max';
      yield serializers.serialize(
        object.max,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NpcCreateHp object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NpcCreateHpBuilder result,
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
  NpcCreateHp deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NpcCreateHpBuilder();
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

