// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_torpedo_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleTorpedoUpdateSlotEnum
    _$shipModuleTorpedoUpdateSlotEnum_TORPEDO =
    const ShipModuleTorpedoUpdateSlotEnum._('TORPEDO');

ShipModuleTorpedoUpdateSlotEnum _$shipModuleTorpedoUpdateSlotEnumValueOf(
    String name) {
  switch (name) {
    case 'TORPEDO':
      return _$shipModuleTorpedoUpdateSlotEnum_TORPEDO;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleTorpedoUpdateSlotEnum>
    _$shipModuleTorpedoUpdateSlotEnumValues = BuiltSet<
        ShipModuleTorpedoUpdateSlotEnum>(const <ShipModuleTorpedoUpdateSlotEnum>[
  _$shipModuleTorpedoUpdateSlotEnum_TORPEDO,
]);

Serializer<ShipModuleTorpedoUpdateSlotEnum>
    _$shipModuleTorpedoUpdateSlotEnumSerializer =
    _$ShipModuleTorpedoUpdateSlotEnumSerializer();

class _$ShipModuleTorpedoUpdateSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleTorpedoUpdateSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'TORPEDO': 'TORPEDO',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'TORPEDO': 'TORPEDO',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleTorpedoUpdateSlotEnum];
  @override
  final String wireName = 'ShipModuleTorpedoUpdateSlotEnum';

  @override
  Object serialize(
          Serializers serializers, ShipModuleTorpedoUpdateSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ShipModuleTorpedoUpdateSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ShipModuleTorpedoUpdateSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ShipModuleTorpedoUpdate extends ShipModuleTorpedoUpdate {
  @override
  final ShipModuleTorpedoUpdateSlotEnum? slot;
  @override
  final String? name;
  @override
  final int? energyUse;
  @override
  final int? torpedoCount;
  @override
  final int? mineCount;
  @override
  final String? notes;

  factory _$ShipModuleTorpedoUpdate(
          [void Function(ShipModuleTorpedoUpdateBuilder)? updates]) =>
      (ShipModuleTorpedoUpdateBuilder()..update(updates))._build();

  _$ShipModuleTorpedoUpdate._(
      {this.slot,
      this.name,
      this.energyUse,
      this.torpedoCount,
      this.mineCount,
      this.notes})
      : super._();
  @override
  ShipModuleTorpedoUpdate rebuild(
          void Function(ShipModuleTorpedoUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipModuleTorpedoUpdateBuilder toBuilder() =>
      ShipModuleTorpedoUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleTorpedoUpdate &&
        slot == other.slot &&
        name == other.name &&
        energyUse == other.energyUse &&
        torpedoCount == other.torpedoCount &&
        mineCount == other.mineCount &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, energyUse.hashCode);
    _$hash = $jc(_$hash, torpedoCount.hashCode);
    _$hash = $jc(_$hash, mineCount.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipModuleTorpedoUpdate')
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('torpedoCount', torpedoCount)
          ..add('mineCount', mineCount)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleTorpedoUpdateBuilder
    implements
        Builder<ShipModuleTorpedoUpdate, ShipModuleTorpedoUpdateBuilder> {
  _$ShipModuleTorpedoUpdate? _$v;

  ShipModuleTorpedoUpdateSlotEnum? _slot;
  ShipModuleTorpedoUpdateSlotEnum? get slot => _$this._slot;
  set slot(ShipModuleTorpedoUpdateSlotEnum? slot) => _$this._slot = slot;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _energyUse;
  int? get energyUse => _$this._energyUse;
  set energyUse(int? energyUse) => _$this._energyUse = energyUse;

  int? _torpedoCount;
  int? get torpedoCount => _$this._torpedoCount;
  set torpedoCount(int? torpedoCount) => _$this._torpedoCount = torpedoCount;

  int? _mineCount;
  int? get mineCount => _$this._mineCount;
  set mineCount(int? mineCount) => _$this._mineCount = mineCount;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ShipModuleTorpedoUpdateBuilder() {
    ShipModuleTorpedoUpdate._defaults(this);
  }

  ShipModuleTorpedoUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _slot = $v.slot;
      _name = $v.name;
      _energyUse = $v.energyUse;
      _torpedoCount = $v.torpedoCount;
      _mineCount = $v.mineCount;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipModuleTorpedoUpdate other) {
    _$v = other as _$ShipModuleTorpedoUpdate;
  }

  @override
  void update(void Function(ShipModuleTorpedoUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleTorpedoUpdate build() => _build();

  _$ShipModuleTorpedoUpdate _build() {
    final _$result = _$v ??
        _$ShipModuleTorpedoUpdate._(
          slot: slot,
          name: name,
          energyUse: energyUse,
          torpedoCount: torpedoCount,
          mineCount: mineCount,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
