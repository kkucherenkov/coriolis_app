//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character_hp.g.dart';

/// CharacterHp
///
/// Properties:
/// * [current] 
/// * [max] - Derived from STR + AGI; set by the server
@BuiltValue()
abstract class CharacterHp implements Built<CharacterHp, CharacterHpBuilder> {
  @BuiltValueField(wireName: r'current')
  int get current;

  /// Derived from STR + AGI; set by the server
  @BuiltValueField(wireName: r'max')
  int get max;

  CharacterHp._();

  factory CharacterHp([void updates(CharacterHpBuilder b)]) = _$CharacterHp;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterHpBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CharacterHp> get serializer => _$CharacterHpSerializer();
}

class _$CharacterHpSerializer implements PrimitiveSerializer<CharacterHp> {
  @override
  final Iterable<Type> types = const [CharacterHp, _$CharacterHp];

  @override
  final String wireName = r'CharacterHp';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CharacterHp object, {
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
    CharacterHp object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CharacterHpBuilder result,
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
  CharacterHp deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CharacterHpBuilder();
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

