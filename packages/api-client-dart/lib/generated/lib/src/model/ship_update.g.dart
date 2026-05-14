// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShipUpdate extends ShipUpdate {
  @override
  final String? name;
  @override
  final String? model;
  @override
  final String? registry;
  @override
  final ShipUpdateHull? hull;
  @override
  final ShipUpdateHull? energy;
  @override
  final int? armor;
  @override
  final int? maneuverability;
  @override
  final int? signature;
  @override
  final int? speed;
  @override
  final BuiltList<String>? problems;
  @override
  final String? history;
  @override
  final String? notes;

  factory _$ShipUpdate([void Function(ShipUpdateBuilder)? updates]) =>
      (ShipUpdateBuilder()..update(updates))._build();

  _$ShipUpdate._(
      {this.name,
      this.model,
      this.registry,
      this.hull,
      this.energy,
      this.armor,
      this.maneuverability,
      this.signature,
      this.speed,
      this.problems,
      this.history,
      this.notes})
      : super._();
  @override
  ShipUpdate rebuild(void Function(ShipUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipUpdateBuilder toBuilder() => ShipUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShipUpdate &&
        name == other.name &&
        model == other.model &&
        registry == other.registry &&
        hull == other.hull &&
        energy == other.energy &&
        armor == other.armor &&
        maneuverability == other.maneuverability &&
        signature == other.signature &&
        speed == other.speed &&
        problems == other.problems &&
        history == other.history &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, model.hashCode);
    _$hash = $jc(_$hash, registry.hashCode);
    _$hash = $jc(_$hash, hull.hashCode);
    _$hash = $jc(_$hash, energy.hashCode);
    _$hash = $jc(_$hash, armor.hashCode);
    _$hash = $jc(_$hash, maneuverability.hashCode);
    _$hash = $jc(_$hash, signature.hashCode);
    _$hash = $jc(_$hash, speed.hashCode);
    _$hash = $jc(_$hash, problems.hashCode);
    _$hash = $jc(_$hash, history.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShipUpdate')
          ..add('name', name)
          ..add('model', model)
          ..add('registry', registry)
          ..add('hull', hull)
          ..add('energy', energy)
          ..add('armor', armor)
          ..add('maneuverability', maneuverability)
          ..add('signature', signature)
          ..add('speed', speed)
          ..add('problems', problems)
          ..add('history', history)
          ..add('notes', notes))
        .toString();
  }
}

class ShipUpdateBuilder implements Builder<ShipUpdate, ShipUpdateBuilder> {
  _$ShipUpdate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _model;
  String? get model => _$this._model;
  set model(String? model) => _$this._model = model;

  String? _registry;
  String? get registry => _$this._registry;
  set registry(String? registry) => _$this._registry = registry;

  ShipUpdateHullBuilder? _hull;
  ShipUpdateHullBuilder get hull => _$this._hull ??= ShipUpdateHullBuilder();
  set hull(ShipUpdateHullBuilder? hull) => _$this._hull = hull;

  ShipUpdateHullBuilder? _energy;
  ShipUpdateHullBuilder get energy =>
      _$this._energy ??= ShipUpdateHullBuilder();
  set energy(ShipUpdateHullBuilder? energy) => _$this._energy = energy;

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

  ListBuilder<String>? _problems;
  ListBuilder<String> get problems =>
      _$this._problems ??= ListBuilder<String>();
  set problems(ListBuilder<String>? problems) => _$this._problems = problems;

  String? _history;
  String? get history => _$this._history;
  set history(String? history) => _$this._history = history;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ShipUpdateBuilder() {
    ShipUpdate._defaults(this);
  }

  ShipUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _model = $v.model;
      _registry = $v.registry;
      _hull = $v.hull?.toBuilder();
      _energy = $v.energy?.toBuilder();
      _armor = $v.armor;
      _maneuverability = $v.maneuverability;
      _signature = $v.signature;
      _speed = $v.speed;
      _problems = $v.problems?.toBuilder();
      _history = $v.history;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShipUpdate other) {
    _$v = other as _$ShipUpdate;
  }

  @override
  void update(void Function(ShipUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShipUpdate build() => _build();

  _$ShipUpdate _build() {
    _$ShipUpdate _$result;
    try {
      _$result = _$v ??
          _$ShipUpdate._(
            name: name,
            model: model,
            registry: registry,
            hull: _hull?.build(),
            energy: _energy?.build(),
            armor: armor,
            maneuverability: maneuverability,
            signature: signature,
            speed: speed,
            problems: _problems?.build(),
            history: history,
            notes: notes,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'hull';
        _hull?.build();
        _$failedField = 'energy';
        _energy?.build();

        _$failedField = 'problems';
        _problems?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ShipUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
