// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipCreate extends ShipCreate {
  @override
  final String name;
  @override
  final ShipClass class_;
  @override
  final String? model;
  @override
  final String? registry;
  @override
  final ShipCreateHull? hull;
  @override
  final ShipCreateEnergy? energy;
  @override
  final int? armor;
  @override
  final int? maneuverability;
  @override
  final int? signature;
  @override
  final int? speed;
  @override
  final String? notes;
  @override
  final String? history;

  factory _$ShipCreate([void Function(ShipCreateBuilder)? updates]) =>
      (new ShipCreateBuilder()..update(updates))._build();

  _$ShipCreate._(
      {required this.name,
      required this.class_,
      this.model,
      this.registry,
      this.hull,
      this.energy,
      this.armor,
      this.maneuverability,
      this.signature,
      this.speed,
      this.notes,
      this.history})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, r'ShipCreate', 'name');
    BuiltValueNullFieldError.checkNotNull(class_, r'ShipCreate', 'class_');
  }

  @override
  ShipCreate rebuild(void Function(ShipCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipCreateBuilder toBuilder() => new ShipCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipCreate &&
        name == other.name &&
        class_ == other.class_ &&
        model == other.model &&
        registry == other.registry &&
        hull == other.hull &&
        energy == other.energy &&
        armor == other.armor &&
        maneuverability == other.maneuverability &&
        signature == other.signature &&
        speed == other.speed &&
        notes == other.notes &&
        history == other.history;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, class_.hashCode);
    _$hash = $jc(_$hash, model.hashCode);
    _$hash = $jc(_$hash, registry.hashCode);
    _$hash = $jc(_$hash, hull.hashCode);
    _$hash = $jc(_$hash, energy.hashCode);
    _$hash = $jc(_$hash, armor.hashCode);
    _$hash = $jc(_$hash, maneuverability.hashCode);
    _$hash = $jc(_$hash, signature.hashCode);
    _$hash = $jc(_$hash, speed.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, history.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipCreate')
          ..add('name', name)
          ..add('class_', class_)
          ..add('model', model)
          ..add('registry', registry)
          ..add('hull', hull)
          ..add('energy', energy)
          ..add('armor', armor)
          ..add('maneuverability', maneuverability)
          ..add('signature', signature)
          ..add('speed', speed)
          ..add('notes', notes)
          ..add('history', history))
        .toString();
  }
}

class ShipCreateBuilder implements Builder<ShipCreate, ShipCreateBuilder> {
  _$ShipCreate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ShipClass? _class_;
  ShipClass? get class_ => _$this._class_;
  set class_(ShipClass? class_) => _$this._class_ = class_;

  String? _model;
  String? get model => _$this._model;
  set model(String? model) => _$this._model = model;

  String? _registry;
  String? get registry => _$this._registry;
  set registry(String? registry) => _$this._registry = registry;

  ShipCreateHullBuilder? _hull;
  ShipCreateHullBuilder get hull =>
      _$this._hull ??= new ShipCreateHullBuilder();
  set hull(ShipCreateHullBuilder? hull) => _$this._hull = hull;

  ShipCreateEnergyBuilder? _energy;
  ShipCreateEnergyBuilder get energy =>
      _$this._energy ??= new ShipCreateEnergyBuilder();
  set energy(ShipCreateEnergyBuilder? energy) => _$this._energy = energy;

  int? _armor;
  int? get armor => _$this._armor;
  set armor(int? armor) => _$this._armor = armor;

  int? _maneuverability;
  int? get maneuverability => _$this._maneuverability;
  set maneuverability(int? maneuverability) =>
      _$this._maneuverability = maneuverability;

  int? _signature;
  int? get signature => _$this._signature;
  set signature(int? signature) => _$this._signature = signature;

  int? _speed;
  int? get speed => _$this._speed;
  set speed(int? speed) => _$this._speed = speed;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  String? _history;
  String? get history => _$this._history;
  set history(String? history) => _$this._history = history;

  ShipCreateBuilder() {
    ShipCreate._defaults(this);
  }

  ShipCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _class_ = $v.class_;
      _model = $v.model;
      _registry = $v.registry;
      _hull = $v.hull?.toBuilder();
      _energy = $v.energy?.toBuilder();
      _armor = $v.armor;
      _maneuverability = $v.maneuverability;
      _signature = $v.signature;
      _speed = $v.speed;
      _notes = $v.notes;
      _history = $v.history;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipCreate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ShipCreate;
  }

  @override
  void update(void Function(ShipCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipCreate build() => _build();

  _$ShipCreate _build() {
    _$ShipCreate _$result;
    try {
      _$result = _$v ??
          new _$ShipCreate._(
              name: BuiltValueNullFieldError.checkNotNull(
                  name, r'ShipCreate', 'name'),
              class_: BuiltValueNullFieldError.checkNotNull(
                  class_, r'ShipCreate', 'class_'),
              model: model,
              registry: registry,
              hull: _hull?.build(),
              energy: _energy?.build(),
              armor: armor,
              maneuverability: maneuverability,
              signature: signature,
              speed: speed,
              notes: notes,
              history: history);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'hull';
        _hull?.build();
        _$failedField = 'energy';
        _energy?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ShipCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
