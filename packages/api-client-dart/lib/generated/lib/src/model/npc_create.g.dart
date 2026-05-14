// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NpcCreate extends NpcCreate {
  @override
  final String name;
  @override
  final String? description;
  @override
  final Attributes? attributes;
  @override
  final Skills? skills;
  @override
  final NpcCreateHp? hp;
  @override
  final NpcCreateMp? mp;
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

  factory _$NpcCreate([void Function(NpcCreateBuilder)? updates]) =>
      (NpcCreateBuilder()..update(updates))._build();

  _$NpcCreate._(
      {required this.name,
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
  NpcCreate rebuild(void Function(NpcCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NpcCreateBuilder toBuilder() => NpcCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NpcCreate &&
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
    return (newBuiltValueToStringHelper(r'NpcCreate')
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

class NpcCreateBuilder implements Builder<NpcCreate, NpcCreateBuilder> {
  _$NpcCreate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  AttributesBuilder? _attributes;
  AttributesBuilder get attributes =>
      _$this._attributes ??= AttributesBuilder();
  set attributes(AttributesBuilder? attributes) =>
      _$this._attributes = attributes;

  SkillsBuilder? _skills;
  SkillsBuilder get skills => _$this._skills ??= SkillsBuilder();
  set skills(SkillsBuilder? skills) => _$this._skills = skills;

  NpcCreateHpBuilder? _hp;
  NpcCreateHpBuilder get hp => _$this._hp ??= NpcCreateHpBuilder();
  set hp(NpcCreateHpBuilder? hp) => _$this._hp = hp;

  NpcCreateMpBuilder? _mp;
  NpcCreateMpBuilder get mp => _$this._mp ??= NpcCreateMpBuilder();
  set mp(NpcCreateMpBuilder? mp) => _$this._mp = mp;

  int? _signature;
  int? get signature => _$this._signature;
  set signature(int? signature) => _$this._signature = signature;

  int? _keySkillModifier;
  int? get keySkillModifier => _$this._keySkillModifier;
  set keySkillModifier(int? keySkillModifier) =>
      _$this._keySkillModifier = keySkillModifier;

  ListBuilder<ItemArmor>? _armor;
  ListBuilder<ItemArmor> get armor =>
      _$this._armor ??= ListBuilder<ItemArmor>();
  set armor(ListBuilder<ItemArmor>? armor) => _$this._armor = armor;

  ListBuilder<ItemWeapon>? _weapons;
  ListBuilder<ItemWeapon> get weapons =>
      _$this._weapons ??= ListBuilder<ItemWeapon>();
  set weapons(ListBuilder<ItemWeapon>? weapons) => _$this._weapons = weapons;

  ListBuilder<String>? _tags;
  ListBuilder<String> get tags => _$this._tags ??= ListBuilder<String>();
  set tags(ListBuilder<String>? tags) => _$this._tags = tags;

  NpcCreateBuilder() {
    NpcCreate._defaults(this);
  }

  NpcCreateBuilder get _$this {
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
  void replace(NpcCreate other) {
    _$v = other as _$NpcCreate;
  }

  @override
  void update(void Function(NpcCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NpcCreate build() => _build();

  _$NpcCreate _build() {
    _$NpcCreate _$result;
    try {
      _$result = _$v ??
          _$NpcCreate._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'NpcCreate', 'name'),
            description: description,
            attributes: _attributes?.build(),
            skills: _skills?.build(),
            hp: _hp?.build(),
            mp: _mp?.build(),
            signature: signature,
            keySkillModifier: keySkillModifier,
            armor: _armor?.build(),
            weapons: _weapons?.build(),
            tags: _tags?.build(),
          );
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
        throw BuiltValueNestedFieldError(
            r'NpcCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
