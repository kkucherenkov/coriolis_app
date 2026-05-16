// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_block_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatBlockRequest extends ChatBlockRequest {
  @override
  final String targetMembershipId;

  factory _$ChatBlockRequest(
          [void Function(ChatBlockRequestBuilder)? updates]) =>
      (ChatBlockRequestBuilder()..update(updates))._build();

  _$ChatBlockRequest._({required this.targetMembershipId}) : super._();
  @override
  ChatBlockRequest rebuild(void Function(ChatBlockRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatBlockRequestBuilder toBuilder() =>
      ChatBlockRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatBlockRequest &&
        targetMembershipId == other.targetMembershipId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, targetMembershipId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatBlockRequest')
          ..add('targetMembershipId', targetMembershipId))
        .toString();
  }
}

class ChatBlockRequestBuilder
    implements Builder<ChatBlockRequest, ChatBlockRequestBuilder> {
  _$ChatBlockRequest? _$v;

  String? _targetMembershipId;
  String? get targetMembershipId => _$this._targetMembershipId;
  set targetMembershipId(String? targetMembershipId) =>
      _$this._targetMembershipId = targetMembershipId;

  ChatBlockRequestBuilder() {
    ChatBlockRequest._defaults(this);
  }

  ChatBlockRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _targetMembershipId = $v.targetMembershipId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatBlockRequest other) {
    _$v = other as _$ChatBlockRequest;
  }

  @override
  void update(void Function(ChatBlockRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatBlockRequest build() => _build();

  _$ChatBlockRequest _build() {
    final _$result = _$v ??
        _$ChatBlockRequest._(
          targetMembershipId: BuiltValueNullFieldError.checkNotNull(
              targetMembershipId, r'ChatBlockRequest', 'targetMembershipId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
