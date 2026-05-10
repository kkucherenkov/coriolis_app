//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'skills.g.dart';

/// The 16 canonical Coriolis skills (ГЛАВА 3 «Перечень навыков»), 8 general (`dexterity, force, infiltration, manipulation, meleeCombat, observation, rangedCombat, survival`) and 8 advanced/specialised (`command, culture, dataDjinn, medicurgy, mysticPowers, pilot, science, technology`). All skills range 0..5 server-side; the lifetime cap of 5 is canon (ГЛАВА 2 §РАЗВИТИЕ ПЕРСОНАЖА — «максимально возможное значение навыка равно 5»). The general/advanced split affects rolling, not range: per ГЛАВА 3 §«Специальные навыки», a general skill can be rolled at value 0 (attribute-only check), while an advanced skill requires value ≥ 1 to roll at all — that gate lives in the dice-engine, not in the schema. Creation-time caps (key skills up to 3, others up to 1, per ГЛАВА 2 «НАВЫКИ») are enforced by the backend `validateSkillsAtCreation` handler against the chosen amplua, not by this schema. All keys are required. 
///
/// Properties:
/// * [dexterity] - General skill (AGI)
/// * [force] - General skill (STR)
/// * [infiltration] - General skill (AGI)
/// * [manipulation] - General skill (EMP)
/// * [meleeCombat] - General skill (STR)
/// * [observation] - General skill (WIT)
/// * [rangedCombat] - General skill (AGI)
/// * [survival] - General skill (WIT)
/// * [command] - Advanced skill (EMP)
/// * [culture] - Advanced skill (EMP)
/// * [dataDjinn] - Advanced skill (WIT)
/// * [medicurgy] - Advanced skill (WIT)
/// * [mysticPowers] - Advanced skill (EMP)
/// * [pilot] - Advanced skill (AGI)
/// * [science] - Advanced skill (WIT)
/// * [technology] - Advanced skill (WIT)
@BuiltValue()
abstract class Skills implements Built<Skills, SkillsBuilder> {
  /// General skill (AGI)
  @BuiltValueField(wireName: r'dexterity')
  int get dexterity;

  /// General skill (STR)
  @BuiltValueField(wireName: r'force')
  int get force;

  /// General skill (AGI)
  @BuiltValueField(wireName: r'infiltration')
  int get infiltration;

  /// General skill (EMP)
  @BuiltValueField(wireName: r'manipulation')
  int get manipulation;

  /// General skill (STR)
  @BuiltValueField(wireName: r'meleeCombat')
  int get meleeCombat;

  /// General skill (WIT)
  @BuiltValueField(wireName: r'observation')
  int get observation;

  /// General skill (AGI)
  @BuiltValueField(wireName: r'rangedCombat')
  int get rangedCombat;

  /// General skill (WIT)
  @BuiltValueField(wireName: r'survival')
  int get survival;

  /// Advanced skill (EMP)
  @BuiltValueField(wireName: r'command')
  int get command;

  /// Advanced skill (EMP)
  @BuiltValueField(wireName: r'culture')
  int get culture;

  /// Advanced skill (WIT)
  @BuiltValueField(wireName: r'dataDjinn')
  int get dataDjinn;

  /// Advanced skill (WIT)
  @BuiltValueField(wireName: r'medicurgy')
  int get medicurgy;

  /// Advanced skill (EMP)
  @BuiltValueField(wireName: r'mysticPowers')
  int get mysticPowers;

  /// Advanced skill (AGI)
  @BuiltValueField(wireName: r'pilot')
  int get pilot;

  /// Advanced skill (WIT)
  @BuiltValueField(wireName: r'science')
  int get science;

  /// Advanced skill (WIT)
  @BuiltValueField(wireName: r'technology')
  int get technology;

  Skills._();

  factory Skills([void updates(SkillsBuilder b)]) = _$Skills;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SkillsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Skills> get serializer => _$SkillsSerializer();
}

class _$SkillsSerializer implements PrimitiveSerializer<Skills> {
  @override
  final Iterable<Type> types = const [Skills, _$Skills];

  @override
  final String wireName = r'Skills';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Skills object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'dexterity';
    yield serializers.serialize(
      object.dexterity,
      specifiedType: const FullType(int),
    );
    yield r'force';
    yield serializers.serialize(
      object.force,
      specifiedType: const FullType(int),
    );
    yield r'infiltration';
    yield serializers.serialize(
      object.infiltration,
      specifiedType: const FullType(int),
    );
    yield r'manipulation';
    yield serializers.serialize(
      object.manipulation,
      specifiedType: const FullType(int),
    );
    yield r'meleeCombat';
    yield serializers.serialize(
      object.meleeCombat,
      specifiedType: const FullType(int),
    );
    yield r'observation';
    yield serializers.serialize(
      object.observation,
      specifiedType: const FullType(int),
    );
    yield r'rangedCombat';
    yield serializers.serialize(
      object.rangedCombat,
      specifiedType: const FullType(int),
    );
    yield r'survival';
    yield serializers.serialize(
      object.survival,
      specifiedType: const FullType(int),
    );
    yield r'command';
    yield serializers.serialize(
      object.command,
      specifiedType: const FullType(int),
    );
    yield r'culture';
    yield serializers.serialize(
      object.culture,
      specifiedType: const FullType(int),
    );
    yield r'dataDjinn';
    yield serializers.serialize(
      object.dataDjinn,
      specifiedType: const FullType(int),
    );
    yield r'medicurgy';
    yield serializers.serialize(
      object.medicurgy,
      specifiedType: const FullType(int),
    );
    yield r'mysticPowers';
    yield serializers.serialize(
      object.mysticPowers,
      specifiedType: const FullType(int),
    );
    yield r'pilot';
    yield serializers.serialize(
      object.pilot,
      specifiedType: const FullType(int),
    );
    yield r'science';
    yield serializers.serialize(
      object.science,
      specifiedType: const FullType(int),
    );
    yield r'technology';
    yield serializers.serialize(
      object.technology,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Skills object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SkillsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dexterity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.dexterity = valueDes;
          break;
        case r'force':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.force = valueDes;
          break;
        case r'infiltration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.infiltration = valueDes;
          break;
        case r'manipulation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.manipulation = valueDes;
          break;
        case r'meleeCombat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.meleeCombat = valueDes;
          break;
        case r'observation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.observation = valueDes;
          break;
        case r'rangedCombat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rangedCombat = valueDes;
          break;
        case r'survival':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.survival = valueDes;
          break;
        case r'command':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.command = valueDes;
          break;
        case r'culture':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.culture = valueDes;
          break;
        case r'dataDjinn':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.dataDjinn = valueDes;
          break;
        case r'medicurgy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.medicurgy = valueDes;
          break;
        case r'mysticPowers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.mysticPowers = valueDes;
          break;
        case r'pilot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pilot = valueDes;
          break;
        case r'science':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.science = valueDes;
          break;
        case r'technology':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.technology = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Skills deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SkillsBuilder();
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

