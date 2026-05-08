//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_energy.g.dart';

/// Reactor energy (Энергия in ST3001 ГЛАВА 7)
///
/// Properties:
/// * [current] - Energy points currently available for allocation
/// * [max] - Maximum energy points (base per class + Мощный реактор upgrades)
@BuiltValue()
abstract class ShipEnergy implements Built<ShipEnergy, ShipEnergyBuilder> {
  /// Energy points currently available for allocation
  @BuiltValueField(wireName: r'current')
  int get current;

  /// Maximum energy points (base per class + Мощный реактор upgrades)
  @BuiltValueField(wireName: r'max')
  int get max;

  ShipEnergy._();

  factory ShipEnergy([void updates(ShipEnergyBuilder b)]) = _$ShipEnergy;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipEnergyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipEnergy> get serializer => _$ShipEnergySerializer();
}

class _$ShipEnergySerializer implements PrimitiveSerializer<ShipEnergy> {
  @override
  final Iterable<Type> types = const [ShipEnergy, _$ShipEnergy];

  @override
  final String wireName = r'ShipEnergy';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipEnergy object, {
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
    ShipEnergy object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipEnergyBuilder result,
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
  ShipEnergy deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipEnergyBuilder();
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

