//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'attributes.g.dart';

/// The four primary attributes per Coriolis core rules (ГЛАВА 2 «ХАРАКТЕРИСТИКИ»). The rulebook states characteristics are scored 1–5, but at character creation the wizard distributes pools so each attribute lands in `2..4` (5 for the amplua's key attribute), and there is no in-game mechanic that lowers an attribute below 2 once a character has been created. Server-side bounds therefore reflect the **active-PC invariant** (2..5) rather than the abstract scale: a stored character with `strength: 1` would never be reachable through canonical play. The 5-cap stays as the lifetime maximum (ГЛАВА 2 §РАЗВИТИЕ ПЕРСОНАЖА — \"максимально возможное значение характеристики равно 5\"). All four keys are required — missing attributes would make derived-stat calculation impossible server-side. 
///
/// Properties:
/// * [strength] - STR — governs Force, Melee Combat skills and HP max
/// * [agility] - AGI — governs Dexterity, Infiltration, Ranged Combat, Pilot; contributes to HP max
/// * [wits] - WIT — governs Observation, Survival, Technology, Data Djinn, Science, Medicurgy; contributes to MP max
/// * [empathy] - EMP — governs Manipulation, Command, Culture, Mystic Powers; contributes to MP max
@BuiltValue()
abstract class Attributes implements Built<Attributes, AttributesBuilder> {
  /// STR — governs Force, Melee Combat skills and HP max
  @BuiltValueField(wireName: r'strength')
  int get strength;

  /// AGI — governs Dexterity, Infiltration, Ranged Combat, Pilot; contributes to HP max
  @BuiltValueField(wireName: r'agility')
  int get agility;

  /// WIT — governs Observation, Survival, Technology, Data Djinn, Science, Medicurgy; contributes to MP max
  @BuiltValueField(wireName: r'wits')
  int get wits;

  /// EMP — governs Manipulation, Command, Culture, Mystic Powers; contributes to MP max
  @BuiltValueField(wireName: r'empathy')
  int get empathy;

  Attributes._();

  factory Attributes([void updates(AttributesBuilder b)]) = _$Attributes;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AttributesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Attributes> get serializer => _$AttributesSerializer();
}

class _$AttributesSerializer implements PrimitiveSerializer<Attributes> {
  @override
  final Iterable<Type> types = const [Attributes, _$Attributes];

  @override
  final String wireName = r'Attributes';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Attributes object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'strength';
    yield serializers.serialize(
      object.strength,
      specifiedType: const FullType(int),
    );
    yield r'agility';
    yield serializers.serialize(
      object.agility,
      specifiedType: const FullType(int),
    );
    yield r'wits';
    yield serializers.serialize(
      object.wits,
      specifiedType: const FullType(int),
    );
    yield r'empathy';
    yield serializers.serialize(
      object.empathy,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Attributes object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AttributesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'strength':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.strength = valueDes;
          break;
        case r'agility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.agility = valueDes;
          break;
        case r'wits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.wits = valueDes;
          break;
        case r'empathy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.empathy = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Attributes deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AttributesBuilder();
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

