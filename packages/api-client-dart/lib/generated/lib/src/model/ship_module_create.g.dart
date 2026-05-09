// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipModuleCreate extends ShipModuleCreate {
  @override
  final OneOf oneOf;

  factory _$ShipModuleCreate(
          [void Function(ShipModuleCreateBuilder)? updates]) =>
      (new ShipModuleCreateBuilder()..update(updates))._build();

  _$ShipModuleCreate._({required this.oneOf}) : super._() {
    BuiltValueNullFieldError.checkNotNull(oneOf, r'ShipModuleCreate', 'oneOf');
  }

  @override
  ShipModuleCreate rebuild(void Function(ShipModuleCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleCreateBuilder toBuilder() =>
      new ShipModuleCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleCreate && oneOf == other.oneOf;
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
    return (newBuiltValueToStringHelper(r'ShipModuleCreate')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class ShipModuleCreateBuilder
    implements Builder<ShipModuleCreate, ShipModuleCreateBuilder> {
  _$ShipModuleCreate? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  ShipModuleCreateBuilder() {
    ShipModuleCreate._defaults(this);
  }

  ShipModuleCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModuleCreate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ShipModuleCreate;
  }

  @override
  void update(void Function(ShipModuleCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleCreate build() => _build();

  _$ShipModuleCreate _build() {
    final _$result = _$v ??
        new _$ShipModuleCreate._(
            oneOf: BuiltValueNullFieldError.checkNotNull(
                oneOf, r'ShipModuleCreate', 'oneOf'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
