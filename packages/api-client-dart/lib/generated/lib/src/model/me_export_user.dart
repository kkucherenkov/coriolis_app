//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_export_user.g.dart';

/// Minimal user envelope for the JSON export. Intentionally excludes `email` — the dump may be saved to disk or shared, and auth-side identifiers should not leak into the file. The opaque `id` is retained so a future re-import path can disambiguate. 
///
/// Properties:
/// * [id] 
/// * [displayName] 
/// * [locale] - BCP-47 locale tag (e.g. `en`, `ru`).
@BuiltValue()
abstract class MeExportUser implements Built<MeExportUser, MeExportUserBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  /// BCP-47 locale tag (e.g. `en`, `ru`).
  @BuiltValueField(wireName: r'locale')
  String get locale;

  MeExportUser._();

  factory MeExportUser([void updates(MeExportUserBuilder b)]) = _$MeExportUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeExportUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeExportUser> get serializer => _$MeExportUserSerializer();
}

class _$MeExportUserSerializer implements PrimitiveSerializer<MeExportUser> {
  @override
  final Iterable<Type> types = const [MeExportUser, _$MeExportUser];

  @override
  final String wireName = r'MeExportUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeExportUser object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield object.displayName == null ? null : serializers.serialize(
      object.displayName,
      specifiedType: const FullType.nullable(String),
    );
    yield r'locale';
    yield serializers.serialize(
      object.locale,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeExportUser object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeExportUserBuilder result,
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
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.displayName = valueDes;
          break;
        case r'locale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.locale = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeExportUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeExportUserBuilder();
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

