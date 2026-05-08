//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/ship_create_energy.dart';
import 'package:app_api_client/src/model/ship_create_hull.dart';
import 'package:app_api_client/src/model/ship_class.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_create.g.dart';

/// Payload for `POST /api/v1/ships`. `name` and `class` are required. Server populates base stats from the class table (ST3001 ГЛАВА 7 Table 7.5) when not explicitly provided. The three mandatory modules (BRIDGE, REACTOR, DRIVE) are created automatically. 
///
/// Properties:
/// * [name] 
/// * [class_] 
/// * [model] 
/// * [registry] 
/// * [hull] 
/// * [energy] 
/// * [armor] 
/// * [maneuverability] 
/// * [signature] 
/// * [speed] 
/// * [notes] 
/// * [history] 
@BuiltValue()
abstract class ShipCreate implements Built<ShipCreate, ShipCreateBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'class')
  ShipClass get class_;
  // enum class_Enum {  fighter,  shuttle,  torpedo-boat,  light-freighter,  light-passenger,  courier-yacht,  clipper,  patrol-boat,  gunboat,  assault-ship,  blockade-runner,  pleasure-yacht,  flying-circus,  prospector,  rescue-ship,  passenger-liner,  heavy-freighter,  cruiser,  destroyer,  heavy-cruiser,  };

  @BuiltValueField(wireName: r'model')
  String? get model;

  @BuiltValueField(wireName: r'registry')
  String? get registry;

  @BuiltValueField(wireName: r'hull')
  ShipCreateHull? get hull;

  @BuiltValueField(wireName: r'energy')
  ShipCreateEnergy? get energy;

  @BuiltValueField(wireName: r'armor')
  int? get armor;

  @BuiltValueField(wireName: r'maneuverability')
  int? get maneuverability;

  @BuiltValueField(wireName: r'signature')
  int? get signature;

  @BuiltValueField(wireName: r'speed')
  int? get speed;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'history')
  String? get history;

  ShipCreate._();

  factory ShipCreate([void updates(ShipCreateBuilder b)]) = _$ShipCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipCreate> get serializer => _$ShipCreateSerializer();
}

class _$ShipCreateSerializer implements PrimitiveSerializer<ShipCreate> {
  @override
  final Iterable<Type> types = const [ShipCreate, _$ShipCreate];

  @override
  final String wireName = r'ShipCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
        specifiedType: const FullType(ShipCreateHull),
      );
    }
    if (object.energy != null) {
      yield r'energy';
      yield serializers.serialize(
        object.energy,
        specifiedType: const FullType(ShipCreateEnergy),
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
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.history != null) {
      yield r'history';
      yield serializers.serialize(
        object.history,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipCreateBuilder result,
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
            specifiedType: const FullType(ShipCreateHull),
          ) as ShipCreateHull;
          result.hull.replace(valueDes);
          break;
        case r'energy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipCreateEnergy),
          ) as ShipCreateEnergy;
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
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'history':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.history = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShipCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipCreateBuilder();
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

