// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_module_torpedo_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ShipModuleTorpedoCreateSlotEnum
_$shipModuleTorpedoCreateSlotEnum_TORPEDO =
    const ShipModuleTorpedoCreateSlotEnum._('TORPEDO');

ShipModuleTorpedoCreateSlotEnum _$shipModuleTorpedoCreateSlotEnumValueOf(
  String name,
) {
  switch (name) {
    case 'TORPEDO':
      return _$shipModuleTorpedoCreateSlotEnum_TORPEDO;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ShipModuleTorpedoCreateSlotEnum>
_$shipModuleTorpedoCreateSlotEnumValues =
    BuiltSet<ShipModuleTorpedoCreateSlotEnum>(
      const <ShipModuleTorpedoCreateSlotEnum>[
        _$shipModuleTorpedoCreateSlotEnum_TORPEDO,
      ],
    );

Serializer<ShipModuleTorpedoCreateSlotEnum>
_$shipModuleTorpedoCreateSlotEnumSerializer =
    _$ShipModuleTorpedoCreateSlotEnumSerializer();

class _$ShipModuleTorpedoCreateSlotEnumSerializer
    implements PrimitiveSerializer<ShipModuleTorpedoCreateSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'TORPEDO': 'TORPEDO',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'TORPEDO': 'TORPEDO',
  };

  @override
  final Iterable<Type> types = const <Type>[ShipModuleTorpedoCreateSlotEnum];
  @override
  final String wireName = 'ShipModuleTorpedoCreateSlotEnum';

  @override
  Object serialize(
    Serializers serializers,
    ShipModuleTorpedoCreateSlotEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ShipModuleTorpedoCreateSlotEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ShipModuleTorpedoCreateSlotEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ShipModuleTorpedoCreate extends ShipModuleTorpedoCreate {
  @override
  final ShipModuleTorpedoCreateSlotEnum slot;
  @override
  final String name;
  @override
  final int energyUse;
  @override
  final int? torpedoCount;
  @override
  final int? mineCount;
  @override
  final String? notes;

  factory _$ShipModuleTorpedoCreate([
    void Function(ShipModuleTorpedoCreateBuilder)? updates,
  ]) => (ShipModuleTorpedoCreateBuilder()..update(updates))._build();

  _$ShipModuleTorpedoCreate._({
    required this.slot,
    required this.name,
    required this.energyUse,
    this.torpedoCount,
    this.mineCount,
    this.notes,
  }) : super._();
  @override
  ShipModuleTorpedoCreate rebuild(
    void Function(ShipModuleTorpedoCreateBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ShipModuleTorpedoCreateBuilder toBuilder() =>
      ShipModuleTorpedoCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipModuleTorpedoCreate &&
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
    return (newBuiltValueToStringHelper(r'ShipModuleTorpedoCreate')
          ..add('slot', slot)
          ..add('name', name)
          ..add('energyUse', energyUse)
          ..add('torpedoCount', torpedoCount)
          ..add('mineCount', mineCount)
          ..add('notes', notes))
        .toString();
  }
}

class ShipModuleTorpedoCreateBuilder
    implements
        Builder<ShipModuleTorpedoCreate, ShipModuleTorpedoCreateBuilder> {
  _$ShipModuleTorpedoCreate? _$v;

  ShipModuleTorpedoCreateSlotEnum? _slot;
  ShipModuleTorpedoCreateSlotEnum? get slot => _$this._slot;
  set slot(ShipModuleTorpedoCreateSlotEnum? slot) => _$this._slot = slot;

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

  ShipModuleTorpedoCreateBuilder() {
    ShipModuleTorpedoCreate._defaults(this);
  }

  ShipModuleTorpedoCreateBuilder get _$this {
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
  void replace(ShipModuleTorpedoCreate other) {
    _$v = other as _$ShipModuleTorpedoCreate;
  }

  @override
  void update(void Function(ShipModuleTorpedoCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipModuleTorpedoCreate build() => _build();

  _$ShipModuleTorpedoCreate _build() {
    final _$result =
        _$v ??
        _$ShipModuleTorpedoCreate._(
          slot: BuiltValueNullFieldError.checkNotNull(
            slot,
            r'ShipModuleTorpedoCreate',
            'slot',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'ShipModuleTorpedoCreate',
            'name',
          ),
          energyUse: BuiltValueNullFieldError.checkNotNull(
            energyUse,
            r'ShipModuleTorpedoCreate',
            'energyUse',
          ),
          torpedoCount: torpedoCount,
          mineCount: mineCount,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
