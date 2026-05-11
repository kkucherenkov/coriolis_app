//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/combatant_type.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'combatant.g.dart';

/// A single participant in a combat encounter. Combatants store a snapshot of the source entity's stats (HP, armor, signature) at the moment of add. Mid-combat changes to the source PC's hp via the character sheet do NOT propagate to the combatant; the GM mutates `hpCurrent` directly on the combatant via `PATCH /api/v1/combatants/{id}`. This protects the tracker from accidental scrambling when a player auto-saves their sheet during combat.  `statusFlags` is intentionally a free-form `string[]` — see the field description for the canonical values listed in ST3001 ГЛАВА 5 «Раунды, ходы и инициатива» and the rationale for not enum-locking it. 
///
/// Properties:
/// * [id] - Opaque combatant identifier (cuid2)
/// * [encounterId] - Identifier of the parent encounter (cuid2)
/// * [combatantType] 
/// * [sourceId] - Identifier of the source entity. When `combatantType` is `pc` this is the `Character.id`; when `npc` it is the `Npc.id`. 
/// * [displayName] - Denormalised name of the combatant, copied from the source entity's `name` at add-time. Can be overridden in `CombatantCreate.displayName` or updated via `PATCH`. 
/// * [initiative] - Combat initiative value — the d6 base roll (1..6 per ST3001 ГЛАВА 5 «Раунды, ходы и инициатива» — «Бросьте по кубику за всех участников сражения») plus per-weapon initiative modifiers (ГЛАВА 6 «Инициатива» column on each weapon table) and any ambush / situational +2 from ГЛАВА 5 §«Повышение инициативы». The 1..10 range accommodates a base roll of 6 plus stacked modifiers (e.g. Посох +2 + ambush +2 = 10). Null until the encounter's initiative is rolled. Set server-side only. 
/// * [turnOrder] - 0-based index in the turn sequence after initiative is sorted. Null until initiative is rolled. Combatant at index 0 goes first. Set server-side only. 
/// * [hpCurrent] - Current hit points. **PRD override** — ST3001 ГЛАВА 5 «Урон» («запас пунктов здоровья не может опуститься ниже нуля») clamps HP at 0; the canonical mechanic is «Небоеспособность» the moment HP reaches 0. The greenfield product allows the field to go negative so the GM tracker can show damage overflow on a single attack (e.g. a 5-HP target taking 8 damage renders as `hpCurrent: -3` until the GM resets to 0 next round). UI clients SHOULD render negative values in red and surface a one-line note that the canon clamp applies for healing math (any heal first brings hpCurrent up to 0, then upward). 
/// * [hpMax] - Maximum hit points snapshotted from the source at add-time.
/// * [armor] - Armor rating (number of armor dice). Snapshotted from the source at add-time.
/// * [signature] - NPC sensor signature score, snapshotted from `Npc.signature` at add-time (defaults to 0 for PC combatants). **PRD override** — ST3001 has no per-combatant numeric `signature` stat; the canonical mechanic for being spotted / hidden is the `скрытность` skill (ГЛАВА 3 «СКРЫТНОСТЬ») rolled at the moment of detection. The field is reserved for future GM tooling (sensor sweep, ambush detection, ship-combat sensor pings — ГЛАВА 7 covers ship-scale sensor rules but assigns those values to the ship, not the crew). Today the field is mostly informational; clients SHOULD allow editing but MUST NOT silently use it to bypass a `скрытность` check. 
/// * [statusFlags] - Free-form short tags describing combat status conditions. The canonical taxonomy in ST3001 ГЛАВА 5 «Раунды, ходы и инициатива» covers `incapacitated` (HP at 0 — cannot act), `prone` (knocked down) and `covered` (behind cover for armor purposes). The field is intentionally not enum-locked: GMs are expected to invent scene-specific tags (e.g. `bleeding`, `restrained`, `zero-g`), and a hard schema would force migrations every time a campaign needs a new condition. Clients SHOULD render the canonical tags with icons; unknown tags MUST be shown as plain text and preserved on PATCH round-trips. 
/// * [notes] - Optional GM notes for this combatant in Markdown format (max 500 characters).
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class Combatant implements Built<Combatant, CombatantBuilder> {
  /// Opaque combatant identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Identifier of the parent encounter (cuid2)
  @BuiltValueField(wireName: r'encounterId')
  String get encounterId;

  @BuiltValueField(wireName: r'combatantType')
  CombatantType get combatantType;
  // enum combatantTypeEnum {  pc,  npc,  };

  /// Identifier of the source entity. When `combatantType` is `pc` this is the `Character.id`; when `npc` it is the `Npc.id`. 
  @BuiltValueField(wireName: r'sourceId')
  String get sourceId;

  /// Denormalised name of the combatant, copied from the source entity's `name` at add-time. Can be overridden in `CombatantCreate.displayName` or updated via `PATCH`. 
  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  /// Combat initiative value — the d6 base roll (1..6 per ST3001 ГЛАВА 5 «Раунды, ходы и инициатива» — «Бросьте по кубику за всех участников сражения») plus per-weapon initiative modifiers (ГЛАВА 6 «Инициатива» column on each weapon table) and any ambush / situational +2 from ГЛАВА 5 §«Повышение инициативы». The 1..10 range accommodates a base roll of 6 plus stacked modifiers (e.g. Посох +2 + ambush +2 = 10). Null until the encounter's initiative is rolled. Set server-side only. 
  @BuiltValueField(wireName: r'initiative')
  int? get initiative;

  /// 0-based index in the turn sequence after initiative is sorted. Null until initiative is rolled. Combatant at index 0 goes first. Set server-side only. 
  @BuiltValueField(wireName: r'turnOrder')
  int? get turnOrder;

  /// Current hit points. **PRD override** — ST3001 ГЛАВА 5 «Урон» («запас пунктов здоровья не может опуститься ниже нуля») clamps HP at 0; the canonical mechanic is «Небоеспособность» the moment HP reaches 0. The greenfield product allows the field to go negative so the GM tracker can show damage overflow on a single attack (e.g. a 5-HP target taking 8 damage renders as `hpCurrent: -3` until the GM resets to 0 next round). UI clients SHOULD render negative values in red and surface a one-line note that the canon clamp applies for healing math (any heal first brings hpCurrent up to 0, then upward). 
  @BuiltValueField(wireName: r'hpCurrent')
  int get hpCurrent;

  /// Maximum hit points snapshotted from the source at add-time.
  @BuiltValueField(wireName: r'hpMax')
  int get hpMax;

  /// Armor rating (number of armor dice). Snapshotted from the source at add-time.
  @BuiltValueField(wireName: r'armor')
  int get armor;

  /// NPC sensor signature score, snapshotted from `Npc.signature` at add-time (defaults to 0 for PC combatants). **PRD override** — ST3001 has no per-combatant numeric `signature` stat; the canonical mechanic for being spotted / hidden is the `скрытность` skill (ГЛАВА 3 «СКРЫТНОСТЬ») rolled at the moment of detection. The field is reserved for future GM tooling (sensor sweep, ambush detection, ship-combat sensor pings — ГЛАВА 7 covers ship-scale sensor rules but assigns those values to the ship, not the crew). Today the field is mostly informational; clients SHOULD allow editing but MUST NOT silently use it to bypass a `скрытность` check. 
  @BuiltValueField(wireName: r'signature')
  int get signature;

  /// Free-form short tags describing combat status conditions. The canonical taxonomy in ST3001 ГЛАВА 5 «Раунды, ходы и инициатива» covers `incapacitated` (HP at 0 — cannot act), `prone` (knocked down) and `covered` (behind cover for armor purposes). The field is intentionally not enum-locked: GMs are expected to invent scene-specific tags (e.g. `bleeding`, `restrained`, `zero-g`), and a hard schema would force migrations every time a campaign needs a new condition. Clients SHOULD render the canonical tags with icons; unknown tags MUST be shown as plain text and preserved on PATCH round-trips. 
  @BuiltValueField(wireName: r'statusFlags')
  BuiltList<String> get statusFlags;

  /// Optional GM notes for this combatant in Markdown format (max 500 characters).
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  Combatant._();

  factory Combatant([void updates(CombatantBuilder b)]) = _$Combatant;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CombatantBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Combatant> get serializer => _$CombatantSerializer();
}

class _$CombatantSerializer implements PrimitiveSerializer<Combatant> {
  @override
  final Iterable<Type> types = const [Combatant, _$Combatant];

  @override
  final String wireName = r'Combatant';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Combatant object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'encounterId';
    yield serializers.serialize(
      object.encounterId,
      specifiedType: const FullType(String),
    );
    yield r'combatantType';
    yield serializers.serialize(
      object.combatantType,
      specifiedType: const FullType(CombatantType),
    );
    yield r'sourceId';
    yield serializers.serialize(
      object.sourceId,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'initiative';
    yield object.initiative == null ? null : serializers.serialize(
      object.initiative,
      specifiedType: const FullType.nullable(int),
    );
    yield r'turnOrder';
    yield object.turnOrder == null ? null : serializers.serialize(
      object.turnOrder,
      specifiedType: const FullType.nullable(int),
    );
    yield r'hpCurrent';
    yield serializers.serialize(
      object.hpCurrent,
      specifiedType: const FullType(int),
    );
    yield r'hpMax';
    yield serializers.serialize(
      object.hpMax,
      specifiedType: const FullType(int),
    );
    yield r'armor';
    yield serializers.serialize(
      object.armor,
      specifiedType: const FullType(int),
    );
    yield r'signature';
    yield serializers.serialize(
      object.signature,
      specifiedType: const FullType(int),
    );
    yield r'statusFlags';
    yield serializers.serialize(
      object.statusFlags,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'notes';
    yield object.notes == null ? null : serializers.serialize(
      object.notes,
      specifiedType: const FullType.nullable(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Combatant object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CombatantBuilder result,
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
        case r'encounterId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.encounterId = valueDes;
          break;
        case r'combatantType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CombatantType),
          ) as CombatantType;
          result.combatantType = valueDes;
          break;
        case r'sourceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceId = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'initiative':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.initiative = valueDes;
          break;
        case r'turnOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.turnOrder = valueDes;
          break;
        case r'hpCurrent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.hpCurrent = valueDes;
          break;
        case r'hpMax':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.hpMax = valueDes;
          break;
        case r'armor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.armor = valueDes;
          break;
        case r'signature':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.signature = valueDes;
          break;
        case r'statusFlags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.statusFlags.replace(valueDes);
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Combatant deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CombatantBuilder();
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

