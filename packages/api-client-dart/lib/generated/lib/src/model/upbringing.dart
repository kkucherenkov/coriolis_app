//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upbringing.g.dart';

class Upbringing extends EnumClass {

  /// Social stratum a character was raised in (Coriolis core book ch.2, table 2.2 — \"Воспитание\"). Upbringing is set once at character creation and is **immutable**; it determines the starting attribute / skill point budgets, the starting reputation, and the starting wealth (in birrs) the character is created with.  | Upbringing  | Attribute pts | Skill pts | Reputation | Wealth (birrs) | | ----------- | ------------- | --------- | ---------- | -------------- | | plebeian    | 15            | 8         | 2          |   500          | | stationary  | 14            | 10        | 4          |  1000          | | aristocrat  | 13            | 12        | 6          |  5000          | 
  @BuiltValueEnumConst(wireName: r'plebeian')
  static const Upbringing plebeian = _$plebeian;
  /// Social stratum a character was raised in (Coriolis core book ch.2, table 2.2 — \"Воспитание\"). Upbringing is set once at character creation and is **immutable**; it determines the starting attribute / skill point budgets, the starting reputation, and the starting wealth (in birrs) the character is created with.  | Upbringing  | Attribute pts | Skill pts | Reputation | Wealth (birrs) | | ----------- | ------------- | --------- | ---------- | -------------- | | plebeian    | 15            | 8         | 2          |   500          | | stationary  | 14            | 10        | 4          |  1000          | | aristocrat  | 13            | 12        | 6          |  5000          | 
  @BuiltValueEnumConst(wireName: r'stationary')
  static const Upbringing stationary = _$stationary;
  /// Social stratum a character was raised in (Coriolis core book ch.2, table 2.2 — \"Воспитание\"). Upbringing is set once at character creation and is **immutable**; it determines the starting attribute / skill point budgets, the starting reputation, and the starting wealth (in birrs) the character is created with.  | Upbringing  | Attribute pts | Skill pts | Reputation | Wealth (birrs) | | ----------- | ------------- | --------- | ---------- | -------------- | | plebeian    | 15            | 8         | 2          |   500          | | stationary  | 14            | 10        | 4          |  1000          | | aristocrat  | 13            | 12        | 6          |  5000          | 
  @BuiltValueEnumConst(wireName: r'aristocrat')
  static const Upbringing aristocrat = _$aristocrat;

  static Serializer<Upbringing> get serializer => _$upbringingSerializer;

  const Upbringing._(String name): super(name);

  static BuiltSet<Upbringing> get values => _$values;
  static Upbringing valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class UpbringingMixin = Object with _$UpbringingMixin;

