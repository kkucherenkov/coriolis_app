// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessage extends ChatMessage {
  @override
  final String id;
  @override
  final String gameSessionId;
  @override
  final String? authorMembershipId;
  @override
  final String? authorDisplayName;
  @override
  final String? targetMembershipId;
  @override
  final ChatMessageKind kind;
  @override
  final String? body;
  @override
  final String? systemKey;
  @override
  final BuiltMap<String, JsonObject?>? systemParams;
  @override
  final DateTime createdAt;
  @override
  final DateTime? editedAt;
  @override
  final DateTime? deletedAt;

  factory _$ChatMessage([void Function(ChatMessageBuilder)? updates]) =>
      (ChatMessageBuilder()..update(updates))._build();

  _$ChatMessage._(
      {required this.id,
      required this.gameSessionId,
      this.authorMembershipId,
      this.authorDisplayName,
      this.targetMembershipId,
      required this.kind,
      this.body,
      this.systemKey,
      this.systemParams,
      required this.createdAt,
      this.editedAt,
      this.deletedAt})
      : super._();
  @override
  ChatMessage rebuild(void Function(ChatMessageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessageBuilder toBuilder() => ChatMessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessage &&
        id == other.id &&
        gameSessionId == other.gameSessionId &&
        authorMembershipId == other.authorMembershipId &&
        authorDisplayName == other.authorDisplayName &&
        targetMembershipId == other.targetMembershipId &&
        kind == other.kind &&
        body == other.body &&
        systemKey == other.systemKey &&
        systemParams == other.systemParams &&
        createdAt == other.createdAt &&
        editedAt == other.editedAt &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, gameSessionId.hashCode);
    _$hash = $jc(_$hash, authorMembershipId.hashCode);
    _$hash = $jc(_$hash, authorDisplayName.hashCode);
    _$hash = $jc(_$hash, targetMembershipId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, systemKey.hashCode);
    _$hash = $jc(_$hash, systemParams.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, editedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMessage')
          ..add('id', id)
          ..add('gameSessionId', gameSessionId)
          ..add('authorMembershipId', authorMembershipId)
          ..add('authorDisplayName', authorDisplayName)
          ..add('targetMembershipId', targetMembershipId)
          ..add('kind', kind)
          ..add('body', body)
          ..add('systemKey', systemKey)
          ..add('systemParams', systemParams)
          ..add('createdAt', createdAt)
          ..add('editedAt', editedAt)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class ChatMessageBuilder implements Builder<ChatMessage, ChatMessageBuilder> {
  _$ChatMessage? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _gameSessionId;
  String? get gameSessionId => _$this._gameSessionId;
  set gameSessionId(String? gameSessionId) =>
      _$this._gameSessionId = gameSessionId;

  String? _authorMembershipId;
  String? get authorMembershipId => _$this._authorMembershipId;
  set authorMembershipId(String? authorMembershipId) =>
      _$this._authorMembershipId = authorMembershipId;

  String? _authorDisplayName;
  String? get authorDisplayName => _$this._authorDisplayName;
  set authorDisplayName(String? authorDisplayName) =>
      _$this._authorDisplayName = authorDisplayName;

  String? _targetMembershipId;
  String? get targetMembershipId => _$this._targetMembershipId;
  set targetMembershipId(String? targetMembershipId) =>
      _$this._targetMembershipId = targetMembershipId;

  ChatMessageKind? _kind;
  ChatMessageKind? get kind => _$this._kind;
  set kind(ChatMessageKind? kind) => _$this._kind = kind;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  String? _systemKey;
  String? get systemKey => _$this._systemKey;
  set systemKey(String? systemKey) => _$this._systemKey = systemKey;

  MapBuilder<String, JsonObject?>? _systemParams;
  MapBuilder<String, JsonObject?> get systemParams =>
      _$this._systemParams ??= MapBuilder<String, JsonObject?>();
  set systemParams(MapBuilder<String, JsonObject?>? systemParams) =>
      _$this._systemParams = systemParams;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _editedAt;
  DateTime? get editedAt => _$this._editedAt;
  set editedAt(DateTime? editedAt) => _$this._editedAt = editedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  ChatMessageBuilder() {
    ChatMessage._defaults(this);
  }

  ChatMessageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _gameSessionId = $v.gameSessionId;
      _authorMembershipId = $v.authorMembershipId;
      _authorDisplayName = $v.authorDisplayName;
      _targetMembershipId = $v.targetMembershipId;
      _kind = $v.kind;
      _body = $v.body;
      _systemKey = $v.systemKey;
      _systemParams = $v.systemParams?.toBuilder();
      _createdAt = $v.createdAt;
      _editedAt = $v.editedAt;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessage other) {
    _$v = other as _$ChatMessage;
  }

  @override
  void update(void Function(ChatMessageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessage build() => _build();

  _$ChatMessage _build() {
    _$ChatMessage _$result;
    try {
      _$result = _$v ??
          _$ChatMessage._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'ChatMessage', 'id'),
            gameSessionId: BuiltValueNullFieldError.checkNotNull(
                gameSessionId, r'ChatMessage', 'gameSessionId'),
            authorMembershipId: authorMembershipId,
            authorDisplayName: authorDisplayName,
            targetMembershipId: targetMembershipId,
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'ChatMessage', 'kind'),
            body: body,
            systemKey: systemKey,
            systemParams: _systemParams?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'ChatMessage', 'createdAt'),
            editedAt: editedAt,
            deletedAt: deletedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'systemParams';
        _systemParams?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ChatMessage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
