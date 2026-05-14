// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_flags.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConditionFlags extends ConditionFlags {
  @override
  final bool exhausted;
  @override
  final bool sleepless;
  @override
  final bool thirsty;
  @override
  final bool hungry;

  factory _$ConditionFlags([void Function(ConditionFlagsBuilder)? updates]) =>
      (ConditionFlagsBuilder()..update(updates))._build();

  _$ConditionFlags._(
      {required this.exhausted,
      required this.sleepless,
      required this.thirsty,
      required this.hungry})
      : super._();
  @override
  ConditionFlags rebuild(void Function(ConditionFlagsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConditionFlagsBuilder toBuilder() => ConditionFlagsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConditionFlags &&
        exhausted == other.exhausted &&
        sleepless == other.sleepless &&
        thirsty == other.thirsty &&
        hungry == other.hungry;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, exhausted.hashCode);
    _$hash = $jc(_$hash, sleepless.hashCode);
    _$hash = $jc(_$hash, thirsty.hashCode);
    _$hash = $jc(_$hash, hungry.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConditionFlags')
          ..add('exhausted', exhausted)
          ..add('sleepless', sleepless)
          ..add('thirsty', thirsty)
          ..add('hungry', hungry))
        .toString();
  }
}

class ConditionFlagsBuilder
    implements Builder<ConditionFlags, ConditionFlagsBuilder> {
  _$ConditionFlags? _$v;

  bool? _exhausted;
  bool? get exhausted => _$this._exhausted;
  set exhausted(bool? exhausted) => _$this._exhausted = exhausted;

  bool? _sleepless;
  bool? get sleepless => _$this._sleepless;
  set sleepless(bool? sleepless) => _$this._sleepless = sleepless;

  bool? _thirsty;
  bool? get thirsty => _$this._thirsty;
  set thirsty(bool? thirsty) => _$this._thirsty = thirsty;

  bool? _hungry;
  bool? get hungry => _$this._hungry;
  set hungry(bool? hungry) => _$this._hungry = hungry;

  ConditionFlagsBuilder() {
    ConditionFlags._defaults(this);
  }

  ConditionFlagsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _exhausted = $v.exhausted;
      _sleepless = $v.sleepless;
      _thirsty = $v.thirsty;
      _hungry = $v.hungry;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConditionFlags other) {
    _$v = other as _$ConditionFlags;
  }

  @override
  void update(void Function(ConditionFlagsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConditionFlags build() => _build();

  _$ConditionFlags _build() {
    final _$result = _$v ??
        _$ConditionFlags._(
          exhausted: BuiltValueNullFieldError.checkNotNull(
              exhausted, r'ConditionFlags', 'exhausted'),
          sleepless: BuiltValueNullFieldError.checkNotNull(
              sleepless, r'ConditionFlags', 'sleepless'),
          thirsty: BuiltValueNullFieldError.checkNotNull(
              thirsty, r'ConditionFlags', 'thirsty'),
          hungry: BuiltValueNullFieldError.checkNotNull(
              hungry, r'ConditionFlags', 'hungry'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
