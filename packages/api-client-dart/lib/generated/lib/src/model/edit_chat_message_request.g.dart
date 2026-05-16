// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_chat_message_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EditChatMessageRequest extends EditChatMessageRequest {
  @override
  final String body;

  factory _$EditChatMessageRequest(
          [void Function(EditChatMessageRequestBuilder)? updates]) =>
      (EditChatMessageRequestBuilder()..update(updates))._build();

  _$EditChatMessageRequest._({required this.body}) : super._();
  @override
  EditChatMessageRequest rebuild(
          void Function(EditChatMessageRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditChatMessageRequestBuilder toBuilder() =>
      EditChatMessageRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditChatMessageRequest && body == other.body;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditChatMessageRequest')
          ..add('body', body))
        .toString();
  }
}

class EditChatMessageRequestBuilder
    implements Builder<EditChatMessageRequest, EditChatMessageRequestBuilder> {
  _$EditChatMessageRequest? _$v;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  EditChatMessageRequestBuilder() {
    EditChatMessageRequest._defaults(this);
  }

  EditChatMessageRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditChatMessageRequest other) {
    _$v = other as _$EditChatMessageRequest;
  }

  @override
  void update(void Function(EditChatMessageRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditChatMessageRequest build() => _build();

  _$EditChatMessageRequest _build() {
    final _$result = _$v ??
        _$EditChatMessageRequest._(
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'EditChatMessageRequest', 'body'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
