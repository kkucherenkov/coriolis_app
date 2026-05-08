//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'talent_create.g.dart';

/// Payload for creating a new talent
///
/// Properties:
/// * [name] - Talent name
/// * [description] - Rules text or flavour description
/// * [rank] - Talent rank (defaults to 1 when not provided)
@BuiltValue()
abstract class TalentCreate implements Built<TalentCreate, TalentCreateBuilder> {
  /// Talent name
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Rules text or flavour description
  @BuiltValueField(wireName: r'description')
  String get description;

  /// Talent rank (defaults to 1 when not provided)
  @BuiltValueField(wireName: r'rank')
  int? get rank;

  TalentCreate._();

  factory TalentCreate([void updates(TalentCreateBuilder b)]) = _$TalentCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TalentCreateBuilder b) => b
      ..rank = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<TalentCreate> get serializer => _$TalentCreateSerializer();
}

class _$TalentCreateSerializer implements PrimitiveSerializer<TalentCreate> {
  @override
  final Iterable<Type> types = const [TalentCreate, _$TalentCreate];

  @override
  final String wireName = r'TalentCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TalentCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
    if (object.rank != null) {
      yield r'rank';
      yield serializers.serialize(
        object.rank,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TalentCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TalentCreateBuilder result,
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
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'rank':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rank = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TalentCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TalentCreateBuilder();
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

