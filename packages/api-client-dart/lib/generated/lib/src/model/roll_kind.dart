//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'roll_kind.g.dart';

class RollKind extends EnumClass {

  /// Discriminator on roll payloads — what *kind* of dice roll the result represents. Drives the push-eligibility gate per ST3001 ГЛАВА 3 §«Вознесение молитв» («Молитву можно возносить только при проверках навыков»). Only `skill` rolls can be pushed; the backend rejects push attempts on the other four kinds with `PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL`.  - `skill` — standard skill / attribute check. Push-eligible. - `save` — armor save / damage-resist roll (ГЛАВА 5 «Урон»). - `trauma` — critical-injury / trauma roll (ГЛАВА 5   «Травмирующие атаки»). - `initiative` — combat initiative d6 (ГЛАВА 5 «Раунды,   ходы и инициатива»). The bounded reroll loop landed in   T-010 Block A is the canonical mechanic; this is not a   push. - `darkness` — GM darkness pool / NPC reaction (ГЛАВА 15   «Принципы игры»). GM-side narrative tool; not pushed. 
  @BuiltValueEnumConst(wireName: r'skill')
  static const RollKind skill = _$skill;
  /// Discriminator on roll payloads — what *kind* of dice roll the result represents. Drives the push-eligibility gate per ST3001 ГЛАВА 3 §«Вознесение молитв» («Молитву можно возносить только при проверках навыков»). Only `skill` rolls can be pushed; the backend rejects push attempts on the other four kinds with `PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL`.  - `skill` — standard skill / attribute check. Push-eligible. - `save` — armor save / damage-resist roll (ГЛАВА 5 «Урон»). - `trauma` — critical-injury / trauma roll (ГЛАВА 5   «Травмирующие атаки»). - `initiative` — combat initiative d6 (ГЛАВА 5 «Раунды,   ходы и инициатива»). The bounded reroll loop landed in   T-010 Block A is the canonical mechanic; this is not a   push. - `darkness` — GM darkness pool / NPC reaction (ГЛАВА 15   «Принципы игры»). GM-side narrative tool; not pushed. 
  @BuiltValueEnumConst(wireName: r'save')
  static const RollKind save = _$save;
  /// Discriminator on roll payloads — what *kind* of dice roll the result represents. Drives the push-eligibility gate per ST3001 ГЛАВА 3 §«Вознесение молитв» («Молитву можно возносить только при проверках навыков»). Only `skill` rolls can be pushed; the backend rejects push attempts on the other four kinds with `PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL`.  - `skill` — standard skill / attribute check. Push-eligible. - `save` — armor save / damage-resist roll (ГЛАВА 5 «Урон»). - `trauma` — critical-injury / trauma roll (ГЛАВА 5   «Травмирующие атаки»). - `initiative` — combat initiative d6 (ГЛАВА 5 «Раунды,   ходы и инициатива»). The bounded reroll loop landed in   T-010 Block A is the canonical mechanic; this is not a   push. - `darkness` — GM darkness pool / NPC reaction (ГЛАВА 15   «Принципы игры»). GM-side narrative tool; not pushed. 
  @BuiltValueEnumConst(wireName: r'trauma')
  static const RollKind trauma = _$trauma;
  /// Discriminator on roll payloads — what *kind* of dice roll the result represents. Drives the push-eligibility gate per ST3001 ГЛАВА 3 §«Вознесение молитв» («Молитву можно возносить только при проверках навыков»). Only `skill` rolls can be pushed; the backend rejects push attempts on the other four kinds with `PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL`.  - `skill` — standard skill / attribute check. Push-eligible. - `save` — armor save / damage-resist roll (ГЛАВА 5 «Урон»). - `trauma` — critical-injury / trauma roll (ГЛАВА 5   «Травмирующие атаки»). - `initiative` — combat initiative d6 (ГЛАВА 5 «Раунды,   ходы и инициатива»). The bounded reroll loop landed in   T-010 Block A is the canonical mechanic; this is not a   push. - `darkness` — GM darkness pool / NPC reaction (ГЛАВА 15   «Принципы игры»). GM-side narrative tool; not pushed. 
  @BuiltValueEnumConst(wireName: r'initiative')
  static const RollKind initiative = _$initiative;
  /// Discriminator on roll payloads — what *kind* of dice roll the result represents. Drives the push-eligibility gate per ST3001 ГЛАВА 3 §«Вознесение молитв» («Молитву можно возносить только при проверках навыков»). Only `skill` rolls can be pushed; the backend rejects push attempts on the other four kinds with `PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL`.  - `skill` — standard skill / attribute check. Push-eligible. - `save` — armor save / damage-resist roll (ГЛАВА 5 «Урон»). - `trauma` — critical-injury / trauma roll (ГЛАВА 5   «Травмирующие атаки»). - `initiative` — combat initiative d6 (ГЛАВА 5 «Раунды,   ходы и инициатива»). The bounded reroll loop landed in   T-010 Block A is the canonical mechanic; this is not a   push. - `darkness` — GM darkness pool / NPC reaction (ГЛАВА 15   «Принципы игры»). GM-side narrative tool; not pushed. 
  @BuiltValueEnumConst(wireName: r'darkness')
  static const RollKind darkness = _$darkness;

  static Serializer<RollKind> get serializer => _$rollKindSerializer;

  const RollKind._(String name): super(name);

  static BuiltSet<RollKind> get values => _$values;
  static RollKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RollKindMixin = Object with _$RollKindMixin;

