// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_other.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemOtherTypeEnum _$itemOtherTypeEnum_OTHER =
    const ItemOtherTypeEnum._('OTHER');

ItemOtherTypeEnum _$itemOtherTypeEnumValueOf(String name) {
  switch (name) {
    case 'OTHER':
      return _$itemOtherTypeEnum_OTHER;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemOtherTypeEnum> _$itemOtherTypeEnumValues =
    new BuiltSet<ItemOtherTypeEnum>(const <ItemOtherTypeEnum>[
  _$itemOtherTypeEnum_OTHER,
]);

Serializer<ItemOtherTypeEnum> _$itemOtherTypeEnumSerializer =
    new _$ItemOtherTypeEnumSerializer();

class _$ItemOtherTypeEnumSerializer
    implements PrimitiveSerializer<ItemOtherTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'OTHER': 'OTHER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'OTHER': 'OTHER',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemOtherTypeEnum];
  @override
  final String wireName = 'ItemOtherTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemOtherTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemOtherTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemOtherTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemOther extends ItemOther {
  @override
  final String? notes;
  @override
  final num weight;
  @override
  final String id;
  @override
  final String type;
  @override
  final String name;

  factory _$ItemOther([void Function(ItemOtherBuilder)? updates]) =>
      (new ItemOtherBuilder()..update(updates))._build();

  _$ItemOther._(
      {this.notes,
      required this.weight,
      required this.id,
      required this.type,
      required this.name})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(weight, r'ItemOther', 'weight');
    BuiltValueNullFieldError.checkNotNull(id, r'ItemOther', 'id');
    BuiltValueNullFieldError.checkNotNull(type, r'ItemOther', 'type');
    BuiltValueNullFieldError.checkNotNull(name, r'ItemOther', 'name');
  }

  @override
  ItemOther rebuild(void Function(ItemOtherBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemOtherBuilder toBuilder() => new ItemOtherBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemOther &&
        notes == other.notes &&
        weight == other.weight &&
        id == other.id &&
        type == other.type &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemOther')
          ..add('notes', notes)
          ..add('weight', weight)
          ..add('id', id)
          ..add('type', type)
          ..add('name', name))
        .toString();
  }
}

class ItemOtherBuilder
    implements Builder<ItemOther, ItemOtherBuilder>, ItemBaseBuilder {
  _$ItemOther? _$v;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(covariant String? notes) => _$this._notes = notes;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(covariant num? weight) => _$this._weight = weight;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _type;
  String? get type => _$this._type;
  set type(covariant String? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  ItemOtherBuilder() {
    ItemOther._defaults(this);
  }

  ItemOtherBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _notes = $v.notes;
      _weight = $v.weight;
      _id = $v.id;
      _type = $v.type;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ItemOther other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemOther;
  }

  @override
  void update(void Function(ItemOtherBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemOther build() => _build();

  _$ItemOther _build() {
    final _$result = _$v ??
        new _$ItemOther._(
            notes: notes,
            weight: BuiltValueNullFieldError.checkNotNull(
                weight, r'ItemOther', 'weight'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'ItemOther', 'id'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'ItemOther', 'type'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ItemOther', 'name'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
