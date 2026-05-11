//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'roll_breakdown.g.dart';

/// Structured breakdown of a roll's dice pool — what each component contributed. The server enforces `attribute + skill + gear + modifier + helpers === pool` when both `breakdown` and `pool` are supplied on a `RollCreate` (catches UI math bugs). Each component is a non-negative integer 0..10; the sum bound is the same 0..20 envelope as `RollCreate.pool` (T-010 Block C).  Components: - `attribute` — the base attribute the skill is governed by   (1..5 typical, but stored as 0..10 to allow GM exotics). - `skill` — the skill rank. - `gear` — bonus dice from equipment / weapons. - `modifier` — situational ad-hoc modifier (positive only). - `helpers` — dice from cooperative helpers (ГЛАВА 3 §«Помощь»).  All five components are required when `breakdown` is supplied. 
///
/// Properties:
/// * [attribute] - Attribute contribution (e.g. STR 4 → 4).
/// * [skill] - Skill rank contribution (e.g. Force 2 → 2).
/// * [gear] - Bonus dice from equipment (weapon `bonus`, armor +1, gear-specific dice).
/// * [modifier] - Situational positive modifier (cover, range, ambush, etc).
/// * [helpers] - Dice from cooperative helpers (ST3001 ГЛАВА 3 §«Помощь»).
@BuiltValue()
abstract class RollBreakdown implements Built<RollBreakdown, RollBreakdownBuilder> {
  /// Attribute contribution (e.g. STR 4 → 4).
  @BuiltValueField(wireName: r'attribute')
  int get attribute;

  /// Skill rank contribution (e.g. Force 2 → 2).
  @BuiltValueField(wireName: r'skill')
  int get skill;

  /// Bonus dice from equipment (weapon `bonus`, armor +1, gear-specific dice).
  @BuiltValueField(wireName: r'gear')
  int get gear;

  /// Situational positive modifier (cover, range, ambush, etc).
  @BuiltValueField(wireName: r'modifier')
  int get modifier;

  /// Dice from cooperative helpers (ST3001 ГЛАВА 3 §«Помощь»).
  @BuiltValueField(wireName: r'helpers')
  int get helpers;

  RollBreakdown._();

  factory RollBreakdown([void updates(RollBreakdownBuilder b)]) = _$RollBreakdown;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RollBreakdownBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RollBreakdown> get serializer => _$RollBreakdownSerializer();
}

class _$RollBreakdownSerializer implements PrimitiveSerializer<RollBreakdown> {
  @override
  final Iterable<Type> types = const [RollBreakdown, _$RollBreakdown];

  @override
  final String wireName = r'RollBreakdown';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RollBreakdown object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'attribute';
    yield serializers.serialize(
      object.attribute,
      specifiedType: const FullType(int),
    );
    yield r'skill';
    yield serializers.serialize(
      object.skill,
      specifiedType: const FullType(int),
    );
    yield r'gear';
    yield serializers.serialize(
      object.gear,
      specifiedType: const FullType(int),
    );
    yield r'modifier';
    yield serializers.serialize(
      object.modifier,
      specifiedType: const FullType(int),
    );
    yield r'helpers';
    yield serializers.serialize(
      object.helpers,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RollBreakdown object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RollBreakdownBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'attribute':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.attribute = valueDes;
          break;
        case r'skill':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.skill = valueDes;
          break;
        case r'gear':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.gear = valueDes;
          break;
        case r'modifier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.modifier = valueDes;
          break;
        case r'helpers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.helpers = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RollBreakdown deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RollBreakdownBuilder();
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

