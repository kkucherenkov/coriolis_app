//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/encounter.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'encounter_list.g.dart';

/// Cursor-paginated list of encounters
///
/// Properties:
/// * [items] 
/// * [nextCursor] - Cursor for the next page; null when there are no more results
@BuiltValue()
abstract class EncounterList implements Built<EncounterList, EncounterListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Encounter> get items;

  /// Cursor for the next page; null when there are no more results
  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  EncounterList._();

  factory EncounterList([void updates(EncounterListBuilder b)]) = _$EncounterList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EncounterListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EncounterList> get serializer => _$EncounterListSerializer();
}

class _$EncounterListSerializer implements PrimitiveSerializer<EncounterList> {
  @override
  final Iterable<Type> types = const [EncounterList, _$EncounterList];

  @override
  final String wireName = r'EncounterList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EncounterList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Encounter)]),
    );
    yield r'nextCursor';
    yield object.nextCursor == null ? null : serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EncounterList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EncounterListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Encounter)]),
          ) as BuiltList<Encounter>;
          result.items.replace(valueDes);
          break;
        case r'nextCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EncounterList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EncounterListBuilder();
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

