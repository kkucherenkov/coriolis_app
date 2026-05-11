//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/me_export_user.dart';
import 'package:app_api_client/src/model/ship.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/me_export_game_session.dart';
import 'package:app_api_client/src/model/character.dart';
import 'package:app_api_client/src/model/npc.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_export_bundle.g.dart';

/// Versioned envelope returned by `GET /api/v1/me/export`. `$schemaVersion` is a string literal so future shape changes can branch deterministically.  NPCs are flat at the bundle top level rather than nested under sessions, because NPCs are user-owned in this codebase (not session-owned). 
///
/// Properties:
/// * [dollarSchemaVersion] 
/// * [exportedAt] 
/// * [user] 
/// * [characters] 
/// * [ships] 
/// * [npcs] 
/// * [gameSessions] 
@BuiltValue()
abstract class MeExportBundle implements Built<MeExportBundle, MeExportBundleBuilder> {
  @BuiltValueField(wireName: r'$schemaVersion')
  MeExportBundleDollarSchemaVersionEnum get dollarSchemaVersion;
  // enum dollarSchemaVersionEnum {  1,  };

  @BuiltValueField(wireName: r'exportedAt')
  DateTime get exportedAt;

  @BuiltValueField(wireName: r'user')
  MeExportUser get user;

  @BuiltValueField(wireName: r'characters')
  BuiltList<Character> get characters;

  @BuiltValueField(wireName: r'ships')
  BuiltList<Ship> get ships;

  @BuiltValueField(wireName: r'npcs')
  BuiltList<Npc> get npcs;

  @BuiltValueField(wireName: r'gameSessions')
  BuiltList<MeExportGameSession> get gameSessions;

  MeExportBundle._();

  factory MeExportBundle([void updates(MeExportBundleBuilder b)]) = _$MeExportBundle;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeExportBundleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeExportBundle> get serializer => _$MeExportBundleSerializer();
}

class _$MeExportBundleSerializer implements PrimitiveSerializer<MeExportBundle> {
  @override
  final Iterable<Type> types = const [MeExportBundle, _$MeExportBundle];

  @override
  final String wireName = r'MeExportBundle';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeExportBundle object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'$schemaVersion';
    yield serializers.serialize(
      object.dollarSchemaVersion,
      specifiedType: const FullType(MeExportBundleDollarSchemaVersionEnum),
    );
    yield r'exportedAt';
    yield serializers.serialize(
      object.exportedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(MeExportUser),
    );
    yield r'characters';
    yield serializers.serialize(
      object.characters,
      specifiedType: const FullType(BuiltList, [FullType(Character)]),
    );
    yield r'ships';
    yield serializers.serialize(
      object.ships,
      specifiedType: const FullType(BuiltList, [FullType(Ship)]),
    );
    yield r'npcs';
    yield serializers.serialize(
      object.npcs,
      specifiedType: const FullType(BuiltList, [FullType(Npc)]),
    );
    yield r'gameSessions';
    yield serializers.serialize(
      object.gameSessions,
      specifiedType: const FullType(BuiltList, [FullType(MeExportGameSession)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeExportBundle object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeExportBundleBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'$schemaVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeExportBundleDollarSchemaVersionEnum),
          ) as MeExportBundleDollarSchemaVersionEnum;
          result.dollarSchemaVersion = valueDes;
          break;
        case r'exportedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.exportedAt = valueDes;
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeExportUser),
          ) as MeExportUser;
          result.user.replace(valueDes);
          break;
        case r'characters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Character)]),
          ) as BuiltList<Character>;
          result.characters.replace(valueDes);
          break;
        case r'ships':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Ship)]),
          ) as BuiltList<Ship>;
          result.ships.replace(valueDes);
          break;
        case r'npcs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Npc)]),
          ) as BuiltList<Npc>;
          result.npcs.replace(valueDes);
          break;
        case r'gameSessions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MeExportGameSession)]),
          ) as BuiltList<MeExportGameSession>;
          result.gameSessions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeExportBundle deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeExportBundleBuilder();
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

class MeExportBundleDollarSchemaVersionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'1')
  static const MeExportBundleDollarSchemaVersionEnum n1 = _$meExportBundleDollarSchemaVersionEnum_n1;

  static Serializer<MeExportBundleDollarSchemaVersionEnum> get serializer => _$meExportBundleDollarSchemaVersionEnumSerializer;

  const MeExportBundleDollarSchemaVersionEnum._(String name): super(name);

  static BuiltSet<MeExportBundleDollarSchemaVersionEnum> get values => _$meExportBundleDollarSchemaVersionEnumValues;
  static MeExportBundleDollarSchemaVersionEnum valueOf(String name) => _$meExportBundleDollarSchemaVersionEnumValueOf(name);
}

