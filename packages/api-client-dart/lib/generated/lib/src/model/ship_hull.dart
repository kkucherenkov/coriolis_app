//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_hull.g.dart';

/// Structural integrity (Прочность in ST3001 ГЛАВА 7)
///
/// Properties:
/// * [current] - Current hull points
/// * [max] - Maximum hull points (base per class + Прочный корпус upgrades)
@BuiltValue()
abstract class ShipHull implements Built<ShipHull, ShipHullBuilder> {
  /// Current hull points
  @BuiltValueField(wireName: r'current')
  int get current;

  /// Maximum hull points (base per class + Прочный корпус upgrades)
  @BuiltValueField(wireName: r'max')
  int get max;

  ShipHull._();

  factory ShipHull([void updates(ShipHullBuilder b)]) = _$ShipHull;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipHullBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipHull> get serializer => _$ShipHullSerializer();
}

class _$ShipHullSerializer implements PrimitiveSerializer<ShipHull> {
  @override
  final Iterable<Type> types = const [ShipHull, _$ShipHull];

  @override
  final String wireName = r'ShipHull';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipHull object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'current';
    yield serializers.serialize(
      object.current,
      specifiedType: const FullType(int),
    );
    yield r'max';
    yield serializers.serialize(
      object.max,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipHull object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipHullBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.current = valueDes;
          break;
        case r'max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.max = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShipHull deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipHullBuilder();
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

