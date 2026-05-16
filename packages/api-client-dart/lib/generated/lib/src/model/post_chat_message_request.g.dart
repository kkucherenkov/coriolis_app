// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_chat_message_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostChatMessageRequestKindEnum _$postChatMessageRequestKindEnum_text =
    const PostChatMessageRequestKindEnum._('text');

PostChatMessageRequestKindEnum _$postChatMessageRequestKindEnumValueOf(
    String name) {
  switch (name) {
    case 'text':
      return _$postChatMessageRequestKindEnum_text;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostChatMessageRequestKindEnum>
    _$postChatMessageRequestKindEnumValues = BuiltSet<
        PostChatMessageRequestKindEnum>(const <PostChatMessageRequestKindEnum>[
  _$postChatMessageRequestKindEnum_text,
]);

Serializer<PostChatMessageRequestKindEnum>
    _$postChatMessageRequestKindEnumSerializer =
    _$PostChatMessageRequestKindEnumSerializer();

class _$PostChatMessageRequestKindEnumSerializer
    implements PrimitiveSerializer<PostChatMessageRequestKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'text': 'text',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'text': 'text',
  };

  @override
  final Iterable<Type> types = const <Type>[PostChatMessageRequestKindEnum];
  @override
  final String wireName = 'PostChatMessageRequestKindEnum';

  @override
  Object serialize(
          Serializers serializers, PostChatMessageRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostChatMessageRequestKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostChatMessageRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostChatMessageRequest extends PostChatMessageRequest {
  @override
  final PostChatMessageRequestKindEnum kind;
  @override
  final String body;
  @override
  final String? targetMembershipId;

  factory _$PostChatMessageRequest(
          [void Function(PostChatMessageRequestBuilder)? updates]) =>
      (PostChatMessageRequestBuilder()..update(updates))._build();

  _$PostChatMessageRequest._(
      {required this.kind, required this.body, this.targetMembershipId})
      : super._();
  @override
  PostChatMessageRequest rebuild(
          void Function(PostChatMessageRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostChatMessageRequestBuilder toBuilder() =>
      PostChatMessageRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostChatMessageRequest &&
        kind == other.kind &&
        body == other.body &&
        targetMembershipId == other.targetMembershipId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, targetMembershipId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostChatMessageRequest')
          ..add('kind', kind)
          ..add('body', body)
          ..add('targetMembershipId', targetMembershipId))
        .toString();
  }
}

class PostChatMessageRequestBuilder
    implements Builder<PostChatMessageRequest, PostChatMessageRequestBuilder> {
  _$PostChatMessageRequest? _$v;

  PostChatMessageRequestKindEnum? _kind;
  PostChatMessageRequestKindEnum? get kind => _$this._kind;
  set kind(PostChatMessageRequestKindEnum? kind) => _$this._kind = kind;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  String? _targetMembershipId;
  String? get targetMembershipId => _$this._targetMembershipId;
  set targetMembershipId(String? targetMembershipId) =>
      _$this._targetMembershipId = targetMembershipId;

  PostChatMessageRequestBuilder() {
    PostChatMessageRequest._defaults(this);
  }

  PostChatMessageRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _body = $v.body;
      _targetMembershipId = $v.targetMembershipId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostChatMessageRequest other) {
    _$v = other as _$PostChatMessageRequest;
  }

  @override
  void update(void Function(PostChatMessageRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostChatMessageRequest build() => _build();

  _$PostChatMessageRequest _build() {
    final _$result = _$v ??
        _$PostChatMessageRequest._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'PostChatMessageRequest', 'kind'),
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'PostChatMessageRequest', 'body'),
          targetMembershipId: targetMembershipId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
