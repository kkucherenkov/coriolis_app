// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_base.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract mixin class ItemBaseBuilder {
  void replace(ItemBase other);
  void update(void Function(ItemBaseBuilder) updates);
  String? get id;
  set id(String? id);

  String? get type;
  set type(String? type);

  String? get name;
  set name(String? name);
}

class _$$ItemBase extends $ItemBase {
  @override
  final String id;
  @override
  final String type;
  @override
  final String name;

  factory _$$ItemBase([void Function($ItemBaseBuilder)? updates]) =>
      ($ItemBaseBuilder()..update(updates))._build();

  _$$ItemBase._({required this.id, required this.type, required this.name})
    : super._();
  @override
  $ItemBase rebuild(void Function($ItemBaseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $ItemBaseBuilder toBuilder() => $ItemBaseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $ItemBase &&
        id == other.id &&
        type == other.type &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$ItemBase')
          ..add('id', id)
          ..add('type', type)
          ..add('name', name))
        .toString();
  }
}

class $ItemBaseBuilder
    implements Builder<$ItemBase, $ItemBaseBuilder>, ItemBaseBuilder {
  _$$ItemBase? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _type;
  String? get type => _$this._type;
  set type(covariant String? type) => _$this._type = type;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  $ItemBaseBuilder() {
    $ItemBase._defaults(this);
  }

  $ItemBaseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $ItemBase other) {
    _$v = other as _$$ItemBase;
  }

  @override
  void update(void Function($ItemBaseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $ItemBase build() => _build();

  _$$ItemBase _build() {
    final _$result =
        _$v ??
        _$$ItemBase._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'$ItemBase', 'id'),
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'$ItemBase',
            'type',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'$ItemBase',
            'name',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
