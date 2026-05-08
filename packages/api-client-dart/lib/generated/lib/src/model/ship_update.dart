//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_update_hull.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_update.g.dart';

/// PATCH payload for `PATCH /api/v1/ships/{id}`. All fields optional. Read-only fields (`id`, `ownerId`, `createdAt`, `updatedAt`) are rejected with 400 if present. 
///
/// Properties:
/// * [name] 
/// * [model] 
/// * [registry] 
/// * [hull] 
/// * [energy] 
/// * [armor] 
/// * [maneuverability] 
/// * [signature] 
/// * [speed] 
/// * [problems] - Replaces the entire problems list when provided
/// * [history] 
/// * [notes] 
@BuiltValue()
abstract class ShipUpdate implements Built<ShipUpdate, ShipUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'registry')
  String? get registry;

  @BuiltValueField(wireName: r'hull')
  ShipUpdateHull? get hull;

  @BuiltValueField(wireName: r'energy')
  ShipUpdateHull? get energy;

  @BuiltValueField(wireName: r'armor')
  int? get armor;

  @BuiltValueField(wireName: r'maneuverability')
  int? get maneuverability;

  @BuiltValueField(wireName: r'signature')
  int? get signature;

  @BuiltValueField(wireName: r'speed')
  int? get speed;

  /// Replaces the entire problems list when provided
  @BuiltValueField(wireName: r'problems')
  BuiltList<String>? get problems;

  @BuiltValueField(wireName: r'history')
  String? get history;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipUpdate._();

  factory ShipUpdate([void updates(ShipUpdateBuilder b)]) = _$ShipUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipUpdate> get serializer => _$ShipUpdateSerializer();
}

class _$ShipUpdateSerializer implements PrimitiveSerializer<ShipUpdate> {
  @override
  final Iterable<Type> types = const [ShipUpdate, _$ShipUpdate];

  @override
  final String wireName = r'ShipUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.model != null) {
      yield r'model';
      yield serializers.serialize(
        object.model,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.registry != null) {
      yield r'registry';
      yield serializers.serialize(
        object.registry,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.hull != null) {
      yield r'hull';
      yield serializers.serialize(
        object.hull,
        specifiedType: const FullType(ShipUpdateHull),
      );
    }
    if (object.energy != null) {
      yield r'energy';
      yield serializers.serialize(
        object.energy,
        specifiedType: const FullType(ShipUpdateHull),
      );
    }
    if (object.armor != null) {
      yield r'armor';
      yield serializers.serialize(
        object.armor,
        specifiedType: const FullType(int),
      );
    }
    if (object.maneuverability != null) {
      yield r'maneuverability';
      yield serializers.serialize(
        object.maneuverability,
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
    if (object.speed != null) {
      yield r'speed';
      yield serializers.serialize(
        object.speed,
        specifiedType: const FullType(int),
      );
    }
    if (object.problems != null) {
      yield r'problems';
      yield serializers.serialize(
        object.problems,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.history != null) {
      yield r'history';
      yield serializers.serialize(
        object.history,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipUpdateBuilder result,
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
        case r'model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.model = valueDes;
          break;
        case r'registry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.registry = valueDes;
          break;
        case r'hull':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipUpdateHull),
          ) as ShipUpdateHull;
          result.hull.replace(valueDes);
          break;
        case r'energy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipUpdateHull),
          ) as ShipUpdateHull;
          result.energy.replace(valueDes);
          break;
        case r'armor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.armor = valueDes;
          break;
        case r'maneuverability':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maneuverability = valueDes;
          break;
        case r'signature':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.signature = valueDes;
          break;
        case r'speed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.speed = valueDes;
          break;
        case r'problems':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.problems.replace(valueDes);
          break;
        case r'history':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.history = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShipUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipUpdateBuilder();
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

