//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'talent_kind.g.dart';

class TalentKind extends EnumClass {

  /// Discriminator for `Talent.kind` per Coriolis ST3001 ch.2 (3 starting talents: one personal from amplua, one crew from crew-amplua, one icon gift from chosen icon) and ch.4 (mutants additionally pick one `stigma`).  Each character has at most one talent of each `personal`, `crew`, `iconGift`, `stigma` at character creation; further talents acquired during play are always `personal`.  - `personal`  — picked from the amplua's personal talent list - `crew`      — picked from the team's crew amplua list - `iconGift`  — auto-derived from the character's `iconId` - `stigma`    — only for mutants; picked from the mutant                 lineage's stigma list (Block 5) 
  @BuiltValueEnumConst(wireName: r'personal')
  static const TalentKind personal = _$personal;
  /// Discriminator for `Talent.kind` per Coriolis ST3001 ch.2 (3 starting talents: one personal from amplua, one crew from crew-amplua, one icon gift from chosen icon) and ch.4 (mutants additionally pick one `stigma`).  Each character has at most one talent of each `personal`, `crew`, `iconGift`, `stigma` at character creation; further talents acquired during play are always `personal`.  - `personal`  — picked from the amplua's personal talent list - `crew`      — picked from the team's crew amplua list - `iconGift`  — auto-derived from the character's `iconId` - `stigma`    — only for mutants; picked from the mutant                 lineage's stigma list (Block 5) 
  @BuiltValueEnumConst(wireName: r'crew')
  static const TalentKind crew = _$crew;
  /// Discriminator for `Talent.kind` per Coriolis ST3001 ch.2 (3 starting talents: one personal from amplua, one crew from crew-amplua, one icon gift from chosen icon) and ch.4 (mutants additionally pick one `stigma`).  Each character has at most one talent of each `personal`, `crew`, `iconGift`, `stigma` at character creation; further talents acquired during play are always `personal`.  - `personal`  — picked from the amplua's personal talent list - `crew`      — picked from the team's crew amplua list - `iconGift`  — auto-derived from the character's `iconId` - `stigma`    — only for mutants; picked from the mutant                 lineage's stigma list (Block 5) 
  @BuiltValueEnumConst(wireName: r'iconGift')
  static const TalentKind iconGift = _$iconGift;
  /// Discriminator for `Talent.kind` per Coriolis ST3001 ch.2 (3 starting talents: one personal from amplua, one crew from crew-amplua, one icon gift from chosen icon) and ch.4 (mutants additionally pick one `stigma`).  Each character has at most one talent of each `personal`, `crew`, `iconGift`, `stigma` at character creation; further talents acquired during play are always `personal`.  - `personal`  — picked from the amplua's personal talent list - `crew`      — picked from the team's crew amplua list - `iconGift`  — auto-derived from the character's `iconId` - `stigma`    — only for mutants; picked from the mutant                 lineage's stigma list (Block 5) 
  @BuiltValueEnumConst(wireName: r'stigma')
  static const TalentKind stigma = _$stigma;

  static Serializer<TalentKind> get serializer => _$talentKindSerializer;

  const TalentKind._(String name): super(name);

  static BuiltSet<TalentKind> get values => _$values;
  static TalentKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class TalentKindMixin = Object with _$TalentKindMixin;

