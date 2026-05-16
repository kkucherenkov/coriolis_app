// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ChatConversationSummaryKindEnum
    _$chatConversationSummaryKindEnum_broadcast =
    const ChatConversationSummaryKindEnum._('broadcast');
const ChatConversationSummaryKindEnum
    _$chatConversationSummaryKindEnum_whisper =
    const ChatConversationSummaryKindEnum._('whisper');

ChatConversationSummaryKindEnum _$chatConversationSummaryKindEnumValueOf(
    String name) {
  switch (name) {
    case 'broadcast':
      return _$chatConversationSummaryKindEnum_broadcast;
    case 'whisper':
      return _$chatConversationSummaryKindEnum_whisper;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ChatConversationSummaryKindEnum>
    _$chatConversationSummaryKindEnumValues = BuiltSet<
        ChatConversationSummaryKindEnum>(const <ChatConversationSummaryKindEnum>[
  _$chatConversationSummaryKindEnum_broadcast,
  _$chatConversationSummaryKindEnum_whisper,
]);

Serializer<ChatConversationSummaryKindEnum>
    _$chatConversationSummaryKindEnumSerializer =
    _$ChatConversationSummaryKindEnumSerializer();

class _$ChatConversationSummaryKindEnumSerializer
    implements PrimitiveSerializer<ChatConversationSummaryKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'broadcast': 'broadcast',
    'whisper': 'whisper',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'broadcast': 'broadcast',
    'whisper': 'whisper',
  };

  @override
  final Iterable<Type> types = const <Type>[ChatConversationSummaryKindEnum];
  @override
  final String wireName = 'ChatConversationSummaryKindEnum';

  @override
  Object serialize(
          Serializers serializers, ChatConversationSummaryKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ChatConversationSummaryKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ChatConversationSummaryKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ChatConversationSummary extends ChatConversationSummary {
  @override
  final String conversationKey;
  @override
  final ChatConversationSummaryKindEnum kind;
  @override
  final String? partnerMembershipId;
  @override
  final String? partnerDisplayName;
  @override
  final String? partnerCharacterName;
  @override
  final DateTime? lastMessageAt;
  @override
  final int unreadCount;

  factory _$ChatConversationSummary(
          [void Function(ChatConversationSummaryBuilder)? updates]) =>
      (ChatConversationSummaryBuilder()..update(updates))._build();

  _$ChatConversationSummary._(
      {required this.conversationKey,
      required this.kind,
      this.partnerMembershipId,
      this.partnerDisplayName,
      this.partnerCharacterName,
      this.lastMessageAt,
      required this.unreadCount})
      : super._();
  @override
  ChatConversationSummary rebuild(
          void Function(ChatConversationSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatConversationSummaryBuilder toBuilder() =>
      ChatConversationSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatConversationSummary &&
        conversationKey == other.conversationKey &&
        kind == other.kind &&
        partnerMembershipId == other.partnerMembershipId &&
        partnerDisplayName == other.partnerDisplayName &&
        partnerCharacterName == other.partnerCharacterName &&
        lastMessageAt == other.lastMessageAt &&
        unreadCount == other.unreadCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, conversationKey.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, partnerMembershipId.hashCode);
    _$hash = $jc(_$hash, partnerDisplayName.hashCode);
    _$hash = $jc(_$hash, partnerCharacterName.hashCode);
    _$hash = $jc(_$hash, lastMessageAt.hashCode);
    _$hash = $jc(_$hash, unreadCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatConversationSummary')
          ..add('conversationKey', conversationKey)
          ..add('kind', kind)
          ..add('partnerMembershipId', partnerMembershipId)
          ..add('partnerDisplayName', partnerDisplayName)
          ..add('partnerCharacterName', partnerCharacterName)
          ..add('lastMessageAt', lastMessageAt)
          ..add('unreadCount', unreadCount))
        .toString();
  }
}

class ChatConversationSummaryBuilder
    implements
        Builder<ChatConversationSummary, ChatConversationSummaryBuilder> {
  _$ChatConversationSummary? _$v;

  String? _conversationKey;
  String? get conversationKey => _$this._conversationKey;
  set conversationKey(String? conversationKey) =>
      _$this._conversationKey = conversationKey;

  ChatConversationSummaryKindEnum? _kind;
  ChatConversationSummaryKindEnum? get kind => _$this._kind;
  set kind(ChatConversationSummaryKindEnum? kind) => _$this._kind = kind;

  String? _partnerMembershipId;
  String? get partnerMembershipId => _$this._partnerMembershipId;
  set partnerMembershipId(String? partnerMembershipId) =>
      _$this._partnerMembershipId = partnerMembershipId;

  String? _partnerDisplayName;
  String? get partnerDisplayName => _$this._partnerDisplayName;
  set partnerDisplayName(String? partnerDisplayName) =>
      _$this._partnerDisplayName = partnerDisplayName;

  String? _partnerCharacterName;
  String? get partnerCharacterName => _$this._partnerCharacterName;
  set partnerCharacterName(String? partnerCharacterName) =>
      _$this._partnerCharacterName = partnerCharacterName;

  DateTime? _lastMessageAt;
  DateTime? get lastMessageAt => _$this._lastMessageAt;
  set lastMessageAt(DateTime? lastMessageAt) =>
      _$this._lastMessageAt = lastMessageAt;

  int? _unreadCount;
  int? get unreadCount => _$this._unreadCount;
  set unreadCount(int? unreadCount) => _$this._unreadCount = unreadCount;

  ChatConversationSummaryBuilder() {
    ChatConversationSummary._defaults(this);
  }

  ChatConversationSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _conversationKey = $v.conversationKey;
      _kind = $v.kind;
      _partnerMembershipId = $v.partnerMembershipId;
      _partnerDisplayName = $v.partnerDisplayName;
      _partnerCharacterName = $v.partnerCharacterName;
      _lastMessageAt = $v.lastMessageAt;
      _unreadCount = $v.unreadCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatConversationSummary other) {
    _$v = other as _$ChatConversationSummary;
  }

  @override
  void update(void Function(ChatConversationSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatConversationSummary build() => _build();

  _$ChatConversationSummary _build() {
    final _$result = _$v ??
        _$ChatConversationSummary._(
          conversationKey: BuiltValueNullFieldError.checkNotNull(
              conversationKey, r'ChatConversationSummary', 'conversationKey'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'ChatConversationSummary', 'kind'),
          partnerMembershipId: partnerMembershipId,
          partnerDisplayName: partnerDisplayName,
          partnerCharacterName: partnerCharacterName,
          lastMessageAt: lastMessageAt,
          unreadCount: BuiltValueNullFieldError.checkNotNull(
              unreadCount, r'ChatConversationSummary', 'unreadCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
