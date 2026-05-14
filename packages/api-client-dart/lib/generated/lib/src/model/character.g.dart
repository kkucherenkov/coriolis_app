// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CharacterStatusEnum _$characterStatusEnum_draft =
    const CharacterStatusEnum._('draft');
const CharacterStatusEnum _$characterStatusEnum_active =
    const CharacterStatusEnum._('active');

CharacterStatusEnum _$characterStatusEnumValueOf(String name) {
  switch (name) {
    case 'draft':
      return _$characterStatusEnum_draft;
    case 'active':
      return _$characterStatusEnum_active;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CharacterStatusEnum> _$characterStatusEnumValues =
    BuiltSet<CharacterStatusEnum>(const <CharacterStatusEnum>[
  _$characterStatusEnum_draft,
  _$characterStatusEnum_active,
]);

Serializer<CharacterStatusEnum> _$characterStatusEnumSerializer =
    _$CharacterStatusEnumSerializer();

class _$CharacterStatusEnumSerializer
    implements PrimitiveSerializer<CharacterStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'active': 'active',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'active': 'active',
  };

  @override
  final Iterable<Type> types = const <Type>[CharacterStatusEnum];
  @override
  final String wireName = 'CharacterStatusEnum';

  @override
  Object serialize(Serializers serializers, CharacterStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CharacterStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CharacterStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Character extends Character {
  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String name;
  @override
  final Concept? concept;
  @override
  final Role? role;
  @override
  final bool? roleUnmigrated;
  @override
  final IconId? iconId;
  @override
  final Upbringing upbringing;
  @override
  final String? origin;
  @override
  final int reputation;
  @override
  final int startingWealth;
  @override
  final int birr;
  @override
  final CrewConcept? crewConcept;
  @override
  final bool mutant;
  @override
  final MutantLineage? mutantLineage;
  @override
  final Attributes attributes;
  @override
  final Skills skills;
  @override
  final CharacterHp hp;
  @override
  final CharacterMp mp;
  @override
  final CharacterEncumbrance encumbrance;
  @override
  final int experience;
  @override
  final ConditionFlags conditions;
  @override
  final BuiltList<CriticalInjury> criticalInjuries;
  @override
  final BuiltList<Talent> talents;
  @override
  final BuiltList<Relationship> relationships;
  @override
  final BuiltList<Item> inventory;
  @override
  final String? notes;
  @override
  final CharacterStatusEnum status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$Character([void Function(CharacterBuilder)? updates]) =>
      (CharacterBuilder()..update(updates))._build();

  _$Character._(
      {required this.id,
      required this.ownerId,
      required this.name,
      this.concept,
      this.role,
      this.roleUnmigrated,
      this.iconId,
      required this.upbringing,
      this.origin,
      required this.reputation,
      required this.startingWealth,
      required this.birr,
      this.crewConcept,
      required this.mutant,
      this.mutantLineage,
      required this.attributes,
      required this.skills,
      required this.hp,
      required this.mp,
      required this.encumbrance,
      required this.experience,
      required this.conditions,
      required this.criticalInjuries,
      required this.talents,
      required this.relationships,
      required this.inventory,
      this.notes,
      required this.status,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  Character rebuild(void Function(CharacterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterBuilder toBuilder() => CharacterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Character &&
        id == other.id &&
        ownerId == other.ownerId &&
        name == other.name &&
        concept == other.concept &&
        role == other.role &&
        roleUnmigrated == other.roleUnmigrated &&
        iconId == other.iconId &&
        upbringing == other.upbringing &&
        origin == other.origin &&
        reputation == other.reputation &&
        startingWealth == other.startingWealth &&
        birr == other.birr &&
        crewConcept == other.crewConcept &&
        mutant == other.mutant &&
        mutantLineage == other.mutantLineage &&
        attributes == other.attributes &&
        skills == other.skills &&
        hp == other.hp &&
        mp == other.mp &&
        encumbrance == other.encumbrance &&
        experience == other.experience &&
        conditions == other.conditions &&
        criticalInjuries == other.criticalInjuries &&
        talents == other.talents &&
        relationships == other.relationships &&
        inventory == other.inventory &&
        notes == other.notes &&
        status == other.status &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ownerId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, concept.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, roleUnmigrated.hashCode);
    _$hash = $jc(_$hash, iconId.hashCode);
    _$hash = $jc(_$hash, upbringing.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, reputation.hashCode);
    _$hash = $jc(_$hash, startingWealth.hashCode);
    _$hash = $jc(_$hash, birr.hashCode);
    _$hash = $jc(_$hash, crewConcept.hashCode);
    _$hash = $jc(_$hash, mutant.hashCode);
    _$hash = $jc(_$hash, mutantLineage.hashCode);
    _$hash = $jc(_$hash, attributes.hashCode);
    _$hash = $jc(_$hash, skills.hashCode);
    _$hash = $jc(_$hash, hp.hashCode);
    _$hash = $jc(_$hash, mp.hashCode);
    _$hash = $jc(_$hash, encumbrance.hashCode);
    _$hash = $jc(_$hash, experience.hashCode);
    _$hash = $jc(_$hash, conditions.hashCode);
    _$hash = $jc(_$hash, criticalInjuries.hashCode);
    _$hash = $jc(_$hash, talents.hashCode);
    _$hash = $jc(_$hash, relationships.hashCode);
    _$hash = $jc(_$hash, inventory.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Character')
          ..add('id', id)
          ..add('ownerId', ownerId)
          ..add('name', name)
          ..add('concept', concept)
          ..add('role', role)
          ..add('roleUnmigrated', roleUnmigrated)
          ..add('iconId', iconId)
          ..add('upbringing', upbringing)
          ..add('origin', origin)
          ..add('reputation', reputation)
          ..add('startingWealth', startingWealth)
          ..add('birr', birr)
          ..add('crewConcept', crewConcept)
          ..add('mutant', mutant)
          ..add('mutantLineage', mutantLineage)
          ..add('attributes', attributes)
          ..add('skills', skills)
          ..add('hp', hp)
          ..add('mp', mp)
          ..add('encumbrance', encumbrance)
          ..add('experience', experience)
          ..add('conditions', conditions)
          ..add('criticalInjuries', criticalInjuries)
          ..add('talents', talents)
          ..add('relationships', relationships)
          ..add('inventory', inventory)
          ..add('notes', notes)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CharacterBuilder implements Builder<Character, CharacterBuilder> {
  _$Character? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ownerId;
  String? get ownerId => _$this._ownerId;
  set ownerId(String? ownerId) => _$this._ownerId = ownerId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  Concept? _concept;
  Concept? get concept => _$this._concept;
  set concept(Concept? concept) => _$this._concept = concept;

  Role? _role;
  Role? get role => _$this._role;
  set role(Role? role) => _$this._role = role;

  bool? _roleUnmigrated;
  bool? get roleUnmigrated => _$this._roleUnmigrated;
  set roleUnmigrated(bool? roleUnmigrated) =>
      _$this._roleUnmigrated = roleUnmigrated;

  IconId? _iconId;
  IconId? get iconId => _$this._iconId;
  set iconId(IconId? iconId) => _$this._iconId = iconId;

  Upbringing? _upbringing;
  Upbringing? get upbringing => _$this._upbringing;
  set upbringing(Upbringing? upbringing) => _$this._upbringing = upbringing;

  String? _origin;
  String? get origin => _$this._origin;
  set origin(String? origin) => _$this._origin = origin;

  int? _reputation;
  int? get reputation => _$this._reputation;
  set reputation(int? reputation) => _$this._reputation = reputation;

  int? _startingWealth;
  int? get startingWealth => _$this._startingWealth;
  set startingWealth(int? startingWealth) =>
      _$this._startingWealth = startingWealth;

  int? _birr;
  int? get birr => _$this._birr;
  set birr(int? birr) => _$this._birr = birr;

  CrewConcept? _crewConcept;
  CrewConcept? get crewConcept => _$this._crewConcept;
  set crewConcept(CrewConcept? crewConcept) =>
      _$this._crewConcept = crewConcept;

  bool? _mutant;
  bool? get mutant => _$this._mutant;
  set mutant(bool? mutant) => _$this._mutant = mutant;

  MutantLineage? _mutantLineage;
  MutantLineage? get mutantLineage => _$this._mutantLineage;
  set mutantLineage(MutantLineage? mutantLineage) =>
      _$this._mutantLineage = mutantLineage;

  AttributesBuilder? _attributes;
  AttributesBuilder get attributes =>
      _$this._attributes ??= AttributesBuilder();
  set attributes(AttributesBuilder? attributes) =>
      _$this._attributes = attributes;

  SkillsBuilder? _skills;
  SkillsBuilder get skills => _$this._skills ??= SkillsBuilder();
  set skills(SkillsBuilder? skills) => _$this._skills = skills;

  CharacterHpBuilder? _hp;
  CharacterHpBuilder get hp => _$this._hp ??= CharacterHpBuilder();
  set hp(CharacterHpBuilder? hp) => _$this._hp = hp;

  CharacterMpBuilder? _mp;
  CharacterMpBuilder get mp => _$this._mp ??= CharacterMpBuilder();
  set mp(CharacterMpBuilder? mp) => _$this._mp = mp;

  CharacterEncumbranceBuilder? _encumbrance;
  CharacterEncumbranceBuilder get encumbrance =>
      _$this._encumbrance ??= CharacterEncumbranceBuilder();
  set encumbrance(CharacterEncumbranceBuilder? encumbrance) =>
      _$this._encumbrance = encumbrance;

  int? _experience;
  int? get experience => _$this._experience;
  set experience(int? experience) => _$this._experience = experience;

  ConditionFlagsBuilder? _conditions;
  ConditionFlagsBuilder get conditions =>
      _$this._conditions ??= ConditionFlagsBuilder();
  set conditions(ConditionFlagsBuilder? conditions) =>
      _$this._conditions = conditions;

  ListBuilder<CriticalInjury>? _criticalInjuries;
  ListBuilder<CriticalInjury> get criticalInjuries =>
      _$this._criticalInjuries ??= ListBuilder<CriticalInjury>();
  set criticalInjuries(ListBuilder<CriticalInjury>? criticalInjuries) =>
      _$this._criticalInjuries = criticalInjuries;

  ListBuilder<Talent>? _talents;
  ListBuilder<Talent> get talents => _$this._talents ??= ListBuilder<Talent>();
  set talents(ListBuilder<Talent>? talents) => _$this._talents = talents;

  ListBuilder<Relationship>? _relationships;
  ListBuilder<Relationship> get relationships =>
      _$this._relationships ??= ListBuilder<Relationship>();
  set relationships(ListBuilder<Relationship>? relationships) =>
      _$this._relationships = relationships;

  ListBuilder<Item>? _inventory;
  ListBuilder<Item> get inventory => _$this._inventory ??= ListBuilder<Item>();
  set inventory(ListBuilder<Item>? inventory) => _$this._inventory = inventory;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  CharacterStatusEnum? _status;
  CharacterStatusEnum? get status => _$this._status;
  set status(CharacterStatusEnum? status) => _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CharacterBuilder() {
    Character._defaults(this);
  }

  CharacterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ownerId = $v.ownerId;
      _name = $v.name;
      _concept = $v.concept;
      _role = $v.role;
      _roleUnmigrated = $v.roleUnmigrated;
      _iconId = $v.iconId;
      _upbringing = $v.upbringing;
      _origin = $v.origin;
      _reputation = $v.reputation;
      _startingWealth = $v.startingWealth;
      _birr = $v.birr;
      _crewConcept = $v.crewConcept;
      _mutant = $v.mutant;
      _mutantLineage = $v.mutantLineage;
      _attributes = $v.attributes.toBuilder();
      _skills = $v.skills.toBuilder();
      _hp = $v.hp.toBuilder();
      _mp = $v.mp.toBuilder();
      _encumbrance = $v.encumbrance.toBuilder();
      _experience = $v.experience;
      _conditions = $v.conditions.toBuilder();
      _criticalInjuries = $v.criticalInjuries.toBuilder();
      _talents = $v.talents.toBuilder();
      _relationships = $v.relationships.toBuilder();
      _inventory = $v.inventory.toBuilder();
      _notes = $v.notes;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Character other) {
    _$v = other as _$Character;
  }

  @override
  void update(void Function(CharacterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Character build() => _build();

  _$Character _build() {
    _$Character _$result;
    try {
      _$result = _$v ??
          _$Character._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Character', 'id'),
            ownerId: BuiltValueNullFieldError.checkNotNull(
                ownerId, r'Character', 'ownerId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'Character', 'name'),
            concept: concept,
            role: role,
            roleUnmigrated: roleUnmigrated,
            iconId: iconId,
            upbringing: BuiltValueNullFieldError.checkNotNull(
                upbringing, r'Character', 'upbringing'),
            origin: origin,
            reputation: BuiltValueNullFieldError.checkNotNull(
                reputation, r'Character', 'reputation'),
            startingWealth: BuiltValueNullFieldError.checkNotNull(
                startingWealth, r'Character', 'startingWealth'),
            birr: BuiltValueNullFieldError.checkNotNull(
                birr, r'Character', 'birr'),
            crewConcept: crewConcept,
            mutant: BuiltValueNullFieldError.checkNotNull(
                mutant, r'Character', 'mutant'),
            mutantLineage: mutantLineage,
            attributes: attributes.build(),
            skills: skills.build(),
            hp: hp.build(),
            mp: mp.build(),
            encumbrance: encumbrance.build(),
            experience: BuiltValueNullFieldError.checkNotNull(
                experience, r'Character', 'experience'),
            conditions: conditions.build(),
            criticalInjuries: criticalInjuries.build(),
            talents: talents.build(),
            relationships: relationships.build(),
            inventory: inventory.build(),
            notes: notes,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Character', 'status'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Character', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'Character', 'updatedAt'),
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
        _$failedField = 'encumbrance';
        encumbrance.build();

        _$failedField = 'conditions';
        conditions.build();
        _$failedField = 'criticalInjuries';
        criticalInjuries.build();
        _$failedField = 'talents';
        talents.build();
        _$failedField = 'relationships';
        relationships.build();
        _$failedField = 'inventory';
        inventory.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Character', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
