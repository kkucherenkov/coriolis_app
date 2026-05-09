//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mutant_lineage.g.dart';

class MutantLineage extends EnumClass {

  /// Mutant lineage (родословная пасынков) per Coriolis ST3001 ch.4 §Стигмы пасынков. Three canonical lineages — `zirba` (Зирба), `shingura` (Шингура), `nerida` (Нерида) — each backed by a stigma talent in the catalog (`stigma-zirba`, `stigma-shingura`, `stigma-nerida`).  Set together with `Character.mutant=true` at creation; both fields are mutable while `status: draft` and immutable once the character is `active`. A non-mutant character must not carry a `stigma` talent — `AddTalent` rejects this combination with `STIGMA_REQUIRES_MUTANT`. 
  @BuiltValueEnumConst(wireName: r'zirba')
  static const MutantLineage zirba = _$zirba;
  /// Mutant lineage (родословная пасынков) per Coriolis ST3001 ch.4 §Стигмы пасынков. Three canonical lineages — `zirba` (Зирба), `shingura` (Шингура), `nerida` (Нерида) — each backed by a stigma talent in the catalog (`stigma-zirba`, `stigma-shingura`, `stigma-nerida`).  Set together with `Character.mutant=true` at creation; both fields are mutable while `status: draft` and immutable once the character is `active`. A non-mutant character must not carry a `stigma` talent — `AddTalent` rejects this combination with `STIGMA_REQUIRES_MUTANT`. 
  @BuiltValueEnumConst(wireName: r'shingura')
  static const MutantLineage shingura = _$shingura;
  /// Mutant lineage (родословная пасынков) per Coriolis ST3001 ch.4 §Стигмы пасынков. Three canonical lineages — `zirba` (Зирба), `shingura` (Шингура), `nerida` (Нерида) — each backed by a stigma talent in the catalog (`stigma-zirba`, `stigma-shingura`, `stigma-nerida`).  Set together with `Character.mutant=true` at creation; both fields are mutable while `status: draft` and immutable once the character is `active`. A non-mutant character must not carry a `stigma` talent — `AddTalent` rejects this combination with `STIGMA_REQUIRES_MUTANT`. 
  @BuiltValueEnumConst(wireName: r'nerida')
  static const MutantLineage nerida = _$nerida;

  static Serializer<MutantLineage> get serializer => _$mutantLineageSerializer;

  const MutantLineage._(String name): super(name);

  static BuiltSet<MutantLineage> get values => _$values;
  static MutantLineage valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class MutantLineageMixin = Object with _$MutantLineageMixin;

