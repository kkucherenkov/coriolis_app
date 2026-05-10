// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_hold.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleHoldSlotEnum _$shipModuleHoldSlotEnum_HOLD =
    const ShipModuleHoldSlotEnum._('HOLD');

ShipModuleHoldSlotEnum _$shipModuleHoldSlotEnumValueOf(String name) {
  switch (name) {
    case 'HOLD':
      return _$shipModuleHoldSlotEnum_HOLD;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleHoldSlotEnum> _$shipModuleHoldSlotEnumValues =
    BuiltSet<ShipModuleHoldSlotEnum>(const <ShipModuleHoldSlotEnum>[
      _$shipModuleHoldSlotEnum_HOLD,
    ]);

Serializer<ShipModuleHoldSlotEnum> _$shipModuleHoldSlotEnumSerializer =
    _$ShipModuleHoldSlotEnumSerializer();

class _$ShipModuleHoldSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleHoldSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'HOLD': 'HOLD',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'HOLD': 'HOLD',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleHoldSlotEnum];
  @override
  final String wireName = 'ShipModuleHoldSlotEnum';

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleHoldSlotEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ShipModuleHoldSlotEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ShipModuleHoldSlotEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ShipModuleHold extends ShipModuleHold {
  @override
  final int? cargoTons;
  @override
  final bool? concealed;

  factory _$ShipModuleHold([void Function(ShipModuleHoldBuilder)? updates]) =>
      (ShipModuleHoldBuilder()..update(updates))._build();

  _$ShipModuleHold._({this.cargoTons, this.concealed}) : super._();
  @override
  ShipModuleHold rebuild(void Function(ShipModuleHoldBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleHoldBuilder toBuilder() => ShipModuleHoldBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleHold &&
        cargoTons == other.cargoTons &&
        concealed == other.concealed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cargoTons.hashCode);
    _$hash = $jc(_$hash, concealed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipModuleHold')
          ..add('cargoTons', cargoTons)
          ..add('concealed', concealed))
        .toString();
  }
}

class ShipModuleHoldBuilder
    implements Builder<ShipModuleHold, ShipModuleHoldBuilder> {
  _$ShipModuleHold? _$v;

  int? _cargoTons;
  int? get cargoTons => _$this._cargoTons;
  set cargoTons(int? cargoTons) => _$this._cargoTons = cargoTons;

  bool? _concealed;
  bool? get concealed => _$this._concealed;
  set concealed(bool? concealed) => _$this._concealed = concealed;

  ShipModuleHoldBuilder() {
    ShipModuleHold._defaults(this);
  }

  ShipModuleHoldBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cargoTons = $v.cargoTons;
      _concealed = $v.concealed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModuleHold other) {
    _$v = other as _$ShipModuleHold;
  }

  @override
  void update(void Function(ShipModuleHoldBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleHold build() => _build();

  _$ShipModuleHold _build() {
    final _$result =
        _$v ?? _$ShipModuleHold._(cargoTons: cargoTons, concealed: concealed);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
