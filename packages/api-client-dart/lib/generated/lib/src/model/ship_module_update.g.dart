// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipModuleUpdate extends ShipModuleUpdate {
  @override
  final OneOf oneOf;

  factory _$ShipModuleUpdate(
          [void Function(ShipModuleUpdateBuilder)? updates]) =>
      (new ShipModuleUpdateBuilder()..update(updates))._build();

  _$ShipModuleUpdate._({required this.oneOf}) : super._() {
    BuiltValueNullFieldError.checkNotNull(oneOf, r'ShipModuleUpdate', 'oneOf');
  }

  @override
  ShipModuleUpdate rebuild(void Function(ShipModuleUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleUpdateBuilder toBuilder() =>
      new ShipModuleUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleUpdate && oneOf == other.oneOf;
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
    return (newBuiltValueToStringHelper(r'ShipModuleUpdate')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class ShipModuleUpdateBuilder
    implements Builder<ShipModuleUpdate, ShipModuleUpdateBuilder> {
  _$ShipModuleUpdate? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  ShipModuleUpdateBuilder() {
    ShipModuleUpdate._defaults(this);
  }

  ShipModuleUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModuleUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ShipModuleUpdate;
  }

  @override
  void update(void Function(ShipModuleUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleUpdate build() => _build();

  _$ShipModuleUpdate _build() {
    final _$result = _$v ??
        new _$ShipModuleUpdate._(
            oneOf: BuiltValueNullFieldError.checkNotNull(
                oneOf, r'ShipModuleUpdate', 'oneOf'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
