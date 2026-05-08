//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/crew_slot.dart';
import 'package:app_api_client/src/model/ship_hull.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_module.dart';
import 'package:app_api_client/src/model/ship_class.dart';
import 'package:app_api_client/src/model/ship_energy.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship.g.dart';

/// Full Ship DTO as returned by the v1 API. Ship stats correspond to ST3001 ГЛАВА 7 Table 7.5 base stats, modified by the installed modules and upgrades.  `hull.max` and `energy.max` are tracked as explicit editable values (not derived) because they can be altered by upgrades (Прочный корпус +1 hull, Мощный реактор +1 energy). `maneuverability` and `signature` are signed integers (negative values are valid per the class table). 
///
/// Properties:
/// * [id] - Opaque ship identifier (cuid2)
/// * [ownerId] - Identifier of the owning user (cuid2)
/// * [name] - Ship name (1–80 characters)
/// * [class_] 
/// * [model] - Model / shipyard name (e.g. \"Helebian Class III freighter\")
/// * [registry] - Registry number / transponder code (e.g. \"KUA-7741-M\")
/// * [hull] 
/// * [energy] 
/// * [armor] - Armor rating — number of dice rolled for the armor check (Броня)
/// * [maneuverability] - Maneuverability modifier (Манёвренность). Signed integer — negative for large classes (Class IV is −1, Class V is −2). Affects pilot skill checks in ship combat per ST3001 ГЛАВА 7. 
/// * [signature] - Signature modifier (Заметность). Signed integer. Negative values mean the ship is harder to detect; positive values mean it is more visible. Applied to opponent sensor checks per ГЛАВА 7. 
/// * [speed] - Speed in astronomical units per day (Скорость per ГЛАВА 7 Table 7.5)
/// * [cargoCapacity] - Total cargo capacity in tonnes across all hold modules (Вместимость per ГЛАВА 7 Table 7.6: Class III = 50 tonnes). 
/// * [modules] - Installed modules including the three mandatory ones (BRIDGE, REACTOR, DRIVE). Optional modules consume the class module-slot budget. 
/// * [crew] - Crew assignment roster
/// * [problems] - List of active ship problems (free-text entries, e.g. damage effects or wear-and-tear notes per ГЛАВА 7 wear table). 
/// * [history] - Free-form ship history / background text (Markdown)
/// * [notes] - GM / player operational notes (Markdown)
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class Ship implements Built<Ship, ShipBuilder> {
  /// Opaque ship identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Identifier of the owning user (cuid2)
  @BuiltValueField(wireName: r'ownerId')
  String get ownerId;

  /// Ship name (1–80 characters)
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'class')
  ShipClass get class_;
  // enum class_Enum {  fighter,  shuttle,  torpedo-boat,  light-freighter,  light-passenger,  courier-yacht,  clipper,  patrol-boat,  gunboat,  assault-ship,  blockade-runner,  pleasure-yacht,  flying-circus,  prospector,  rescue-ship,  passenger-liner,  heavy-freighter,  cruiser,  destroyer,  heavy-cruiser,  };

  /// Model / shipyard name (e.g. \"Helebian Class III freighter\")
  @BuiltValueField(wireName: r'model')
  String? get model;

  /// Registry number / transponder code (e.g. \"KUA-7741-M\")
  @BuiltValueField(wireName: r'registry')
  String? get registry;

  @BuiltValueField(wireName: r'hull')
  ShipHull get hull;

  @BuiltValueField(wireName: r'energy')
  ShipEnergy get energy;

  /// Armor rating — number of dice rolled for the armor check (Броня)
  @BuiltValueField(wireName: r'armor')
  int get armor;

  /// Maneuverability modifier (Манёвренность). Signed integer — negative for large classes (Class IV is −1, Class V is −2). Affects pilot skill checks in ship combat per ST3001 ГЛАВА 7. 
  @BuiltValueField(wireName: r'maneuverability')
  int get maneuverability;

  /// Signature modifier (Заметность). Signed integer. Negative values mean the ship is harder to detect; positive values mean it is more visible. Applied to opponent sensor checks per ГЛАВА 7. 
  @BuiltValueField(wireName: r'signature')
  int get signature;

  /// Speed in astronomical units per day (Скорость per ГЛАВА 7 Table 7.5)
  @BuiltValueField(wireName: r'speed')
  int get speed;

  /// Total cargo capacity in tonnes across all hold modules (Вместимость per ГЛАВА 7 Table 7.6: Class III = 50 tonnes). 
  @BuiltValueField(wireName: r'cargoCapacity')
  int get cargoCapacity;

  /// Installed modules including the three mandatory ones (BRIDGE, REACTOR, DRIVE). Optional modules consume the class module-slot budget. 
  @BuiltValueField(wireName: r'modules')
  BuiltList<ShipModule> get modules;

  /// Crew assignment roster
  @BuiltValueField(wireName: r'crew')
  BuiltList<CrewSlot> get crew;

  /// List of active ship problems (free-text entries, e.g. damage effects or wear-and-tear notes per ГЛАВА 7 wear table). 
  @BuiltValueField(wireName: r'problems')
  BuiltList<String> get problems;

  /// Free-form ship history / background text (Markdown)
  @BuiltValueField(wireName: r'history')
  String? get history;

  /// GM / player operational notes (Markdown)
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  Ship._();

  factory Ship([void updates(ShipBuilder b)]) = _$Ship;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Ship> get serializer => _$ShipSerializer();
}

class _$ShipSerializer implements PrimitiveSerializer<Ship> {
  @override
  final Iterable<Type> types = const [Ship, _$Ship];

  @override
  final String wireName = r'Ship';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Ship object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'ownerId';
    yield serializers.serialize(
      object.ownerId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'class';
    yield serializers.serialize(
      object.class_,
      specifiedType: const FullType(ShipClass),
    );
    yield r'model';
    yield object.model == null ? null : serializers.serialize(
      object.model,
      specifiedType: const FullType.nullable(String),
    );
    yield r'registry';
    yield object.registry == null ? null : serializers.serialize(
      object.registry,
      specifiedType: const FullType.nullable(String),
    );
    yield r'hull';
    yield serializers.serialize(
      object.hull,
      specifiedType: const FullType(ShipHull),
    );
    yield r'energy';
    yield serializers.serialize(
      object.energy,
      specifiedType: const FullType(ShipEnergy),
    );
    yield r'armor';
    yield serializers.serialize(
      object.armor,
      specifiedType: const FullType(int),
    );
    yield r'maneuverability';
    yield serializers.serialize(
      object.maneuverability,
      specifiedType: const FullType(int),
    );
    yield r'signature';
    yield serializers.serialize(
      object.signature,
      specifiedType: const FullType(int),
    );
    yield r'speed';
    yield serializers.serialize(
      object.speed,
      specifiedType: const FullType(int),
    );
    yield r'cargoCapacity';
    yield serializers.serialize(
      object.cargoCapacity,
      specifiedType: const FullType(int),
    );
    yield r'modules';
    yield serializers.serialize(
      object.modules,
      specifiedType: const FullType(BuiltList, [FullType(ShipModule)]),
    );
    yield r'crew';
    yield serializers.serialize(
      object.crew,
      specifiedType: const FullType(BuiltList, [FullType(CrewSlot)]),
    );
    yield r'problems';
    yield serializers.serialize(
      object.problems,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'history';
    yield object.history == null ? null : serializers.serialize(
      object.history,
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
    Ship object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipBuilder result,
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
        case r'ownerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ownerId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'class':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipClass),
          ) as ShipClass;
          result.class_ = valueDes;
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
            specifiedType: const FullType(ShipHull),
          ) as ShipHull;
          result.hull.replace(valueDes);
          break;
        case r'energy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipEnergy),
          ) as ShipEnergy;
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
        case r'cargoCapacity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cargoCapacity = valueDes;
          break;
        case r'modules':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ShipModule)]),
          ) as BuiltList<ShipModule>;
          result.modules.replace(valueDes);
          break;
        case r'crew':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CrewSlot)]),
          ) as BuiltList<CrewSlot>;
          result.crew.replace(valueDes);
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
  Ship deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipBuilder();
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

