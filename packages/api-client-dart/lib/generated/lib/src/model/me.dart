//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me.g.dart';

/// The authenticated user's profile as exposed by the v1 API. Fields sourced from the Better Auth `user` table. `deletedAt` is an internal soft-delete flag and is never surfaced here — deleted users receive a 404 because their sessions are revoked at deletion time. 
///
/// Properties:
/// * [id] - Opaque user identifier issued by Better Auth (cuid2)
/// * [email] - Primary email address. Read-only via this API.
/// * [displayName] - User-chosen display name shown in share-link banners and the avatar menu. Null when the user has not set one yet. 
/// * [createdAt] - ISO-8601 instant when the account was created. Read-only via this API.
/// * [theme] - UI theme preference. Synced across web + mobile so a player who toggles high-contrast on one device sees it everywhere. `dark` is the default; `high-contrast` increases colour contrast for users who need improved readability. 
@BuiltValue()
abstract class Me implements Built<Me, MeBuilder> {
  /// Opaque user identifier issued by Better Auth (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Primary email address. Read-only via this API.
  @BuiltValueField(wireName: r'email')
  String get email;

  /// User-chosen display name shown in share-link banners and the avatar menu. Null when the user has not set one yet. 
  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  /// ISO-8601 instant when the account was created. Read-only via this API.
  @BuiltValueField(wireName: r'createdAt')
  DateTime? get createdAt;

  /// UI theme preference. Synced across web + mobile so a player who toggles high-contrast on one device sees it everywhere. `dark` is the default; `high-contrast` increases colour contrast for users who need improved readability. 
  @BuiltValueField(wireName: r'theme')
  MeThemeEnum? get theme;
  // enum themeEnum {  dark,  high-contrast,  };

  Me._();

  factory Me([void updates(MeBuilder b)]) = _$Me;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeBuilder b) => b
      ..theme = MeThemeEnum.valueOf('dark');

  @BuiltValueSerializer(custom: true)
  static Serializer<Me> get serializer => _$MeSerializer();
}

class _$MeSerializer implements PrimitiveSerializer<Me> {
  @override
  final Iterable<Type> types = const [Me, _$Me];

  @override
  final String wireName = r'Me';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Me object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield object.displayName == null ? null : serializers.serialize(
      object.displayName,
      specifiedType: const FullType.nullable(String),
    );
    yield r'createdAt';
    yield object.createdAt == null ? null : serializers.serialize(
      object.createdAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    if (object.theme != null) {
      yield r'theme';
      yield serializers.serialize(
        object.theme,
        specifiedType: const FullType(MeThemeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Me object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeBuilder result,
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
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.displayName = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'theme':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeThemeEnum),
          ) as MeThemeEnum;
          result.theme = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Me deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeBuilder();
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

class MeThemeEnum extends EnumClass {

  /// UI theme preference. Synced across web + mobile so a player who toggles high-contrast on one device sees it everywhere. `dark` is the default; `high-contrast` increases colour contrast for users who need improved readability. 
  @BuiltValueEnumConst(wireName: r'dark')
  static const MeThemeEnum dark = _$meThemeEnum_dark;
  /// UI theme preference. Synced across web + mobile so a player who toggles high-contrast on one device sees it everywhere. `dark` is the default; `high-contrast` increases colour contrast for users who need improved readability. 
  @BuiltValueEnumConst(wireName: r'high-contrast')
  static const MeThemeEnum highContrast = _$meThemeEnum_highContrast;

  static Serializer<MeThemeEnum> get serializer => _$meThemeEnumSerializer;

  const MeThemeEnum._(String name): super(name);

  static BuiltSet<MeThemeEnum> get values => _$meThemeEnumValues;
  static MeThemeEnum valueOf(String name) => _$meThemeEnumValueOf(name);
}

