//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dp_source.g.dart';

class DpSource extends EnumClass {

  /// Source that originated the DP adjustment. - `gm-manual` — GM applied the delta via the HTTP endpoint. - `roll-push` — Automatic +1 from a player pushing a roll. - `system` — Applied by internal automation. 
  @BuiltValueEnumConst(wireName: r'gm-manual')
  static const DpSource gmManual = _$gmManual;
  /// Source that originated the DP adjustment. - `gm-manual` — GM applied the delta via the HTTP endpoint. - `roll-push` — Automatic +1 from a player pushing a roll. - `system` — Applied by internal automation. 
  @BuiltValueEnumConst(wireName: r'roll-push')
  static const DpSource rollPush = _$rollPush;
  /// Source that originated the DP adjustment. - `gm-manual` — GM applied the delta via the HTTP endpoint. - `roll-push` — Automatic +1 from a player pushing a roll. - `system` — Applied by internal automation. 
  @BuiltValueEnumConst(wireName: r'system')
  static const DpSource system = _$system;

  static Serializer<DpSource> get serializer => _$dpSourceSerializer;

  const DpSource._(String name): super(name);

  static BuiltSet<DpSource> get values => _$values;
  static DpSource valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class DpSourceMixin = Object with _$DpSourceMixin;

