// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_other_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ItemOtherUpdateTypeEnum _$itemOtherUpdateTypeEnum_OTHER =
    const ItemOtherUpdateTypeEnum._('OTHER');

ItemOtherUpdateTypeEnum _$itemOtherUpdateTypeEnumValueOf(String name) {
  switch (name) {
    case 'OTHER':
      return _$itemOtherUpdateTypeEnum_OTHER;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<ItemOtherUpdateTypeEnum> _$itemOtherUpdateTypeEnumValues =
    new BuiltSet<ItemOtherUpdateTypeEnum>(const <ItemOtherUpdateTypeEnum>[
  _$itemOtherUpdateTypeEnum_OTHER,
]);

Serializer<ItemOtherUpdateTypeEnum> _$itemOtherUpdateTypeEnumSerializer =
    new _$ItemOtherUpdateTypeEnumSerializer();

class _$ItemOtherUpdateTypeEnumSerializer
    implements PrimitiveSerializer<ItemOtherUpdateTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'OTHER': 'OTHER',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'OTHER': 'OTHER',
  };

  @override
  final Iterable<Type> types = const <Type>[ItemOtherUpdateTypeEnum];
  @override
  final String wireName = 'ItemOtherUpdateTypeEnum';

  @override
  Object serialize(Serializers serializers, ItemOtherUpdateTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ItemOtherUpdateTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ItemOtherUpdateTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ItemOtherUpdate extends ItemOtherUpdate {
  @override
  final ItemOtherUpdateTypeEnum? type;
  @override
  final String? name;
  @override
  final num? weight;
  @override
  final String? notes;

  factory _$ItemOtherUpdate([void Function(ItemOtherUpdateBuilder)? updates]) =>
      (new ItemOtherUpdateBuilder()..update(updates))._build();

  _$ItemOtherUpdate._({this.type, this.name, this.weight, this.notes})
      : super._();

  @override
  ItemOtherUpdate rebuild(void Function(ItemOtherUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemOtherUpdateBuilder toBuilder() =>
      new ItemOtherUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ItemOtherUpdate &&
        type == other.type &&
        name == other.name &&
        weight == other.weight &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ItemOtherUpdate')
          ..add('type', type)
          ..add('name', name)
          ..add('weight', weight)
          ..add('notes', notes))
        .toString();
  }
}

class ItemOtherUpdateBuilder
    implements Builder<ItemOtherUpdate, ItemOtherUpdateBuilder> {
  _$ItemOtherUpdate? _$v;

  ItemOtherUpdateTypeEnum? _type;
  ItemOtherUpdateTypeEnum? get type => _$this._type;
  set type(ItemOtherUpdateTypeEnum? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(num? weight) => _$this._weight = weight;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  ItemOtherUpdateBuilder() {
    ItemOtherUpdate._defaults(this);
  }

  ItemOtherUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _name = $v.name;
      _weight = $v.weight;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ItemOtherUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ItemOtherUpdate;
  }

  @override
  void update(void Function(ItemOtherUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ItemOtherUpdate build() => _build();

  _$ItemOtherUpdate _build() {
    final _$result = _$v ??
        new _$ItemOtherUpdate._(
            type: type, name: name, weight: weight, notes: notes);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
