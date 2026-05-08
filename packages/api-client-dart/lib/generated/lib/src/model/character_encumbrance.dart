//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character_encumbrance.g.dart';

/// CharacterEncumbrance
///
/// Properties:
/// * [current] - Sum of non-stowed item weights; set by the server
/// * [max] - Derived from STR × 2; set by the server
@BuiltValue()
abstract class CharacterEncumbrance implements Built<CharacterEncumbrance, CharacterEncumbranceBuilder> {
  /// Sum of non-stowed item weights; set by the server
  @BuiltValueField(wireName: r'current')
  num get current;

  /// Derived from STR × 2; set by the server
  @BuiltValueField(wireName: r'max')
  int get max;

  CharacterEncumbrance._();

  factory CharacterEncumbrance([void updates(CharacterEncumbranceBuilder b)]) = _$CharacterEncumbrance;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterEncumbranceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CharacterEncumbrance> get serializer => _$CharacterEncumbranceSerializer();
}

class _$CharacterEncumbranceSerializer implements PrimitiveSerializer<CharacterEncumbrance> {
  @override
  final Iterable<Type> types = const [CharacterEncumbrance, _$CharacterEncumbrance];

  @override
  final String wireName = r'CharacterEncumbrance';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CharacterEncumbrance object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'current';
    yield serializers.serialize(
      object.current,
      specifiedType: const FullType(num),
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
    CharacterEncumbrance object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CharacterEncumbranceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
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
  CharacterEncumbrance deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CharacterEncumbranceBuilder();
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

