//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'share_link.g.dart';

/// A share link grants anonymous read-only access to a character via the `/api/v1/public/character/{slug}` endpoint. 
///
/// Properties:
/// * [id] - Opaque share-link identifier (cuid2). Used for revocation.
/// * [slug] - 24-character URL-safe slug. Use in the public URL: `/api/v1/public/character/{slug}`. 
/// * [characterId] - ID of the character this link exposes.
/// * [includeGmNotes] - Whether the `notes` field is included in the public character response. Always false if not set at creation time. 
/// * [label] - Owner-assigned label for this link.
/// * [expiresAt] - Expiry instant. Null for permanent links.
/// * [revokedAt] - Revocation instant. Null if active. When set, the public endpoint returns 410 Gone. 
/// * [lastViewedAt] - ISO-8601 instant of the last recorded public view. Updated asynchronously (up to 60 seconds lag) via the view-tracker flush job. Null until the first view is flushed. 
/// * [viewCount] - Cumulative count of public views. Updated asynchronously; may lag by up to 60 seconds. 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class ShareLink implements Built<ShareLink, ShareLinkBuilder> {
  /// Opaque share-link identifier (cuid2). Used for revocation.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 24-character URL-safe slug. Use in the public URL: `/api/v1/public/character/{slug}`. 
  @BuiltValueField(wireName: r'slug')
  String get slug;

  /// ID of the character this link exposes.
  @BuiltValueField(wireName: r'characterId')
  String get characterId;

  /// Whether the `notes` field is included in the public character response. Always false if not set at creation time. 
  @BuiltValueField(wireName: r'includeGmNotes')
  bool get includeGmNotes;

  /// Owner-assigned label for this link.
  @BuiltValueField(wireName: r'label')
  String? get label;

  /// Expiry instant. Null for permanent links.
  @BuiltValueField(wireName: r'expiresAt')
  DateTime? get expiresAt;

  /// Revocation instant. Null if active. When set, the public endpoint returns 410 Gone. 
  @BuiltValueField(wireName: r'revokedAt')
  DateTime? get revokedAt;

  /// ISO-8601 instant of the last recorded public view. Updated asynchronously (up to 60 seconds lag) via the view-tracker flush job. Null until the first view is flushed. 
  @BuiltValueField(wireName: r'lastViewedAt')
  DateTime? get lastViewedAt;

  /// Cumulative count of public views. Updated asynchronously; may lag by up to 60 seconds. 
  @BuiltValueField(wireName: r'viewCount')
  int get viewCount;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  ShareLink._();

  factory ShareLink([void updates(ShareLinkBuilder b)]) = _$ShareLink;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShareLinkBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShareLink> get serializer => _$ShareLinkSerializer();
}

class _$ShareLinkSerializer implements PrimitiveSerializer<ShareLink> {
  @override
  final Iterable<Type> types = const [ShareLink, _$ShareLink];

  @override
  final String wireName = r'ShareLink';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShareLink object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'slug';
    yield serializers.serialize(
      object.slug,
      specifiedType: const FullType(String),
    );
    yield r'characterId';
    yield serializers.serialize(
      object.characterId,
      specifiedType: const FullType(String),
    );
    yield r'includeGmNotes';
    yield serializers.serialize(
      object.includeGmNotes,
      specifiedType: const FullType(bool),
    );
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'expiresAt';
    yield object.expiresAt == null ? null : serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'revokedAt';
    yield object.revokedAt == null ? null : serializers.serialize(
      object.revokedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'lastViewedAt';
    yield object.lastViewedAt == null ? null : serializers.serialize(
      object.lastViewedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'viewCount';
    yield serializers.serialize(
      object.viewCount,
      specifiedType: const FullType(int),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ShareLink object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShareLinkBuilder result,
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
        case r'slug':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.slug = valueDes;
          break;
        case r'characterId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.characterId = valueDes;
          break;
        case r'includeGmNotes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.includeGmNotes = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.expiresAt = valueDes;
          break;
        case r'revokedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.revokedAt = valueDes;
          break;
        case r'lastViewedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastViewedAt = valueDes;
          break;
        case r'viewCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.viewCount = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShareLink deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShareLinkBuilder();
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

