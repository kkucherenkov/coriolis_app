// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_link_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShareLinkList extends ShareLinkList {
  @override
  final BuiltList<ShareLink> items;

  factory _$ShareLinkList([void Function(ShareLinkListBuilder)? updates]) =>
      (new ShareLinkListBuilder()..update(updates))._build();

  _$ShareLinkList._({required this.items}) : super._() {
    BuiltValueNullFieldError.checkNotNull(items, r'ShareLinkList', 'items');
  }

  @override
  ShareLinkList rebuild(void Function(ShareLinkListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShareLinkListBuilder toBuilder() => new ShareLinkListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShareLinkList && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShareLinkList')..add('items', items))
        .toString();
  }
}

class ShareLinkListBuilder
    implements Builder<ShareLinkList, ShareLinkListBuilder> {
  _$ShareLinkList? _$v;

  ListBuilder<ShareLink>? _items;
  ListBuilder<ShareLink> get items =>
      _$this._items ??= new ListBuilder<ShareLink>();
  set items(ListBuilder<ShareLink>? items) => _$this._items = items;

  ShareLinkListBuilder() {
    ShareLinkList._defaults(this);
  }

  ShareLinkListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShareLinkList other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ShareLinkList;
  }

  @override
  void update(void Function(ShareLinkListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShareLinkList build() => _build();

  _$ShareLinkList _build() {
    _$ShareLinkList _$result;
    try {
      _$result = _$v ?? new _$ShareLinkList._(items: items.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ShareLinkList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
