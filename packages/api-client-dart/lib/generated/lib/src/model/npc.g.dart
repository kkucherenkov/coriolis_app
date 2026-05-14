// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'npc.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Npc extends Npc {
  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final Attributes attributes;
  @override
  final Skills skills;
  @override
  final NpcHp hp;
  @override
  final NpcMp mp;
  @override
  final int signature;
  @override
  final int? keySkillModifier;
  @override
  final BuiltList<ItemArmor> armor;
  @override
  final BuiltList<ItemWeapon> weapons;
  @override
  final BuiltList<String> tags;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$Npc([void Function(NpcBuilder)? updates]) =>
      (NpcBuilder()..update(updates))._build();

  _$Npc._(
      {required this.id,
      required this.ownerId,
      required this.name,
      this.description,
      required this.attributes,
      required this.skills,
      required this.hp,
      required this.mp,
      required this.signature,
      this.keySkillModifier,
      required this.armor,
      required this.weapons,
      required this.tags,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  Npc rebuild(void Function(NpcBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NpcBuilder toBuilder() => NpcBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Npc &&
        id == other.id &&
        ownerId == other.ownerId &&
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
        tags == other.tags &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ownerId.hashCode);
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
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Npc')
          ..add('id', id)
          ..add('ownerId', ownerId)
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
          ..add('tags', tags)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class NpcBuilder implements Builder<Npc, NpcBuilder> {
  _$Npc? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ownerId;
  String? get ownerId => _$this._ownerId;
  set ownerId(String? ownerId) => _$this._ownerId = ownerId;

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

  NpcHpBuilder? _hp;
  NpcHpBuilder get hp => _$this._hp ??= NpcHpBuilder();
  set hp(NpcHpBuilder? hp) => _$this._hp = hp;

  NpcMpBuilder? _mp;
  NpcMpBuilder get mp => _$this._mp ??= NpcMpBuilder();
  set mp(NpcMpBuilder? mp) => _$this._mp = mp;

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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  NpcBuilder() {
    Npc._defaults(this);
  }

  NpcBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ownerId = $v.ownerId;
      _name = $v.name;
      _description = $v.description;
      _attributes = $v.attributes.toBuilder();
      _skills = $v.skills.toBuilder();
      _hp = $v.hp.toBuilder();
      _mp = $v.mp.toBuilder();
      _signature = $v.signature;
      _keySkillModifier = $v.keySkillModifier;
      _armor = $v.armor.toBuilder();
      _weapons = $v.weapons.toBuilder();
      _tags = $v.tags.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Npc other) {
    _$v = other as _$Npc;
  }

  @override
  void update(void Function(NpcBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Npc build() => _build();

  _$Npc _build() {
    _$Npc _$result;
    try {
      _$result = _$v ??
          _$Npc._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Npc', 'id'),
            ownerId: BuiltValueNullFieldError.checkNotNull(
                ownerId, r'Npc', 'ownerId'),
            name: BuiltValueNullFieldError.checkNotNull(name, r'Npc', 'name'),
            description: description,
            attributes: attributes.build(),
            skills: skills.build(),
            hp: hp.build(),
            mp: mp.build(),
            signature: BuiltValueNullFieldError.checkNotNull(
                signature, r'Npc', 'signature'),
            keySkillModifier: keySkillModifier,
            armor: armor.build(),
            weapons: weapons.build(),
            tags: tags.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Npc', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'Npc', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'attributes';
        attributes.build();
        _$failedField = 'skills';
        skills.build();
        _$failedField = 'hp';
        hp.build();
        _$failedField = 'mp';
        mp.build();

        _$failedField = 'armor';
        armor.build();
        _$failedField = 'weapons';
        weapons.build();
        _$failedField = 'tags';
        tags.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Npc', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
