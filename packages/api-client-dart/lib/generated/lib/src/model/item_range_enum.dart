//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_range_enum.g.dart';

class ItemRangeEnum extends EnumClass {

  /// Personal-scale weapon range bands per ST3001 ГЛАВА 5 «Дистанция» (lines 73-78 of the Russian rulebook). Four bands by canon — each absorbs the previous (a target at `medium` is also at `close` for any rule that talks about \"within X\"). - `close` — Ближняя, up to 2 m (engaged / hand-to-hand /   same-room close quarters; absorbs the legacy `arm` and `near`   values). - `medium` — Средняя, up to 20 m (corridor / street; absorbs the   legacy `short`). - `long` — Дальняя, up to 100 m (open ground / rooftop; same   slug as the legacy value, semantics narrowed). - `extreme` — Предельная, up to 1000 m (sniper / max effective;   absorbs the legacy `distant`). Distinct from `ShipWeaponRange` (5-band ship-combat ladder from ГЛАВА 7 Table 7.9 — that enum keeps its `zero` band). 
  @BuiltValueEnumConst(wireName: r'close')
  static const ItemRangeEnum close = _$close;
  /// Personal-scale weapon range bands per ST3001 ГЛАВА 5 «Дистанция» (lines 73-78 of the Russian rulebook). Four bands by canon — each absorbs the previous (a target at `medium` is also at `close` for any rule that talks about \"within X\"). - `close` — Ближняя, up to 2 m (engaged / hand-to-hand /   same-room close quarters; absorbs the legacy `arm` and `near`   values). - `medium` — Средняя, up to 20 m (corridor / street; absorbs the   legacy `short`). - `long` — Дальняя, up to 100 m (open ground / rooftop; same   slug as the legacy value, semantics narrowed). - `extreme` — Предельная, up to 1000 m (sniper / max effective;   absorbs the legacy `distant`). Distinct from `ShipWeaponRange` (5-band ship-combat ladder from ГЛАВА 7 Table 7.9 — that enum keeps its `zero` band). 
  @BuiltValueEnumConst(wireName: r'medium')
  static const ItemRangeEnum medium = _$medium;
  /// Personal-scale weapon range bands per ST3001 ГЛАВА 5 «Дистанция» (lines 73-78 of the Russian rulebook). Four bands by canon — each absorbs the previous (a target at `medium` is also at `close` for any rule that talks about \"within X\"). - `close` — Ближняя, up to 2 m (engaged / hand-to-hand /   same-room close quarters; absorbs the legacy `arm` and `near`   values). - `medium` — Средняя, up to 20 m (corridor / street; absorbs the   legacy `short`). - `long` — Дальняя, up to 100 m (open ground / rooftop; same   slug as the legacy value, semantics narrowed). - `extreme` — Предельная, up to 1000 m (sniper / max effective;   absorbs the legacy `distant`). Distinct from `ShipWeaponRange` (5-band ship-combat ladder from ГЛАВА 7 Table 7.9 — that enum keeps its `zero` band). 
  @BuiltValueEnumConst(wireName: r'long')
  static const ItemRangeEnum long = _$long;
  /// Personal-scale weapon range bands per ST3001 ГЛАВА 5 «Дистанция» (lines 73-78 of the Russian rulebook). Four bands by canon — each absorbs the previous (a target at `medium` is also at `close` for any rule that talks about \"within X\"). - `close` — Ближняя, up to 2 m (engaged / hand-to-hand /   same-room close quarters; absorbs the legacy `arm` and `near`   values). - `medium` — Средняя, up to 20 m (corridor / street; absorbs the   legacy `short`). - `long` — Дальняя, up to 100 m (open ground / rooftop; same   slug as the legacy value, semantics narrowed). - `extreme` — Предельная, up to 1000 m (sniper / max effective;   absorbs the legacy `distant`). Distinct from `ShipWeaponRange` (5-band ship-combat ladder from ГЛАВА 7 Table 7.9 — that enum keeps its `zero` band). 
  @BuiltValueEnumConst(wireName: r'extreme')
  static const ItemRangeEnum extreme = _$extreme;

  static Serializer<ItemRangeEnum> get serializer => _$itemRangeEnumSerializer;

  const ItemRangeEnum._(String name): super(name);

  static BuiltSet<ItemRangeEnum> get values => _$values;
  static ItemRangeEnum valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ItemRangeEnumMixin = Object with _$ItemRangeEnumMixin;

