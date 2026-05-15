//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invite_preview.g.dart';

/// Public preview returned before accepting an invite. Contains only session name and GM display name — no session ID, no member list, no liveness signal. Decision #4 in the design doc. 
///
/// Properties:
/// * [sessionName] 
/// * [gmDisplayName] 
/// * [alreadyJoined] - True when the authenticated caller already has an active membership.
@BuiltValue()
abstract class InvitePreview implements Built<InvitePreview, InvitePreviewBuilder> {
  @BuiltValueField(wireName: r'sessionName')
  String get sessionName;

  @BuiltValueField(wireName: r'gmDisplayName')
  String get gmDisplayName;

  /// True when the authenticated caller already has an active membership.
  @BuiltValueField(wireName: r'alreadyJoined')
  bool get alreadyJoined;

  InvitePreview._();

  factory InvitePreview([void updates(InvitePreviewBuilder b)]) = _$InvitePreview;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvitePreviewBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvitePreview> get serializer => _$InvitePreviewSerializer();
}

class _$InvitePreviewSerializer implements PrimitiveSerializer<InvitePreview> {
  @override
  final Iterable<Type> types = const [InvitePreview, _$InvitePreview];

  @override
  final String wireName = r'InvitePreview';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvitePreview object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sessionName';
    yield serializers.serialize(
      object.sessionName,
      specifiedType: const FullType(String),
    );
    yield r'gmDisplayName';
    yield serializers.serialize(
      object.gmDisplayName,
      specifiedType: const FullType(String),
    );
    yield r'alreadyJoined';
    yield serializers.serialize(
      object.alreadyJoined,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InvitePreview object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InvitePreviewBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sessionName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionName = valueDes;
          break;
        case r'gmDisplayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.gmDisplayName = valueDes;
          break;
        case r'alreadyJoined':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.alreadyJoined = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InvitePreview deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvitePreviewBuilder();
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

