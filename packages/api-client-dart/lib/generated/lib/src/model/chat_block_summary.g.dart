// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_block_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatBlockSummary extends ChatBlockSummary {
  @override
  final String targetMembershipId;
  @override
  final String? targetDisplayName;
  @override
  final DateTime createdAt;

  factory _$ChatBlockSummary(
          [void Function(ChatBlockSummaryBuilder)? updates]) =>
      (ChatBlockSummaryBuilder()..update(updates))._build();

  _$ChatBlockSummary._(
      {required this.targetMembershipId,
      this.targetDisplayName,
      required this.createdAt})
      : super._();
  @override
  ChatBlockSummary rebuild(void Function(ChatBlockSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatBlockSummaryBuilder toBuilder() =>
      ChatBlockSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatBlockSummary &&
        targetMembershipId == other.targetMembershipId &&
        targetDisplayName == other.targetDisplayName &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, targetMembershipId.hashCode);
    _$hash = $jc(_$hash, targetDisplayName.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatBlockSummary')
          ..add('targetMembershipId', targetMembershipId)
          ..add('targetDisplayName', targetDisplayName)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ChatBlockSummaryBuilder
    implements Builder<ChatBlockSummary, ChatBlockSummaryBuilder> {
  _$ChatBlockSummary? _$v;

  String? _targetMembershipId;
  String? get targetMembershipId => _$this._targetMembershipId;
  set targetMembershipId(String? targetMembershipId) =>
      _$this._targetMembershipId = targetMembershipId;

  String? _targetDisplayName;
  String? get targetDisplayName => _$this._targetDisplayName;
  set targetDisplayName(String? targetDisplayName) =>
      _$this._targetDisplayName = targetDisplayName;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ChatBlockSummaryBuilder() {
    ChatBlockSummary._defaults(this);
  }

  ChatBlockSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _targetMembershipId = $v.targetMembershipId;
      _targetDisplayName = $v.targetDisplayName;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatBlockSummary other) {
    _$v = other as _$ChatBlockSummary;
  }

  @override
  void update(void Function(ChatBlockSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatBlockSummary build() => _build();

  _$ChatBlockSummary _build() {
    final _$result = _$v ??
        _$ChatBlockSummary._(
          targetMembershipId: BuiltValueNullFieldError.checkNotNull(
              targetMembershipId, r'ChatBlockSummary', 'targetMembershipId'),
          targetDisplayName: targetDisplayName,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ChatBlockSummary', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
