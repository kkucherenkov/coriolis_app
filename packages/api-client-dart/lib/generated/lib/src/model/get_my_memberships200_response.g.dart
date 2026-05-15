// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_my_memberships200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetMyMemberships200Response extends GetMyMemberships200Response {
  @override
  final BuiltList<MyMembershipSummary> items;

  factory _$GetMyMemberships200Response(
          [void Function(GetMyMemberships200ResponseBuilder)? updates]) =>
      (GetMyMemberships200ResponseBuilder()..update(updates))._build();

  _$GetMyMemberships200Response._({required this.items}) : super._();
  @override
  GetMyMemberships200Response rebuild(
          void Function(GetMyMemberships200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetMyMemberships200ResponseBuilder toBuilder() =>
      GetMyMemberships200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetMyMemberships200Response && items == other.items;
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
    return (newBuiltValueToStringHelper(r'GetMyMemberships200Response')
          ..add('items', items))
        .toString();
  }
}

class GetMyMemberships200ResponseBuilder
    implements
        Builder<GetMyMemberships200Response,
            GetMyMemberships200ResponseBuilder> {
  _$GetMyMemberships200Response? _$v;

  ListBuilder<MyMembershipSummary>? _items;
  ListBuilder<MyMembershipSummary> get items =>
      _$this._items ??= ListBuilder<MyMembershipSummary>();
  set items(ListBuilder<MyMembershipSummary>? items) => _$this._items = items;

  GetMyMemberships200ResponseBuilder() {
    GetMyMemberships200Response._defaults(this);
  }

  GetMyMemberships200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetMyMemberships200Response other) {
    _$v = other as _$GetMyMemberships200Response;
  }

  @override
  void update(void Function(GetMyMemberships200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetMyMemberships200Response build() => _build();

  _$GetMyMemberships200Response _build() {
    _$GetMyMemberships200Response _$result;
    try {
      _$result = _$v ??
          _$GetMyMemberships200Response._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetMyMemberships200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
