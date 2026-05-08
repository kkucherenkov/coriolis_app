//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character_mp.g.dart';

/// CharacterMp
///
/// Properties:
/// * [current] 
/// * [max] - Derived from WIT + EMP; set by the server
@BuiltValue()
abstract class CharacterMp implements Built<CharacterMp, CharacterMpBuilder> {
  @BuiltValueField(wireName: r'current')
  int get current;

  /// Derived from WIT + EMP; set by the server
  @BuiltValueField(wireName: r'max')
  int get max;

  CharacterMp._();

  factory CharacterMp([void updates(CharacterMpBuilder b)]) = _$CharacterMp;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterMpBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CharacterMp> get serializer => _$CharacterMpSerializer();
}

class _$CharacterMpSerializer implements PrimitiveSerializer<CharacterMp> {
  @override
  final Iterable<Type> types = const [CharacterMp, _$CharacterMp];

  @override
  final String wireName = r'CharacterMp';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CharacterMp object, {
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
    CharacterMp object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CharacterMpBuilder result,
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
  CharacterMp deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CharacterMpBuilder();
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

