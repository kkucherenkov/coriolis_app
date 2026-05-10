// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_link.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShareLink extends ShareLink {
  @override
  final String id;
  @override
  final String slug;
  @override
  final String characterId;
  @override
  final bool includeGmNotes;
  @override
  final String? label;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? revokedAt;
  @override
  final DateTime? lastViewedAt;
  @override
  final int viewCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$ShareLink([void Function(ShareLinkBuilder)? updates]) =>
      (ShareLinkBuilder()..update(updates))._build();

  _$ShareLink._({
    required this.id,
    required this.slug,
    required this.characterId,
    required this.includeGmNotes,
    this.label,
    this.expiresAt,
    this.revokedAt,
    this.lastViewedAt,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();
  @override
  ShareLink rebuild(void Function(ShareLinkBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShareLinkBuilder toBuilder() => ShareLinkBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShareLink &&
        id == other.id &&
        slug == other.slug &&
        characterId == other.characterId &&
        includeGmNotes == other.includeGmNotes &&
        label == other.label &&
        expiresAt == other.expiresAt &&
        revokedAt == other.revokedAt &&
        lastViewedAt == other.lastViewedAt &&
        viewCount == other.viewCount &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, slug.hashCode);
    _$hash = $jc(_$hash, characterId.hashCode);
    _$hash = $jc(_$hash, includeGmNotes.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, revokedAt.hashCode);
    _$hash = $jc(_$hash, lastViewedAt.hashCode);
    _$hash = $jc(_$hash, viewCount.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShareLink')
          ..add('id', id)
          ..add('slug', slug)
          ..add('characterId', characterId)
          ..add('includeGmNotes', includeGmNotes)
          ..add('label', label)
          ..add('expiresAt', expiresAt)
          ..add('revokedAt', revokedAt)
          ..add('lastViewedAt', lastViewedAt)
          ..add('viewCount', viewCount)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ShareLinkBuilder implements Builder<ShareLink, ShareLinkBuilder> {
  _$ShareLink? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _slug;
  String? get slug => _$this._slug;
  set slug(String? slug) => _$this._slug = slug;

  String? _characterId;
  String? get characterId => _$this._characterId;
  set characterId(String? characterId) => _$this._characterId = characterId;

  bool? _includeGmNotes;
  bool? get includeGmNotes => _$this._includeGmNotes;
  set includeGmNotes(bool? includeGmNotes) =>
      _$this._includeGmNotes = includeGmNotes;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  DateTime? _revokedAt;
  DateTime? get revokedAt => _$this._revokedAt;
  set revokedAt(DateTime? revokedAt) => _$this._revokedAt = revokedAt;

  DateTime? _lastViewedAt;
  DateTime? get lastViewedAt => _$this._lastViewedAt;
  set lastViewedAt(DateTime? lastViewedAt) =>
      _$this._lastViewedAt = lastViewedAt;

  int? _viewCount;
  int? get viewCount => _$this._viewCount;
  set viewCount(int? viewCount) => _$this._viewCount = viewCount;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ShareLinkBuilder() {
    ShareLink._defaults(this);
  }

  ShareLinkBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _slug = $v.slug;
      _characterId = $v.characterId;
      _includeGmNotes = $v.includeGmNotes;
      _label = $v.label;
      _expiresAt = $v.expiresAt;
      _revokedAt = $v.revokedAt;
      _lastViewedAt = $v.lastViewedAt;
      _viewCount = $v.viewCount;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShareLink other) {
    _$v = other as _$ShareLink;
  }

  @override
  void update(void Function(ShareLinkBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShareLink build() => _build();

  _$ShareLink _build() {
    final _$result =
        _$v ??
        _$ShareLink._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'ShareLink', 'id'),
          slug: BuiltValueNullFieldError.checkNotNull(
            slug,
            r'ShareLink',
            'slug',
          ),
          characterId: BuiltValueNullFieldError.checkNotNull(
            characterId,
            r'ShareLink',
            'characterId',
          ),
          includeGmNotes: BuiltValueNullFieldError.checkNotNull(
            includeGmNotes,
            r'ShareLink',
            'includeGmNotes',
          ),
          label: label,
          expiresAt: expiresAt,
          revokedAt: revokedAt,
          lastViewedAt: lastViewedAt,
          viewCount: BuiltValueNullFieldError.checkNotNull(
            viewCount,
            r'ShareLink',
            'viewCount',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'ShareLink',
            'createdAt',
          ),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
            updatedAt,
            r'ShareLink',
            'updatedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
