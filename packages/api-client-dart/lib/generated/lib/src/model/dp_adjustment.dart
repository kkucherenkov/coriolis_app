//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dp_adjustment.g.dart';

/// Payload for adjusting Darkness Points on a game session
///
/// Properties:
/// * [delta] - Positive to add DP, negative to remove DP. Must be non-zero. A negative delta is only accepted from the GM owner of the session. 
/// * [reason] - Optional human-readable reason for the adjustment
@BuiltValue()
abstract class DpAdjustment implements Built<DpAdjustment, DpAdjustmentBuilder> {
  /// Positive to add DP, negative to remove DP. Must be non-zero. A negative delta is only accepted from the GM owner of the session. 
  @BuiltValueField(wireName: r'delta')
  int get delta;

  /// Optional human-readable reason for the adjustment
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  DpAdjustment._();

  factory DpAdjustment([void updates(DpAdjustmentBuilder b)]) = _$DpAdjustment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DpAdjustmentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DpAdjustment> get serializer => _$DpAdjustmentSerializer();
}

class _$DpAdjustmentSerializer implements PrimitiveSerializer<DpAdjustment> {
  @override
  final Iterable<Type> types = const [DpAdjustment, _$DpAdjustment];

  @override
  final String wireName = r'DpAdjustment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DpAdjustment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'delta';
    yield serializers.serialize(
      object.delta,
      specifiedType: const FullType(int),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DpAdjustment object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DpAdjustmentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'delta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.delta = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DpAdjustment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DpAdjustmentBuilder();
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

