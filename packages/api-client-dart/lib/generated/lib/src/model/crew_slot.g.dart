// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crew_slot.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CrewSlot extends CrewSlot {
  @override
  final CrewPosition position;
  @override
  final String? assignedCharacterId;

  factory _$CrewSlot([void Function(CrewSlotBuilder)? updates]) =>
      (new CrewSlotBuilder()..update(updates))._build();

  _$CrewSlot._({required this.position, this.assignedCharacterId}) : super._() {
    BuiltValueNullFieldError.checkNotNull(position, r'CrewSlot', 'position');
  }

  @override
  CrewSlot rebuild(void Function(CrewSlotBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CrewSlotBuilder toBuilder() => new CrewSlotBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CrewSlot &&
        position == other.position &&
        assignedCharacterId == other.assignedCharacterId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, assignedCharacterId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CrewSlot')
          ..add('position', position)
          ..add('assignedCharacterId', assignedCharacterId))
        .toString();
  }
}

class CrewSlotBuilder implements Builder<CrewSlot, CrewSlotBuilder> {
  _$CrewSlot? _$v;

  CrewPosition? _position;
  CrewPosition? get position => _$this._position;
  set position(CrewPosition? position) => _$this._position = position;

  String? _assignedCharacterId;
  String? get assignedCharacterId => _$this._assignedCharacterId;
  set assignedCharacterId(String? assignedCharacterId) =>
      _$this._assignedCharacterId = assignedCharacterId;

  CrewSlotBuilder() {
    CrewSlot._defaults(this);
  }

  CrewSlotBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _position = $v.position;
      _assignedCharacterId = $v.assignedCharacterId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CrewSlot other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$CrewSlot;
  }

  @override
  void update(void Function(CrewSlotBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CrewSlot build() => _build();

  _$CrewSlot _build() {
    final _$result = _$v ??
        new _$CrewSlot._(
            position: BuiltValueNullFieldError.checkNotNull(
                position, r'CrewSlot', 'position'),
            assignedCharacterId: assignedCharacterId);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
