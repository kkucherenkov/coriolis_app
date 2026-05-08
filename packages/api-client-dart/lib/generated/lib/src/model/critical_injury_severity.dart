//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'critical_injury_severity.g.dart';

class CriticalInjurySeverity extends EnumClass {

  /// Severity tier of a critical injury per Coriolis core rules. - `light` — minor wound, no long-term mechanical effect. - `severe` — significant injury; may impose ongoing penalties. - `critical` — life-threatening; requires urgent medicurgy. 
  @BuiltValueEnumConst(wireName: r'light')
  static const CriticalInjurySeverity light = _$light;
  /// Severity tier of a critical injury per Coriolis core rules. - `light` — minor wound, no long-term mechanical effect. - `severe` — significant injury; may impose ongoing penalties. - `critical` — life-threatening; requires urgent medicurgy. 
  @BuiltValueEnumConst(wireName: r'severe')
  static const CriticalInjurySeverity severe = _$severe;
  /// Severity tier of a critical injury per Coriolis core rules. - `light` — minor wound, no long-term mechanical effect. - `severe` — significant injury; may impose ongoing penalties. - `critical` — life-threatening; requires urgent medicurgy. 
  @BuiltValueEnumConst(wireName: r'critical')
  static const CriticalInjurySeverity critical = _$critical;

  static Serializer<CriticalInjurySeverity> get serializer => _$criticalInjurySeveritySerializer;

  const CriticalInjurySeverity._(String name): super(name);

  static BuiltSet<CriticalInjurySeverity> get values => _$values;
  static CriticalInjurySeverity valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CriticalInjurySeverityMixin = Object with _$CriticalInjurySeverityMixin;

