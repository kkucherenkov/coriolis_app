//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'crew_position.g.dart';

class CrewPosition extends EnumClass {

  /// Crew positions per ST3001 ГЛАВА 7 (crew roles). `sensorOp` is the штурман-оператор (navigator/sensor operator) in the rulebook, also responsible for combat-meme and info-impulse attacks. All positions except `captain` may be filled by automation (усовершенствование «Автоматика»). 
  @BuiltValueEnumConst(wireName: r'captain')
  static const CrewPosition captain = _$captain;
  /// Crew positions per ST3001 ГЛАВА 7 (crew roles). `sensorOp` is the штурман-оператор (navigator/sensor operator) in the rulebook, also responsible for combat-meme and info-impulse attacks. All positions except `captain` may be filled by automation (усовершенствование «Автоматика»). 
  @BuiltValueEnumConst(wireName: r'pilot')
  static const CrewPosition pilot = _$pilot;
  /// Crew positions per ST3001 ГЛАВА 7 (crew roles). `sensorOp` is the штурман-оператор (navigator/sensor operator) in the rulebook, also responsible for combat-meme and info-impulse attacks. All positions except `captain` may be filled by automation (усовершенствование «Автоматика»). 
  @BuiltValueEnumConst(wireName: r'sensorOp')
  static const CrewPosition sensorOp = _$sensorOp;
  /// Crew positions per ST3001 ГЛАВА 7 (crew roles). `sensorOp` is the штурман-оператор (navigator/sensor operator) in the rulebook, also responsible for combat-meme and info-impulse attacks. All positions except `captain` may be filled by automation (усовершенствование «Автоматика»). 
  @BuiltValueEnumConst(wireName: r'gunner')
  static const CrewPosition gunner = _$gunner;
  /// Crew positions per ST3001 ГЛАВА 7 (crew roles). `sensorOp` is the штурман-оператор (navigator/sensor operator) in the rulebook, also responsible for combat-meme and info-impulse attacks. All positions except `captain` may be filled by automation (усовершенствование «Автоматика»). 
  @BuiltValueEnumConst(wireName: r'engineer')
  static const CrewPosition engineer = _$engineer;
  /// Crew positions per ST3001 ГЛАВА 7 (crew roles). `sensorOp` is the штурман-оператор (navigator/sensor operator) in the rulebook, also responsible for combat-meme and info-impulse attacks. All positions except `captain` may be filled by automation (усовершенствование «Автоматика»). 
  @BuiltValueEnumConst(wireName: r'serviceCrew')
  static const CrewPosition serviceCrew = _$serviceCrew;

  static Serializer<CrewPosition> get serializer => _$crewPositionSerializer;

  const CrewPosition._(String name): super(name);

  static BuiltSet<CrewPosition> get values => _$values;
  static CrewPosition valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CrewPositionMixin = Object with _$CrewPositionMixin;

