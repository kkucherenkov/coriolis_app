// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ship.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Ship extends Ship {
  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String name;
  @override
  final ShipClass class_;
  @override
  final String? model;
  @override
  final String? registry;
  @override
  final ShipHull hull;
  @override
  final ShipEnergy energy;
  @override
  final int armor;
  @override
  final int maneuverability;
  @override
  final int signature;
  @override
  final int speed;
  @override
  final int cargoCapacity;
  @override
  final BuiltList<ShipModule> modules;
  @override
  final BuiltList<CrewSlot> crew;
  @override
  final BuiltList<String> problems;
  @override
  final String? history;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$Ship([void Function(ShipBuilder)? updates]) =>
      (ShipBuilder()..update(updates))._build();

  _$Ship._(
      {required this.id,
      required this.ownerId,
      required this.name,
      required this.class_,
      this.model,
      this.registry,
      required this.hull,
      required this.energy,
      required this.armor,
      required this.maneuverability,
      required this.signature,
      required this.speed,
      required this.cargoCapacity,
      required this.modules,
      required this.crew,
      required this.problems,
      this.history,
      this.notes,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  Ship rebuild(void Function(ShipBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShipBuilder toBuilder() => ShipBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Ship &&
        id == other.id &&
        ownerId == other.ownerId &&
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
        cargoCapacity == other.cargoCapacity &&
        modules == other.modules &&
        crew == other.crew &&
        problems == other.problems &&
        history == other.history &&
        notes == other.notes &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ownerId.hashCode);
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
    _$hash = $jc(_$hash, cargoCapacity.hashCode);
    _$hash = $jc(_$hash, modules.hashCode);
    _$hash = $jc(_$hash, crew.hashCode);
    _$hash = $jc(_$hash, problems.hashCode);
    _$hash = $jc(_$hash, history.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Ship')
          ..add('id', id)
          ..add('ownerId', ownerId)
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
          ..add('cargoCapacity', cargoCapacity)
          ..add('modules', modules)
          ..add('crew', crew)
          ..add('problems', problems)
          ..add('history', history)
          ..add('notes', notes)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ShipBuilder implements Builder<Ship, ShipBuilder> {
  _$Ship? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ownerId;
  String? get ownerId => _$this._ownerId;
  set ownerId(String? ownerId) => _$this._ownerId = ownerId;

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

  ShipHullBuilder? _hull;
  ShipHullBuilder get hull => _$this._hull ??= ShipHullBuilder();
  set hull(ShipHullBuilder? hull) => _$this._hull = hull;

  ShipEnergyBuilder? _energy;
  ShipEnergyBuilder get energy => _$this._energy ??= ShipEnergyBuilder();
  set energy(ShipEnergyBuilder? energy) => _$this._energy = energy;

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

  int? _cargoCapacity;
  int? get cargoCapacity => _$this._cargoCapacity;
  set cargoCapacity(int? cargoCapacity) =>
      _$this._cargoCapacity = cargoCapacity;

  ListBuilder<ShipModule>? _modules;
  ListBuilder<ShipModule> get modules =>
      _$this._modules ??= ListBuilder<ShipModule>();
  set modules(ListBuilder<ShipModule>? modules) => _$this._modules = modules;

  ListBuilder<CrewSlot>? _crew;
  ListBuilder<CrewSlot> get crew => _$this._crew ??= ListBuilder<CrewSlot>();
  set crew(ListBuilder<CrewSlot>? crew) => _$this._crew = crew;

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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ShipBuilder() {
    Ship._defaults(this);
  }

  ShipBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ownerId = $v.ownerId;
      _name = $v.name;
      _class_ = $v.class_;
      _model = $v.model;
      _registry = $v.registry;
      _hull = $v.hull.toBuilder();
      _energy = $v.energy.toBuilder();
      _armor = $v.armor;
      _maneuverability = $v.maneuverability;
      _signature = $v.signature;
      _speed = $v.speed;
      _cargoCapacity = $v.cargoCapacity;
      _modules = $v.modules.toBuilder();
      _crew = $v.crew.toBuilder();
      _problems = $v.problems.toBuilder();
      _history = $v.history;
      _notes = $v.notes;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Ship other) {
    _$v = other as _$Ship;
  }

  @override
  void update(void Function(ShipBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Ship build() => _build();

  _$Ship _build() {
    _$Ship _$result;
    try {
      _$result = _$v ??
          _$Ship._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Ship', 'id'),
            ownerId: BuiltValueNullFieldError.checkNotNull(
                ownerId, r'Ship', 'ownerId'),
            name: BuiltValueNullFieldError.checkNotNull(name, r'Ship', 'name'),
            class_: BuiltValueNullFieldError.checkNotNull(
                class_, r'Ship', 'class_'),
            model: model,
            registry: registry,
            hull: hull.build(),
            energy: energy.build(),
            armor:
                BuiltValueNullFieldError.checkNotNull(armor, r'Ship', 'armor'),
            maneuverability: BuiltValueNullFieldError.checkNotNull(
                maneuverability, r'Ship', 'maneuverability'),
            signature: BuiltValueNullFieldError.checkNotNull(
                signature, r'Ship', 'signature'),
            speed:
                BuiltValueNullFieldError.checkNotNull(speed, r'Ship', 'speed'),
            cargoCapacity: BuiltValueNullFieldError.checkNotNull(
                cargoCapacity, r'Ship', 'cargoCapacity'),
            modules: modules.build(),
            crew: crew.build(),
            problems: problems.build(),
            history: history,
            notes: notes,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Ship', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'Ship', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'hull';
        hull.build();
        _$failedField = 'energy';
        energy.build();

        _$failedField = 'modules';
        modules.build();
        _$failedField = 'crew';
        crew.build();
        _$failedField = 'problems';
        problems.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Ship', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
