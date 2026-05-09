// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CharacterCreateStatusEnum _$characterCreateStatusEnum_draft =
    const CharacterCreateStatusEnum._('draft');
const CharacterCreateStatusEnum _$characterCreateStatusEnum_active =
    const CharacterCreateStatusEnum._('active');

CharacterCreateStatusEnum _$characterCreateStatusEnumValueOf(String name) {
  switch (name) {
    case 'draft':
      return _$characterCreateStatusEnum_draft;
    case 'active':
      return _$characterCreateStatusEnum_active;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<CharacterCreateStatusEnum> _$characterCreateStatusEnumValues =
    new BuiltSet<CharacterCreateStatusEnum>(const <CharacterCreateStatusEnum>[
  _$characterCreateStatusEnum_draft,
  _$characterCreateStatusEnum_active,
]);

Serializer<CharacterCreateStatusEnum> _$characterCreateStatusEnumSerializer =
    new _$CharacterCreateStatusEnumSerializer();

class _$CharacterCreateStatusEnumSerializer
    implements PrimitiveSerializer<CharacterCreateStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'active': 'active',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'active': 'active',
  };

  @override
  final Iterable<Type> types = const <Type>[CharacterCreateStatusEnum];
  @override
  final String wireName = 'CharacterCreateStatusEnum';

  @override
  Object serialize(Serializers serializers, CharacterCreateStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CharacterCreateStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CharacterCreateStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CharacterCreate extends CharacterCreate {
  @override
  final String name;
  @override
  final String? concept;
  @override
  final IconId? iconId;
  @override
  final Attributes? attributes;
  @override
  final Skills? skills;
  @override
  final CharacterCreateHp? hp;
  @override
  final CharacterCreateHp? mp;
  @override
  final int? experience;
  @override
  final ConditionFlags? conditions;
  @override
  final String? notes;
  @override
  final CharacterCreateStatusEnum? status;

  factory _$CharacterCreate([void Function(CharacterCreateBuilder)? updates]) =>
      (new CharacterCreateBuilder()..update(updates))._build();

  _$CharacterCreate._(
      {required this.name,
      this.concept,
      this.iconId,
      this.attributes,
      this.skills,
      this.hp,
      this.mp,
      this.experience,
      this.conditions,
      this.notes,
      this.status})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, r'CharacterCreate', 'name');
  }

  @override
  CharacterCreate rebuild(void Function(CharacterCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterCreateBuilder toBuilder() =>
      new CharacterCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CharacterCreate &&
        name == other.name &&
        concept == other.concept &&
        iconId == other.iconId &&
        attributes == other.attributes &&
        skills == other.skills &&
        hp == other.hp &&
        mp == other.mp &&
        experience == other.experience &&
        conditions == other.conditions &&
        notes == other.notes &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, concept.hashCode);
    _$hash = $jc(_$hash, iconId.hashCode);
    _$hash = $jc(_$hash, attributes.hashCode);
    _$hash = $jc(_$hash, skills.hashCode);
    _$hash = $jc(_$hash, hp.hashCode);
    _$hash = $jc(_$hash, mp.hashCode);
    _$hash = $jc(_$hash, experience.hashCode);
    _$hash = $jc(_$hash, conditions.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CharacterCreate')
          ..add('name', name)
          ..add('concept', concept)
          ..add('iconId', iconId)
          ..add('attributes', attributes)
          ..add('skills', skills)
          ..add('hp', hp)
          ..add('mp', mp)
          ..add('experience', experience)
          ..add('conditions', conditions)
          ..add('notes', notes)
          ..add('status', status))
        .toString();
  }
}

class CharacterCreateBuilder
    implements Builder<CharacterCreate, CharacterCreateBuilder> {
  _$CharacterCreate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _concept;
  String? get concept => _$this._concept;
  set concept(String? concept) => _$this._concept = concept;

  IconId? _iconId;
  IconId? get iconId => _$this._iconId;
  set iconId(IconId? iconId) => _$this._iconId = iconId;

  AttributesBuilder? _attributes;
  AttributesBuilder get attributes =>
      _$this._attributes ??= new AttributesBuilder();
  set attributes(AttributesBuilder? attributes) =>
      _$this._attributes = attributes;

  SkillsBuilder? _skills;
  SkillsBuilder get skills => _$this._skills ??= new SkillsBuilder();
  set skills(SkillsBuilder? skills) => _$this._skills = skills;

  CharacterCreateHpBuilder? _hp;
  CharacterCreateHpBuilder get hp =>
      _$this._hp ??= new CharacterCreateHpBuilder();
  set hp(CharacterCreateHpBuilder? hp) => _$this._hp = hp;

  CharacterCreateHpBuilder? _mp;
  CharacterCreateHpBuilder get mp =>
      _$this._mp ??= new CharacterCreateHpBuilder();
  set mp(CharacterCreateHpBuilder? mp) => _$this._mp = mp;

  int? _experience;
  int? get experience => _$this._experience;
  set experience(int? experience) => _$this._experience = experience;

  ConditionFlagsBuilder? _conditions;
  ConditionFlagsBuilder get conditions =>
      _$this._conditions ??= new ConditionFlagsBuilder();
  set conditions(ConditionFlagsBuilder? conditions) =>
      _$this._conditions = conditions;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  CharacterCreateStatusEnum? _status;
  CharacterCreateStatusEnum? get status => _$this._status;
  set status(CharacterCreateStatusEnum? status) => _$this._status = status;

  CharacterCreateBuilder() {
    CharacterCreate._defaults(this);
  }

  CharacterCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _concept = $v.concept;
      _iconId = $v.iconId;
      _attributes = $v.attributes?.toBuilder();
      _skills = $v.skills?.toBuilder();
      _hp = $v.hp?.toBuilder();
      _mp = $v.mp?.toBuilder();
      _experience = $v.experience;
      _conditions = $v.conditions?.toBuilder();
      _notes = $v.notes;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CharacterCreate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$CharacterCreate;
  }

  @override
  void update(void Function(CharacterCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CharacterCreate build() => _build();

  _$CharacterCreate _build() {
    _$CharacterCreate _$result;
    try {
      _$result = _$v ??
          new _$CharacterCreate._(
              name: BuiltValueNullFieldError.checkNotNull(
                  name, r'CharacterCreate', 'name'),
              concept: concept,
              iconId: iconId,
              attributes: _attributes?.build(),
              skills: _skills?.build(),
              hp: _hp?.build(),
              mp: _mp?.build(),
              experience: experience,
              conditions: _conditions?.build(),
              notes: notes,
              status: status);
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

        _$failedField = 'conditions';
        _conditions?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'CharacterCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
