//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'relationship_kind.g.dart';

class RelationshipKind extends EnumClass {

  /// The nature of the relationship between a character and an NPC or PC. 
  @BuiltValueEnumConst(wireName: r'ally')
  static const RelationshipKind ally = _$ally;
  /// The nature of the relationship between a character and an NPC or PC. 
  @BuiltValueEnumConst(wireName: r'rival')
  static const RelationshipKind rival = _$rival;
  /// The nature of the relationship between a character and an NPC or PC. 
  @BuiltValueEnumConst(wireName: r'family')
  static const RelationshipKind family = _$family;
  /// The nature of the relationship between a character and an NPC or PC. 
  @BuiltValueEnumConst(wireName: r'mentor')
  static const RelationshipKind mentor = _$mentor;
  /// The nature of the relationship between a character and an NPC or PC. 
  @BuiltValueEnumConst(wireName: r'debtor')
  static const RelationshipKind debtor = _$debtor;
  /// The nature of the relationship between a character and an NPC or PC. 
  @BuiltValueEnumConst(wireName: r'creditor')
  static const RelationshipKind creditor = _$creditor;

  static Serializer<RelationshipKind> get serializer => _$relationshipKindSerializer;

  const RelationshipKind._(String name): super(name);

  static BuiltSet<RelationshipKind> get values => _$values;
  static RelationshipKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RelationshipKindMixin = Object with _$RelationshipKindMixin;

