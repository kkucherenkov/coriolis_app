// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roll_breakdown.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RollBreakdown extends RollBreakdown {
  @override
  final int attribute;
  @override
  final int skill;
  @override
  final int gear;
  @override
  final int modifier;
  @override
  final int helpers;

  factory _$RollBreakdown([void Function(RollBreakdownBuilder)? updates]) =>
      (RollBreakdownBuilder()..update(updates))._build();

  _$RollBreakdown._(
      {required this.attribute,
      required this.skill,
      required this.gear,
      required this.modifier,
      required this.helpers})
      : super._();
  @override
  RollBreakdown rebuild(void Function(RollBreakdownBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RollBreakdownBuilder toBuilder() => RollBreakdownBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RollBreakdown &&
        attribute == other.attribute &&
        skill == other.skill &&
        gear == other.gear &&
        modifier == other.modifier &&
        helpers == other.helpers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, attribute.hashCode);
    _$hash = $jc(_$hash, skill.hashCode);
    _$hash = $jc(_$hash, gear.hashCode);
    _$hash = $jc(_$hash, modifier.hashCode);
    _$hash = $jc(_$hash, helpers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RollBreakdown')
          ..add('attribute', attribute)
          ..add('skill', skill)
          ..add('gear', gear)
          ..add('modifier', modifier)
          ..add('helpers', helpers))
        .toString();
  }
}

class RollBreakdownBuilder
    implements Builder<RollBreakdown, RollBreakdownBuilder> {
  _$RollBreakdown? _$v;

  int? _attribute;
  int? get attribute => _$this._attribute;
  set attribute(int? attribute) => _$this._attribute = attribute;

  int? _skill;
  int? get skill => _$this._skill;
  set skill(int? skill) => _$this._skill = skill;

  int? _gear;
  int? get gear => _$this._gear;
  set gear(int? gear) => _$this._gear = gear;

  int? _modifier;
  int? get modifier => _$this._modifier;
  set modifier(int? modifier) => _$this._modifier = modifier;

  int? _helpers;
  int? get helpers => _$this._helpers;
  set helpers(int? helpers) => _$this._helpers = helpers;

  RollBreakdownBuilder() {
    RollBreakdown._defaults(this);
  }

  RollBreakdownBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _attribute = $v.attribute;
      _skill = $v.skill;
      _gear = $v.gear;
      _modifier = $v.modifier;
      _helpers = $v.helpers;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RollBreakdown other) {
    _$v = other as _$RollBreakdown;
  }

  @override
  void update(void Function(RollBreakdownBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RollBreakdown build() => _build();

  _$RollBreakdown _build() {
    final _$result = _$v ??
        _$RollBreakdown._(
          attribute: BuiltValueNullFieldError.checkNotNull(
              attribute, r'RollBreakdown', 'attribute'),
          skill: BuiltValueNullFieldError.checkNotNull(
              skill, r'RollBreakdown', 'skill'),
          gear: BuiltValueNullFieldError.checkNotNull(
              gear, r'RollBreakdown', 'gear'),
          modifier: BuiltValueNullFieldError.checkNotNull(
              modifier, r'RollBreakdown', 'modifier'),
          helpers: BuiltValueNullFieldError.checkNotNull(
              helpers, r'RollBreakdown', 'helpers'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
