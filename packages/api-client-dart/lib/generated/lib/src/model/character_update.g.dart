// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CharacterUpdateStatusEnum _$characterUpdateStatusEnum_draft =
    const CharacterUpdateStatusEnum._('draft');
const CharacterUpdateStatusEnum _$characterUpdateStatusEnum_active =
    const CharacterUpdateStatusEnum._('active');

CharacterUpdateStatusEnum _$characterUpdateStatusEnumValueOf(String name) {
  switch (name) {
    case 'draft':
      return _$characterUpdateStatusEnum_draft;
    case 'active':
      return _$characterUpdateStatusEnum_active;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<CharacterUpdateStatusEnum> _$characterUpdateStatusEnumValues =
    new BuiltSet<CharacterUpdateStatusEnum>(const <CharacterUpdateStatusEnum>[
  _$characterUpdateStatusEnum_draft,
  _$characterUpdateStatusEnum_active,
]);

Serializer<CharacterUpdateStatusEnum> _$characterUpdateStatusEnumSerializer =
    new _$CharacterUpdateStatusEnumSerializer();

class _$CharacterUpdateStatusEnumSerializer
    implements PrimitiveSerializer<CharacterUpdateStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'active': 'active',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'active': 'active',
  };

  @override
  final Iterable<Type> types = const <Type>[CharacterUpdateStatusEnum];
  @override
  final String wireName = 'CharacterUpdateStatusEnum';

  @override
  Object serialize(Serializers serializers, CharacterUpdateStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CharacterUpdateStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CharacterUpdateStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CharacterUpdate extends CharacterUpdate {
  @override
  final String? name;
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
  final BuiltList<CriticalInjury>? criticalInjuries;
  @override
  final String? notes;
  @override
  final CharacterUpdateStatusEnum? status;

  factory _$CharacterUpdate([void Function(CharacterUpdateBuilder)? updates]) =>
      (new CharacterUpdateBuilder()..update(updates))._build();

  _$CharacterUpdate._(
      {this.name,
      this.concept,
      this.iconId,
      this.attributes,
      this.skills,
      this.hp,
      this.mp,
      this.experience,
      this.conditions,
      this.criticalInjuries,
      this.notes,
      this.status})
      : super._();

  @override
  CharacterUpdate rebuild(void Function(CharacterUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CharacterUpdateBuilder toBuilder() =>
      new CharacterUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CharacterUpdate &&
        name == other.name &&
        concept == other.concept &&
        iconId == other.iconId &&
        attributes == other.attributes &&
        skills == other.skills &&
        hp == other.hp &&
        mp == other.mp &&
        experience == other.experience &&
        conditions == other.conditions &&
        criticalInjuries == other.criticalInjuries &&
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
    _$hash = $jc(_$hash, criticalInjuries.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CharacterUpdate')
          ..add('name', name)
          ..add('concept', concept)
          ..add('iconId', iconId)
          ..add('attributes', attributes)
          ..add('skills', skills)
          ..add('hp', hp)
          ..add('mp', mp)
          ..add('experience', experience)
          ..add('conditions', conditions)
          ..add('criticalInjuries', criticalInjuries)
          ..add('notes', notes)
          ..add('status', status))
        .toString();
  }
}

class CharacterUpdateBuilder
    implements Builder<CharacterUpdate, CharacterUpdateBuilder> {
  _$CharacterUpdate? _$v;

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

  ListBuilder<CriticalInjury>? _criticalInjuries;
  ListBuilder<CriticalInjury> get criticalInjuries =>
      _$this._criticalInjuries ??= new ListBuilder<CriticalInjury>();
  set criticalInjuries(ListBuilder<CriticalInjury>? criticalInjuries) =>
      _$this._criticalInjuries = criticalInjuries;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  CharacterUpdateStatusEnum? _status;
  CharacterUpdateStatusEnum? get status => _$this._status;
  set status(CharacterUpdateStatusEnum? status) => _$this._status = status;

  CharacterUpdateBuilder() {
    CharacterUpdate._defaults(this);
  }

  CharacterUpdateBuilder get _$this {
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
      _criticalInjuries = $v.criticalInjuries?.toBuilder();
      _notes = $v.notes;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CharacterUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$CharacterUpdate;
  }

  @override
  void update(void Function(CharacterUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CharacterUpdate build() => _build();

  _$CharacterUpdate _build() {
    _$CharacterUpdate _$result;
    try {
      _$result = _$v ??
          new _$CharacterUpdate._(
              name: name,
              concept: concept,
              iconId: iconId,
              attributes: _attributes?.build(),
              skills: _skills?.build(),
              hp: _hp?.build(),
              mp: _mp?.build(),
              experience: experience,
              conditions: _conditions?.build(),
              criticalInjuries: _criticalInjuries?.build(),
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
        _$failedField = 'criticalInjuries';
        _criticalInjuries?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'CharacterUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
