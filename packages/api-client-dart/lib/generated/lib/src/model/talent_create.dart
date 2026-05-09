//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/talent_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'talent_create.g.dart';

/// Payload for creating a new talent. `kind` defaults to `personal` when omitted (the most common case for talents acquired during play). At character creation, the wizard picks one talent of each kind (`personal`, `crew`, `iconGift`); the server rejects a second talent of the same non-`personal` kind with `TALENT_KIND_DUPLICATE`. 
///
/// Properties:
/// * [kind] - Defaults to `personal`. Pass `crew` / `iconGift` / `stigma` to record a starting-talent slot of that kind (only one of each non-`personal` kind is allowed per character). 
/// * [name] - Talent name
/// * [description] - Rules text or flavour description
/// * [rank] - Talent rank (defaults to 1 when not provided)
@BuiltValue()
abstract class TalentCreate implements Built<TalentCreate, TalentCreateBuilder> {
  /// Defaults to `personal`. Pass `crew` / `iconGift` / `stigma` to record a starting-talent slot of that kind (only one of each non-`personal` kind is allowed per character). 
  @BuiltValueField(wireName: r'kind')
  TalentKind? get kind;
  // enum kindEnum {  personal,  crew,  iconGift,  stigma,  };

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
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(TalentKind),
      );
    }
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TalentKind),
          ) as TalentKind;
          result.kind = valueDes;
          break;
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

