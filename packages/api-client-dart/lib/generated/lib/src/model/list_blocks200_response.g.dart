// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_blocks200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListBlocks200Response extends ListBlocks200Response {
  @override
  final BuiltList<ChatBlockSummary> items;

  factory _$ListBlocks200Response(
          [void Function(ListBlocks200ResponseBuilder)? updates]) =>
      (ListBlocks200ResponseBuilder()..update(updates))._build();

  _$ListBlocks200Response._({required this.items}) : super._();
  @override
  ListBlocks200Response rebuild(
          void Function(ListBlocks200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListBlocks200ResponseBuilder toBuilder() =>
      ListBlocks200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListBlocks200Response && items == other.items;
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
    return (newBuiltValueToStringHelper(r'ListBlocks200Response')
          ..add('items', items))
        .toString();
  }
}

class ListBlocks200ResponseBuilder
    implements Builder<ListBlocks200Response, ListBlocks200ResponseBuilder> {
  _$ListBlocks200Response? _$v;

  ListBuilder<ChatBlockSummary>? _items;
  ListBuilder<ChatBlockSummary> get items =>
      _$this._items ??= ListBuilder<ChatBlockSummary>();
  set items(ListBuilder<ChatBlockSummary>? items) => _$this._items = items;

  ListBlocks200ResponseBuilder() {
    ListBlocks200Response._defaults(this);
  }

  ListBlocks200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListBlocks200Response other) {
    _$v = other as _$ListBlocks200Response;
  }

  @override
  void update(void Function(ListBlocks200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListBlocks200Response build() => _build();

  _$ListBlocks200Response _build() {
    _$ListBlocks200Response _$result;
    try {
      _$result = _$v ??
          _$ListBlocks200Response._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListBlocks200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
