// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attributes.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Attributes extends Attributes {
  @override
  final int strength;
  @override
  final int agility;
  @override
  final int wits;
  @override
  final int empathy;

  factory _$Attributes([void Function(AttributesBuilder)? updates]) =>
      (AttributesBuilder()..update(updates))._build();

  _$Attributes._({
    required this.strength,
    required this.agility,
    required this.wits,
    required this.empathy,
  }) : super._();
  @override
  Attributes rebuild(void Function(AttributesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AttributesBuilder toBuilder() => AttributesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Attributes &&
        strength == other.strength &&
        agility == other.agility &&
        wits == other.wits &&
        empathy == other.empathy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, strength.hashCode);
    _$hash = $jc(_$hash, agility.hashCode);
    _$hash = $jc(_$hash, wits.hashCode);
    _$hash = $jc(_$hash, empathy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Attributes')
          ..add('strength', strength)
          ..add('agility', agility)
          ..add('wits', wits)
          ..add('empathy', empathy))
        .toString();
  }
}

class AttributesBuilder implements Builder<Attributes, AttributesBuilder> {
  _$Attributes? _$v;

  int? _strength;
  int? get strength => _$this._strength;
  set strength(int? strength) => _$this._strength = strength;

  int? _agility;
  int? get agility => _$this._agility;
  set agility(int? agility) => _$this._agility = agility;

  int? _wits;
  int? get wits => _$this._wits;
  set wits(int? wits) => _$this._wits = wits;

  int? _empathy;
  int? get empathy => _$this._empathy;
  set empathy(int? empathy) => _$this._empathy = empathy;

  AttributesBuilder() {
    Attributes._defaults(this);
  }

  AttributesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _strength = $v.strength;
      _agility = $v.agility;
      _wits = $v.wits;
      _empathy = $v.empathy;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Attributes other) {
    _$v = other as _$Attributes;
  }

  @override
  void update(void Function(AttributesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Attributes build() => _build();

  _$Attributes _build() {
    final _$result =
        _$v ??
        _$Attributes._(
          strength: BuiltValueNullFieldError.checkNotNull(
            strength,
            r'Attributes',
            'strength',
          ),
          agility: BuiltValueNullFieldError.checkNotNull(
            agility,
            r'Attributes',
            'agility',
          ),
          wits: BuiltValueNullFieldError.checkNotNull(
            wits,
            r'Attributes',
            'wits',
          ),
          empathy: BuiltValueNullFieldError.checkNotNull(
            empathy,
            r'Attributes',
            'empathy',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
