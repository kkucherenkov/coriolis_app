// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NpcUpdate extends NpcUpdate {
  @override
  final String? name;
  @override
  final String? description;
  @override
  final Attributes? attributes;
  @override
  final Skills? skills;
  @override
  final NpcUpdateHp? hp;
  @override
  final NpcUpdateHp? mp;
  @override
  final int? signature;
  @override
  final int? keySkillModifier;
  @override
  final BuiltList<ItemArmor>? armor;
  @override
  final BuiltList<ItemWeapon>? weapons;
  @override
  final BuiltList<String>? tags;

  factory _$NpcUpdate([void Function(NpcUpdateBuilder)? updates]) =>
      (new NpcUpdateBuilder()..update(updates))._build();

  _$NpcUpdate._(
      {this.name,
      this.description,
      this.attributes,
      this.skills,
      this.hp,
      this.mp,
      this.signature,
      this.keySkillModifier,
      this.armor,
      this.weapons,
      this.tags})
      : super._();

  @override
  NpcUpdate rebuild(void Function(NpcUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NpcUpdateBuilder toBuilder() => new NpcUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NpcUpdate &&
        name == other.name &&
        description == other.description &&
        attributes == other.attributes &&
        skills == other.skills &&
        hp == other.hp &&
        mp == other.mp &&
        signature == other.signature &&
        keySkillModifier == other.keySkillModifier &&
        armor == other.armor &&
        weapons == other.weapons &&
        tags == other.tags;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, attributes.hashCode);
    _$hash = $jc(_$hash, skills.hashCode);
    _$hash = $jc(_$hash, hp.hashCode);
    _$hash = $jc(_$hash, mp.hashCode);
    _$hash = $jc(_$hash, signature.hashCode);
    _$hash = $jc(_$hash, keySkillModifier.hashCode);
    _$hash = $jc(_$hash, armor.hashCode);
    _$hash = $jc(_$hash, weapons.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NpcUpdate')
          ..add('name', name)
          ..add('description', description)
          ..add('attributes', attributes)
          ..add('skills', skills)
          ..add('hp', hp)
          ..add('mp', mp)
          ..add('signature', signature)
          ..add('keySkillModifier', keySkillModifier)
          ..add('armor', armor)
          ..add('weapons', weapons)
          ..add('tags', tags))
        .toString();
  }
}

class NpcUpdateBuilder implements Builder<NpcUpdate, NpcUpdateBuilder> {
  _$NpcUpdate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  AttributesBuilder? _attributes;
  AttributesBuilder get attributes =>
      _$this._attributes ??= new AttributesBuilder();
  set attributes(AttributesBuilder? attributes) =>
      _$this._attributes = attributes;

  SkillsBuilder? _skills;
  SkillsBuilder get skills => _$this._skills ??= new SkillsBuilder();
  set skills(SkillsBuilder? skills) => _$this._skills = skills;

  NpcUpdateHpBuilder? _hp;
  NpcUpdateHpBuilder get hp => _$this._hp ??= new NpcUpdateHpBuilder();
  set hp(NpcUpdateHpBuilder? hp) => _$this._hp = hp;

  NpcUpdateHpBuilder? _mp;
  NpcUpdateHpBuilder get mp => _$this._mp ??= new NpcUpdateHpBuilder();
  set mp(NpcUpdateHpBuilder? mp) => _$this._mp = mp;

  int? _signature;
  int? get signature => _$this._signature;
  set signature(int? signature) => _$this._signature = signature;

  int? _keySkillModifier;
  int? get keySkillModifier => _$this._keySkillModifier;
  set keySkillModifier(int? keySkillModifier) =>
      _$this._keySkillModifier = keySkillModifier;

  ListBuilder<ItemArmor>? _armor;
  ListBuilder<ItemArmor> get armor =>
      _$this._armor ??= new ListBuilder<ItemArmor>();
  set armor(ListBuilder<ItemArmor>? armor) => _$this._armor = armor;

  ListBuilder<ItemWeapon>? _weapons;
  ListBuilder<ItemWeapon> get weapons =>
      _$this._weapons ??= new ListBuilder<ItemWeapon>();
  set weapons(ListBuilder<ItemWeapon>? weapons) => _$this._weapons = weapons;

  ListBuilder<String>? _tags;
  ListBuilder<String> get tags => _$this._tags ??= new ListBuilder<String>();
  set tags(ListBuilder<String>? tags) => _$this._tags = tags;

  NpcUpdateBuilder() {
    NpcUpdate._defaults(this);
  }

  NpcUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _attributes = $v.attributes?.toBuilder();
      _skills = $v.skills?.toBuilder();
      _hp = $v.hp?.toBuilder();
      _mp = $v.mp?.toBuilder();
      _signature = $v.signature;
      _keySkillModifier = $v.keySkillModifier;
      _armor = $v.armor?.toBuilder();
      _weapons = $v.weapons?.toBuilder();
      _tags = $v.tags?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NpcUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$NpcUpdate;
  }

  @override
  void update(void Function(NpcUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NpcUpdate build() => _build();

  _$NpcUpdate _build() {
    _$NpcUpdate _$result;
    try {
      _$result = _$v ??
          new _$NpcUpdate._(
              name: name,
              description: description,
              attributes: _attributes?.build(),
              skills: _skills?.build(),
              hp: _hp?.build(),
              mp: _mp?.build(),
              signature: signature,
              keySkillModifier: keySkillModifier,
              armor: _armor?.build(),
              weapons: _weapons?.build(),
              tags: _tags?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'attributes';
        _attributes?.build();
        _$failedField = 'skills';
        _skills?.build();
        _$failedField = 'hp';
        _hp?.build();
        _$failedField = 'mp';
        _mp?.build();

        _$failedField = 'armor';
        _armor?.build();
        _$failedField = 'weapons';
        _weapons?.build();
        _$failedField = 'tags';
        _tags?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'NpcUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
