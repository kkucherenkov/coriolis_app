// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_membership_character_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LinkMembershipCharacterRequest extends LinkMembershipCharacterRequest {
  @override
  final String? characterId;

  factory _$LinkMembershipCharacterRequest(
          [void Function(LinkMembershipCharacterRequestBuilder)? updates]) =>
      (LinkMembershipCharacterRequestBuilder()..update(updates))._build();

  _$LinkMembershipCharacterRequest._({this.characterId}) : super._();
  @override
  LinkMembershipCharacterRequest rebuild(
          void Function(LinkMembershipCharacterRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LinkMembershipCharacterRequestBuilder toBuilder() =>
      LinkMembershipCharacterRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LinkMembershipCharacterRequest &&
        characterId == other.characterId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, characterId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LinkMembershipCharacterRequest')
          ..add('characterId', characterId))
        .toString();
  }
}

class LinkMembershipCharacterRequestBuilder
    implements
        Builder<LinkMembershipCharacterRequest,
            LinkMembershipCharacterRequestBuilder> {
  _$LinkMembershipCharacterRequest? _$v;

  String? _characterId;
  String? get characterId => _$this._characterId;
  set characterId(String? characterId) => _$this._characterId = characterId;

  LinkMembershipCharacterRequestBuilder() {
    LinkMembershipCharacterRequest._defaults(this);
  }

  LinkMembershipCharacterRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _characterId = $v.characterId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LinkMembershipCharacterRequest other) {
    _$v = other as _$LinkMembershipCharacterRequest;
  }

  @override
  void update(void Function(LinkMembershipCharacterRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LinkMembershipCharacterRequest build() => _build();

  _$LinkMembershipCharacterRequest _build() {
    final _$result = _$v ??
        _$LinkMembershipCharacterRequest._(
          characterId: characterId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
