//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_create_hull.g.dart';

/// Override base hull stats from class table
///
/// Properties:
/// * [current] 
/// * [max] 
@BuiltValue()
abstract class ShipCreateHull implements Built<ShipCreateHull, ShipCreateHullBuilder> {
  @BuiltValueField(wireName: r'current')
  int? get current;

  @BuiltValueField(wireName: r'max')
  int? get max;

  ShipCreateHull._();

  factory ShipCreateHull([void updates(ShipCreateHullBuilder b)]) = _$ShipCreateHull;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipCreateHullBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipCreateHull> get serializer => _$ShipCreateHullSerializer();
}

class _$ShipCreateHullSerializer implements PrimitiveSerializer<ShipCreateHull> {
  @override
  final Iterable<Type> types = const [ShipCreateHull, _$ShipCreateHull];

  @override
  final String wireName = r'ShipCreateHull';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipCreateHull object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.current != null) {
      yield r'current';
      yield serializers.serialize(
        object.current,
        specifiedType: const FullType(int),
      );
    }
    if (object.max != null) {
      yield r'max';
      yield serializers.serialize(
        object.max,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShipCreateHull object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipCreateHullBuilder result,
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
  ShipCreateHull deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipCreateHullBuilder();
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

