// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipModule extends ShipModule {
  @override
  final OneOf oneOf;

  factory _$ShipModule([void Function(ShipModuleBuilder)? updates]) =>
      (new ShipModuleBuilder()..update(updates))._build();

  _$ShipModule._({required this.oneOf}) : super._() {
    BuiltValueNullFieldError.checkNotNull(oneOf, r'ShipModule', 'oneOf');
  }

  @override
  ShipModule rebuild(void Function(ShipModuleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleBuilder toBuilder() => new ShipModuleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModule && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipModule')..add('oneOf', oneOf))
        .toString();
  }
}

class ShipModuleBuilder implements Builder<ShipModule, ShipModuleBuilder> {
  _$ShipModule? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  ShipModuleBuilder() {
    ShipModule._defaults(this);
  }

  ShipModuleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModule other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ShipModule;
  }

  @override
  void update(void Function(ShipModuleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModule build() => _build();

  _$ShipModule _build() {
    final _$result = _$v ??
        new _$ShipModule._(
            oneOf: BuiltValueNullFieldError.checkNotNull(
                oneOf, r'ShipModule', 'oneOf'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
