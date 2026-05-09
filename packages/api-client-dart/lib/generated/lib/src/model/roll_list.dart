//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/roll.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'roll_list.g.dart';

/// RollList
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class RollList implements Built<RollList, RollListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Roll> get items;

  RollList._();

  factory RollList([void updates(RollListBuilder b)]) = _$RollList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RollListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RollList> get serializer => _$RollListSerializer();
}

class _$RollListSerializer implements PrimitiveSerializer<RollList> {
  @override
  final Iterable<Type> types = const [RollList, _$RollList];

  @override
  final String wireName = r'RollList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RollList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Roll)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RollList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RollListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Roll)]),
          ) as BuiltList<Roll>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RollList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RollListBuilder();
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

