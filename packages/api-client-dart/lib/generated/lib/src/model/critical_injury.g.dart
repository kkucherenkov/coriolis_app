// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'critical_injury.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CriticalInjury extends CriticalInjury {
  @override
  final String id;
  @override
  final String name;
  @override
  final CriticalInjurySeverity severity;
  @override
  final String effect;
  @override
  final DateTime acquiredAt;

  factory _$CriticalInjury([void Function(CriticalInjuryBuilder)? updates]) =>
      (CriticalInjuryBuilder()..update(updates))._build();

  _$CriticalInjury._(
      {required this.id,
      required this.name,
      required this.severity,
      required this.effect,
      required this.acquiredAt})
      : super._();
  @override
  CriticalInjury rebuild(void Function(CriticalInjuryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CriticalInjuryBuilder toBuilder() => CriticalInjuryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CriticalInjury &&
        id == other.id &&
        name == other.name &&
        severity == other.severity &&
        effect == other.effect &&
        acquiredAt == other.acquiredAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, severity.hashCode);
    _$hash = $jc(_$hash, effect.hashCode);
    _$hash = $jc(_$hash, acquiredAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CriticalInjury')
          ..add('id', id)
          ..add('name', name)
          ..add('severity', severity)
          ..add('effect', effect)
          ..add('acquiredAt', acquiredAt))
        .toString();
  }
}

class CriticalInjuryBuilder
    implements Builder<CriticalInjury, CriticalInjuryBuilder> {
  _$CriticalInjury? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CriticalInjurySeverity? _severity;
  CriticalInjurySeverity? get severity => _$this._severity;
  set severity(CriticalInjurySeverity? severity) => _$this._severity = severity;

  String? _effect;
  String? get effect => _$this._effect;
  set effect(String? effect) => _$this._effect = effect;

  DateTime? _acquiredAt;
  DateTime? get acquiredAt => _$this._acquiredAt;
  set acquiredAt(DateTime? acquiredAt) => _$this._acquiredAt = acquiredAt;

  CriticalInjuryBuilder() {
    CriticalInjury._defaults(this);
  }

  CriticalInjuryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _severity = $v.severity;
      _effect = $v.effect;
      _acquiredAt = $v.acquiredAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CriticalInjury other) {
    _$v = other as _$CriticalInjury;
  }

  @override
  void update(void Function(CriticalInjuryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CriticalInjury build() => _build();

  _$CriticalInjury _build() {
    final _$result = _$v ??
        _$CriticalInjury._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'CriticalInjury', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CriticalInjury', 'name'),
          severity: BuiltValueNullFieldError.checkNotNull(
              severity, r'CriticalInjury', 'severity'),
          effect: BuiltValueNullFieldError.checkNotNull(
              effect, r'CriticalInjury', 'effect'),
          acquiredAt: BuiltValueNullFieldError.checkNotNull(
              acquiredAt, r'CriticalInjury', 'acquiredAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
