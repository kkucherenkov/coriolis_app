//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_block_summary.g.dart';

/// ChatBlockSummary
///
/// Properties:
/// * [targetMembershipId] 
/// * [targetDisplayName] 
/// * [createdAt] 
@BuiltValue()
abstract class ChatBlockSummary implements Built<ChatBlockSummary, ChatBlockSummaryBuilder> {
  @BuiltValueField(wireName: r'targetMembershipId')
  String get targetMembershipId;

  @BuiltValueField(wireName: r'targetDisplayName')
  String? get targetDisplayName;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  ChatBlockSummary._();

  factory ChatBlockSummary([void updates(ChatBlockSummaryBuilder b)]) = _$ChatBlockSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatBlockSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatBlockSummary> get serializer => _$ChatBlockSummarySerializer();
}

class _$ChatBlockSummarySerializer implements PrimitiveSerializer<ChatBlockSummary> {
  @override
  final Iterable<Type> types = const [ChatBlockSummary, _$ChatBlockSummary];

  @override
  final String wireName = r'ChatBlockSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatBlockSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'targetMembershipId';
    yield serializers.serialize(
      object.targetMembershipId,
      specifiedType: const FullType(String),
    );
    if (object.targetDisplayName != null) {
      yield r'targetDisplayName';
      yield serializers.serialize(
        object.targetDisplayName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatBlockSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatBlockSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'targetMembershipId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetMembershipId = valueDes;
          break;
        case r'targetDisplayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetDisplayName = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatBlockSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatBlockSummaryBuilder();
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

