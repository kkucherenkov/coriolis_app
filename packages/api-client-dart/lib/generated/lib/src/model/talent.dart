//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/talent_kind.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'talent.g.dart';

/// A talent owned by a character
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [kind] - Discriminator describing where this talent came from (personal amplua, crew amplua, icon gift, or mutant stigma). Set on creation and immutable thereafter. 
/// * [name] - Talent name (e.g. \"Wing-Mate\", \"Stunt Pilot\")
/// * [description] - Rules text or flavour description of the talent
/// * [rank] - Talent rank (1 = basic, 2 = journeyman, 3 = master)
/// * [acquiredAt] - ISO-8601 instant when the talent was recorded on the sheet
@BuiltValue()
abstract class Talent implements Built<Talent, TalentBuilder> {
  /// Opaque identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Discriminator describing where this talent came from (personal amplua, crew amplua, icon gift, or mutant stigma). Set on creation and immutable thereafter. 
  @BuiltValueField(wireName: r'kind')
  TalentKind get kind;
  // enum kindEnum {  personal,  crew,  iconGift,  stigma,  };

  /// Talent name (e.g. \"Wing-Mate\", \"Stunt Pilot\")
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Rules text or flavour description of the talent
  @BuiltValueField(wireName: r'description')
  String get description;

  /// Talent rank (1 = basic, 2 = journeyman, 3 = master)
  @BuiltValueField(wireName: r'rank')
  int get rank;

  /// ISO-8601 instant when the talent was recorded on the sheet
  @BuiltValueField(wireName: r'acquiredAt')
  DateTime get acquiredAt;

  Talent._();

  factory Talent([void updates(TalentBuilder b)]) = _$Talent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TalentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Talent> get serializer => _$TalentSerializer();
}

class _$TalentSerializer implements PrimitiveSerializer<Talent> {
  @override
  final Iterable<Type> types = const [Talent, _$Talent];

  @override
  final String wireName = r'Talent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Talent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(TalentKind),
    );
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
    yield r'rank';
    yield serializers.serialize(
      object.rank,
      specifiedType: const FullType(int),
    );
    yield r'acquiredAt';
    yield serializers.serialize(
      object.acquiredAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Talent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TalentBuilder result,
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
        case r'acquiredAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.acquiredAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Talent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TalentBuilder();
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

