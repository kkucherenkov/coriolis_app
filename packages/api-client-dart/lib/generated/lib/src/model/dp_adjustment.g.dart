// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dp_adjustment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DpAdjustment extends DpAdjustment {
  @override
  final int delta;
  @override
  final String? reason;

  factory _$DpAdjustment([void Function(DpAdjustmentBuilder)? updates]) =>
      (DpAdjustmentBuilder()..update(updates))._build();

  _$DpAdjustment._({required this.delta, this.reason}) : super._();
  @override
  DpAdjustment rebuild(void Function(DpAdjustmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DpAdjustmentBuilder toBuilder() => DpAdjustmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DpAdjustment &&
        delta == other.delta &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, delta.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DpAdjustment')
          ..add('delta', delta)
          ..add('reason', reason))
        .toString();
  }
}

class DpAdjustmentBuilder
    implements Builder<DpAdjustment, DpAdjustmentBuilder> {
  _$DpAdjustment? _$v;

  int? _delta;
  int? get delta => _$this._delta;
  set delta(int? delta) => _$this._delta = delta;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DpAdjustmentBuilder() {
    DpAdjustment._defaults(this);
  }

  DpAdjustmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _delta = $v.delta;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DpAdjustment other) {
    _$v = other as _$DpAdjustment;
  }

  @override
  void update(void Function(DpAdjustmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DpAdjustment build() => _build();

  _$DpAdjustment _build() {
    final _$result = _$v ??
        _$DpAdjustment._(
          delta: BuiltValueNullFieldError.checkNotNull(
              delta, r'DpAdjustment', 'delta'),
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
