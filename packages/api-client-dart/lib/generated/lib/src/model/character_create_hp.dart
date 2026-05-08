//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character_create_hp.g.dart';

/// CharacterCreateHp
///
/// Properties:
/// * [current] 
@BuiltValue()
abstract class CharacterCreateHp implements Built<CharacterCreateHp, CharacterCreateHpBuilder> {
  @BuiltValueField(wireName: r'current')
  int? get current;

  CharacterCreateHp._();

  factory CharacterCreateHp([void updates(CharacterCreateHpBuilder b)]) = _$CharacterCreateHp;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterCreateHpBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CharacterCreateHp> get serializer => _$CharacterCreateHpSerializer();
}

class _$CharacterCreateHpSerializer implements PrimitiveSerializer<CharacterCreateHp> {
  @override
  final Iterable<Type> types = const [CharacterCreateHp, _$CharacterCreateHp];

  @override
  final String wireName = r'CharacterCreateHp';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CharacterCreateHp object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.current != null) {
      yield r'current';
      yield serializers.serialize(
        object.current,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CharacterCreateHp object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CharacterCreateHpBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CharacterCreateHp deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CharacterCreateHpBuilder();
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

