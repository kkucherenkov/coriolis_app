//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'share_link_create.g.dart';

/// Request body for creating a share link. All fields are optional; an empty object `{}` creates a permanent link without GM notes. 
///
/// Properties:
/// * [includeGmNotes] - When true, the public character endpoint returns the top-level `notes` field. When false (default), `notes` is always null in the public response regardless of the character's actual notes value. 
/// * [expiresAt] - ISO-8601 instant after which the link stops resolving. Omit or set to null for a permanent link. 
/// * [label] - Optional human-readable label to distinguish this link from others in the owner's list (e.g. \"GM copy\", \"public preview\"). 
@BuiltValue()
abstract class ShareLinkCreate implements Built<ShareLinkCreate, ShareLinkCreateBuilder> {
  /// When true, the public character endpoint returns the top-level `notes` field. When false (default), `notes` is always null in the public response regardless of the character's actual notes value. 
  @BuiltValueField(wireName: r'includeGmNotes')
  bool? get includeGmNotes;

  /// ISO-8601 instant after which the link stops resolving. Omit or set to null for a permanent link. 
  @BuiltValueField(wireName: r'expiresAt')
  DateTime? get expiresAt;

  /// Optional human-readable label to distinguish this link from others in the owner's list (e.g. \"GM copy\", \"public preview\"). 
  @BuiltValueField(wireName: r'label')
  String? get label;

  ShareLinkCreate._();

  factory ShareLinkCreate([void updates(ShareLinkCreateBuilder b)]) = _$ShareLinkCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShareLinkCreateBuilder b) => b
      ..includeGmNotes = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShareLinkCreate> get serializer => _$ShareLinkCreateSerializer();
}

class _$ShareLinkCreateSerializer implements PrimitiveSerializer<ShareLinkCreate> {
  @override
  final Iterable<Type> types = const [ShareLinkCreate, _$ShareLinkCreate];

  @override
  final String wireName = r'ShareLinkCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShareLinkCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.includeGmNotes != null) {
      yield r'includeGmNotes';
      yield serializers.serialize(
        object.includeGmNotes,
        specifiedType: const FullType(bool),
      );
    }
    if (object.expiresAt != null) {
      yield r'expiresAt';
      yield serializers.serialize(
        object.expiresAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShareLinkCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShareLinkCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'includeGmNotes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.includeGmNotes = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.expiresAt = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShareLinkCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShareLinkCreateBuilder();
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

