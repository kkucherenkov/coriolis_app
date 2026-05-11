//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/encounter_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'encounter.g.dart';

/// A single combat encounter owned by a game session. The Encounter carries the combat metadata (status, round, active turn) but does NOT embed the combatant list — combatants live on a separate sub-resource added in Block 3. 
///
/// Properties:
/// * [id] - Opaque encounter identifier (cuid2)
/// * [gameSessionId] - Identifier of the parent game session (cuid2)
/// * [name] - Short descriptive name for the encounter (1–80 characters)
/// * [status] 
/// * [round] - Current combat round. Starts at 0 while in `setup`. Bumped to 1 when the encounter transitions to `active`. Increments by 1 each time the turn order wraps back to the first combatant (Block 4 turn-advance operation). 
/// * [activeCombatantId] - Identifier of the combatant whose turn it currently is. Null when `status` is `setup` (initiative not yet rolled) or `ended` (combat closed). Set by the server on the `setup → active` transition and updated by the turn-advance operation (Block 4). 
/// * [notes] - Optional GM notes for the encounter in Markdown format (max 4096 characters). May be edited at any status. 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue(instantiable: false)
abstract class Encounter  {
  /// Opaque encounter identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Identifier of the parent game session (cuid2)
  @BuiltValueField(wireName: r'gameSessionId')
  String get gameSessionId;

  /// Short descriptive name for the encounter (1–80 characters)
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'status')
  EncounterStatus get status;
  // enum statusEnum {  setup,  active,  ended,  };

  /// Current combat round. Starts at 0 while in `setup`. Bumped to 1 when the encounter transitions to `active`. Increments by 1 each time the turn order wraps back to the first combatant (Block 4 turn-advance operation). 
  @BuiltValueField(wireName: r'round')
  int get round;

  /// Identifier of the combatant whose turn it currently is. Null when `status` is `setup` (initiative not yet rolled) or `ended` (combat closed). Set by the server on the `setup → active` transition and updated by the turn-advance operation (Block 4). 
  @BuiltValueField(wireName: r'activeCombatantId')
  String? get activeCombatantId;

  /// Optional GM notes for the encounter in Markdown format (max 4096 characters). May be edited at any status. 
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueSerializer(custom: true)
  static Serializer<Encounter> get serializer => _$EncounterSerializer();
}

class _$EncounterSerializer implements PrimitiveSerializer<Encounter> {
  @override
  final Iterable<Type> types = const [Encounter];

  @override
  final String wireName = r'Encounter';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Encounter object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'gameSessionId';
    yield serializers.serialize(
      object.gameSessionId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EncounterStatus),
    );
    yield r'round';
    yield serializers.serialize(
      object.round,
      specifiedType: const FullType(int),
    );
    yield r'activeCombatantId';
    yield object.activeCombatantId == null ? null : serializers.serialize(
      object.activeCombatantId,
      specifiedType: const FullType.nullable(String),
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
    Encounter object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  Encounter deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($Encounter)) as $Encounter;
  }
}

/// a concrete implementation of [Encounter], since [Encounter] is not instantiable
@BuiltValue(instantiable: true)
abstract class $Encounter implements Encounter, Built<$Encounter, $EncounterBuilder> {
  $Encounter._();

  factory $Encounter([void Function($EncounterBuilder)? updates]) = _$$Encounter;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($EncounterBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$Encounter> get serializer => _$$EncounterSerializer();
}

class _$$EncounterSerializer implements PrimitiveSerializer<$Encounter> {
  @override
  final Iterable<Type> types = const [$Encounter, _$$Encounter];

  @override
  final String wireName = r'$Encounter';

  @override
  Object serialize(
    Serializers serializers,
    $Encounter object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(Encounter))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EncounterBuilder result,
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
        case r'gameSessionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.gameSessionId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EncounterStatus),
          ) as EncounterStatus;
          result.status = valueDes;
          break;
        case r'round':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.round = valueDes;
          break;
        case r'activeCombatantId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.activeCombatantId = valueDes;
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
  $Encounter deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $EncounterBuilder();
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

