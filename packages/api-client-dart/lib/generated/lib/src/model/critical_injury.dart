//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/critical_injury_severity.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'critical_injury.g.dart';

/// A critical injury entry on a character's sheet
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [name] - Short name of the injury (e.g. \"Broken arm\")
/// * [severity] 
/// * [effect] - Free-text description of the mechanical or narrative effect
/// * [acquiredAt] - ISO-8601 instant when the injury was recorded
@BuiltValue()
abstract class CriticalInjury implements Built<CriticalInjury, CriticalInjuryBuilder> {
  /// Opaque identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Short name of the injury (e.g. \"Broken arm\")
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'severity')
  CriticalInjurySeverity get severity;
  // enum severityEnum {  light,  severe,  critical,  };

  /// Free-text description of the mechanical or narrative effect
  @BuiltValueField(wireName: r'effect')
  String get effect;

  /// ISO-8601 instant when the injury was recorded
  @BuiltValueField(wireName: r'acquiredAt')
  DateTime get acquiredAt;

  CriticalInjury._();

  factory CriticalInjury([void updates(CriticalInjuryBuilder b)]) = _$CriticalInjury;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CriticalInjuryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CriticalInjury> get serializer => _$CriticalInjurySerializer();
}

class _$CriticalInjurySerializer implements PrimitiveSerializer<CriticalInjury> {
  @override
  final Iterable<Type> types = const [CriticalInjury, _$CriticalInjury];

  @override
  final String wireName = r'CriticalInjury';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CriticalInjury object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'severity';
    yield serializers.serialize(
      object.severity,
      specifiedType: const FullType(CriticalInjurySeverity),
    );
    yield r'effect';
    yield serializers.serialize(
      object.effect,
      specifiedType: const FullType(String),
    );
    yield r'acquiredAt';
    yield serializers.serialize(
      object.acquiredAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CriticalInjury object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CriticalInjuryBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'severity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CriticalInjurySeverity),
          ) as CriticalInjurySeverity;
          result.severity = valueDes;
          break;
        case r'effect':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.effect = valueDes;
          break;
        case r'acquiredAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.acquiredAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CriticalInjury deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CriticalInjuryBuilder();
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

