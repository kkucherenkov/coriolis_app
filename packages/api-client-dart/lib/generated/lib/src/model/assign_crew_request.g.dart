// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_crew_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AssignCrewRequest extends AssignCrewRequest {
  @override
  final CrewPosition position;
  @override
  final String characterId;

  factory _$AssignCrewRequest(
          [void Function(AssignCrewRequestBuilder)? updates]) =>
      (AssignCrewRequestBuilder()..update(updates))._build();

  _$AssignCrewRequest._({required this.position, required this.characterId})
      : super._();
  @override
  AssignCrewRequest rebuild(void Function(AssignCrewRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AssignCrewRequestBuilder toBuilder() =>
      AssignCrewRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AssignCrewRequest &&
        position == other.position &&
        characterId == other.characterId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, characterId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AssignCrewRequest')
          ..add('position', position)
          ..add('characterId', characterId))
        .toString();
  }
}

class AssignCrewRequestBuilder
    implements Builder<AssignCrewRequest, AssignCrewRequestBuilder> {
  _$AssignCrewRequest? _$v;

  CrewPosition? _position;
  CrewPosition? get position => _$this._position;
  set position(CrewPosition? position) => _$this._position = position;

  String? _characterId;
  String? get characterId => _$this._characterId;
  set characterId(String? characterId) => _$this._characterId = characterId;

  AssignCrewRequestBuilder() {
    AssignCrewRequest._defaults(this);
  }

  AssignCrewRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _position = $v.position;
      _characterId = $v.characterId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AssignCrewRequest other) {
    _$v = other as _$AssignCrewRequest;
  }

  @override
  void update(void Function(AssignCrewRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AssignCrewRequest build() => _build();

  _$AssignCrewRequest _build() {
    final _$result = _$v ??
        _$AssignCrewRequest._(
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'AssignCrewRequest', 'position'),
          characterId: BuiltValueNullFieldError.checkNotNull(
              characterId, r'AssignCrewRequest', 'characterId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
