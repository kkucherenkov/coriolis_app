//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'combatant_update.g.dart';

/// PATCH payload for `PATCH /api/v1/combatants/{id}`. All fields are optional; omitted fields are left unchanged.  `combatantType` and `sourceId` are immutable and absent from this schema. `initiative` and `turnOrder` are read-only and can only be set via the Block 4 initiative operations. 
///
/// Properties:
/// * [displayName] - Update the combatant display name.
/// * [hpCurrent] - Update current hit points (may go negative).
/// * [armor] - Update armor rating.
/// * [signature] - Update the mystic signature value.
/// * [statusFlags] - Replace the full set of status flags. Well-known values: `broken`, `exposed`, `covered`, `prone`. 
/// * [notes] - Update GM notes in Markdown (max 500 characters).
/// * [initiative] - Read-only. Initiative is set exclusively by the Block 4 initiative-roll operation. This field is listed here for documentation purposes only; any value supplied in a PATCH request will be ignored. 
/// * [turnOrder] - Read-only. Turn order index is set exclusively by the Block 4 initiative operations. This field is listed here for documentation purposes only; any value supplied in a PATCH request will be ignored. 
@BuiltValue()
abstract class CombatantUpdate implements Built<CombatantUpdate, CombatantUpdateBuilder> {
  /// Update the combatant display name.
  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  /// Update current hit points (may go negative).
  @BuiltValueField(wireName: r'hpCurrent')
  int? get hpCurrent;

  /// Update armor rating.
  @BuiltValueField(wireName: r'armor')
  int? get armor;

  /// Update the mystic signature value.
  @BuiltValueField(wireName: r'signature')
  int? get signature;

  /// Replace the full set of status flags. Well-known values: `broken`, `exposed`, `covered`, `prone`. 
  @BuiltValueField(wireName: r'statusFlags')
  BuiltList<String>? get statusFlags;

  /// Update GM notes in Markdown (max 500 characters).
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// Read-only. Initiative is set exclusively by the Block 4 initiative-roll operation. This field is listed here for documentation purposes only; any value supplied in a PATCH request will be ignored. 
  @BuiltValueField(wireName: r'initiative')
  int? get initiative;

  /// Read-only. Turn order index is set exclusively by the Block 4 initiative operations. This field is listed here for documentation purposes only; any value supplied in a PATCH request will be ignored. 
  @BuiltValueField(wireName: r'turnOrder')
  int? get turnOrder;

  CombatantUpdate._();

  factory CombatantUpdate([void updates(CombatantUpdateBuilder b)]) = _$CombatantUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CombatantUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CombatantUpdate> get serializer => _$CombatantUpdateSerializer();
}

class _$CombatantUpdateSerializer implements PrimitiveSerializer<CombatantUpdate> {
  @override
  final Iterable<Type> types = const [CombatantUpdate, _$CombatantUpdate];

  @override
  final String wireName = r'CombatantUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CombatantUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.displayName != null) {
      yield r'displayName';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType(String),
      );
    }
    if (object.hpCurrent != null) {
      yield r'hpCurrent';
      yield serializers.serialize(
        object.hpCurrent,
        specifiedType: const FullType(int),
      );
    }
    if (object.armor != null) {
      yield r'armor';
      yield serializers.serialize(
        object.armor,
        specifiedType: const FullType(int),
      );
    }
    if (object.signature != null) {
      yield r'signature';
      yield serializers.serialize(
        object.signature,
        specifiedType: const FullType(int),
      );
    }
    if (object.statusFlags != null) {
      yield r'statusFlags';
      yield serializers.serialize(
        object.statusFlags,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.initiative != null) {
      yield r'initiative';
      yield serializers.serialize(
        object.initiative,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.turnOrder != null) {
      yield r'turnOrder';
      yield serializers.serialize(
        object.turnOrder,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CombatantUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CombatantUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'hpCurrent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.hpCurrent = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CombatantUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CombatantUpdateBuilder();
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

