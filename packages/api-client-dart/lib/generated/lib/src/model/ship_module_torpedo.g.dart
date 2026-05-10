// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_torpedo.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleTorpedoSlotEnum _$shipModuleTorpedoSlotEnum_TORPEDO =
    const ShipModuleTorpedoSlotEnum._('TORPEDO');

ShipModuleTorpedoSlotEnum _$shipModuleTorpedoSlotEnumValueOf(String name) {
  switch (name) {
    case 'TORPEDO':
      return _$shipModuleTorpedoSlotEnum_TORPEDO;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleTorpedoSlotEnum> _$shipModuleTorpedoSlotEnumValues =
    BuiltSet<ShipModuleTorpedoSlotEnum>(const <ShipModuleTorpedoSlotEnum>[
      _$shipModuleTorpedoSlotEnum_TORPEDO,
    ]);

Serializer<ShipModuleTorpedoSlotEnum> _$shipModuleTorpedoSlotEnumSerializer =
    _$ShipModuleTorpedoSlotEnumSerializer();

class _$ShipModuleTorpedoSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleTorpedoSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'TORPEDO': 'TORPEDO',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'TORPEDO': 'TORPEDO',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleTorpedoSlotEnum];
  @override
  final String wireName = 'ShipModuleTorpedoSlotEnum';

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleTorpedoSlotEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ShipModuleTorpedoSlotEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ShipModuleTorpedoSlotEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ShipModuleTorpedo extends ShipModuleTorpedo {
  @override
  final int? mineCount;
  @override
  final int? torpedoCount;

  factory _$ShipModuleTorpedo([
    void Function(ShipModuleTorpedoBuilder)? updates,
  ]) => (ShipModuleTorpedoBuilder()..update(updates))._build();

  _$ShipModuleTorpedo._({this.mineCount, this.torpedoCount}) : super._();
  @override
  ShipModuleTorpedo rebuild(void Function(ShipModuleTorpedoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleTorpedoBuilder toBuilder() =>
      ShipModuleTorpedoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleTorpedo &&
        mineCount == other.mineCount &&
        torpedoCount == other.torpedoCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mineCount.hashCode);
    _$hash = $jc(_$hash, torpedoCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipModuleTorpedo')
          ..add('mineCount', mineCount)
          ..add('torpedoCount', torpedoCount))
        .toString();
  }
}

class ShipModuleTorpedoBuilder
    implements Builder<ShipModuleTorpedo, ShipModuleTorpedoBuilder> {
  _$ShipModuleTorpedo? _$v;

  int? _mineCount;
  int? get mineCount => _$this._mineCount;
  set mineCount(int? mineCount) => _$this._mineCount = mineCount;

  int? _torpedoCount;
  int? get torpedoCount => _$this._torpedoCount;
  set torpedoCount(int? torpedoCount) => _$this._torpedoCount = torpedoCount;

  ShipModuleTorpedoBuilder() {
    ShipModuleTorpedo._defaults(this);
  }

  ShipModuleTorpedoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mineCount = $v.mineCount;
      _torpedoCount = $v.torpedoCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModuleTorpedo other) {
    _$v = other as _$ShipModuleTorpedo;
  }

  @override
  void update(void Function(ShipModuleTorpedoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleTorpedo build() => _build();

  _$ShipModuleTorpedo _build() {
    final _$result =
        _$v ??
        _$ShipModuleTorpedo._(mineCount: mineCount, torpedoCount: torpedoCount);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
