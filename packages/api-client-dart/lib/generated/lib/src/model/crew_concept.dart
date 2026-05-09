//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'crew_concept.g.dart';

class CrewConcept extends EnumClass {

  /// Crew archetype (амплуа команды) per Coriolis ST3001 ch.2 §АМПЛУА КОМАНДЫ. Five canonical crews — `free-trader` (Вольные торговцы), `mercenary` (Наёмники), `explorer` (Исследователи), `agents` (Агенты), `pilgrim` (Пилигримы).  The crew concept is shared by all heroes in a campaign and determines the pool of three crew talents the team picks from at creation (one of which becomes each hero's starting \"crew\" kind talent — see `TalentKind`). Crew concept is mutable while the character is `draft` and immutable once `active`. 
  @BuiltValueEnumConst(wireName: r'free-trader')
  static const CrewConcept freeTrader = _$freeTrader;
  /// Crew archetype (амплуа команды) per Coriolis ST3001 ch.2 §АМПЛУА КОМАНДЫ. Five canonical crews — `free-trader` (Вольные торговцы), `mercenary` (Наёмники), `explorer` (Исследователи), `agents` (Агенты), `pilgrim` (Пилигримы).  The crew concept is shared by all heroes in a campaign and determines the pool of three crew talents the team picks from at creation (one of which becomes each hero's starting \"crew\" kind talent — see `TalentKind`). Crew concept is mutable while the character is `draft` and immutable once `active`. 
  @BuiltValueEnumConst(wireName: r'mercenary')
  static const CrewConcept mercenary = _$mercenary;
  /// Crew archetype (амплуа команды) per Coriolis ST3001 ch.2 §АМПЛУА КОМАНДЫ. Five canonical crews — `free-trader` (Вольные торговцы), `mercenary` (Наёмники), `explorer` (Исследователи), `agents` (Агенты), `pilgrim` (Пилигримы).  The crew concept is shared by all heroes in a campaign and determines the pool of three crew talents the team picks from at creation (one of which becomes each hero's starting \"crew\" kind talent — see `TalentKind`). Crew concept is mutable while the character is `draft` and immutable once `active`. 
  @BuiltValueEnumConst(wireName: r'explorer')
  static const CrewConcept explorer = _$explorer;
  /// Crew archetype (амплуа команды) per Coriolis ST3001 ch.2 §АМПЛУА КОМАНДЫ. Five canonical crews — `free-trader` (Вольные торговцы), `mercenary` (Наёмники), `explorer` (Исследователи), `agents` (Агенты), `pilgrim` (Пилигримы).  The crew concept is shared by all heroes in a campaign and determines the pool of three crew talents the team picks from at creation (one of which becomes each hero's starting \"crew\" kind talent — see `TalentKind`). Crew concept is mutable while the character is `draft` and immutable once `active`. 
  @BuiltValueEnumConst(wireName: r'agents')
  static const CrewConcept agents = _$agents;
  /// Crew archetype (амплуа команды) per Coriolis ST3001 ch.2 §АМПЛУА КОМАНДЫ. Five canonical crews — `free-trader` (Вольные торговцы), `mercenary` (Наёмники), `explorer` (Исследователи), `agents` (Агенты), `pilgrim` (Пилигримы).  The crew concept is shared by all heroes in a campaign and determines the pool of three crew talents the team picks from at creation (one of which becomes each hero's starting \"crew\" kind talent — see `TalentKind`). Crew concept is mutable while the character is `draft` and immutable once `active`. 
  @BuiltValueEnumConst(wireName: r'pilgrim')
  static const CrewConcept pilgrim = _$pilgrim;

  static Serializer<CrewConcept> get serializer => _$crewConceptSerializer;

  const CrewConcept._(String name): super(name);

  static BuiltSet<CrewConcept> get values => _$values;
  static CrewConcept valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CrewConceptMixin = Object with _$CrewConceptMixin;

