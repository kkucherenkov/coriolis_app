//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/combatant.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'combatant_list.g.dart';

/// Non-paginated list of combatants for an encounter. Typical encounters have fewer than 20 combatants; a pagination cursor would add unnecessary complexity for no practical benefit. 
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class CombatantList implements Built<CombatantList, CombatantListBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Combatant> get items;

  CombatantList._();

  factory CombatantList([void updates(CombatantListBuilder b)]) = _$CombatantList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CombatantListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CombatantList> get serializer => _$CombatantListSerializer();
}

class _$CombatantListSerializer implements PrimitiveSerializer<CombatantList> {
  @override
  final Iterable<Type> types = const [CombatantList, _$CombatantList];

  @override
  final String wireName = r'CombatantList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CombatantList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Combatant)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CombatantList object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CombatantListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Combatant)]),
          ) as BuiltList<Combatant>;
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
  CombatantList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CombatantListBuilder();
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

