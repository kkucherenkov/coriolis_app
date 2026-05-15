// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initiative_reorder_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InitiativeReorderRequest extends InitiativeReorderRequest {
  @override
  final BuiltList<String> combatantIds;

  factory _$InitiativeReorderRequest(
          [void Function(InitiativeReorderRequestBuilder)? updates]) =>
      (InitiativeReorderRequestBuilder()..update(updates))._build();

  _$InitiativeReorderRequest._({required this.combatantIds}) : super._();
  @override
  InitiativeReorderRequest rebuild(
          void Function(InitiativeReorderRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InitiativeReorderRequestBuilder toBuilder() =>
      InitiativeReorderRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InitiativeReorderRequest &&
        combatantIds == other.combatantIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, combatantIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InitiativeReorderRequest')
          ..add('combatantIds', combatantIds))
        .toString();
  }
}

class InitiativeReorderRequestBuilder
    implements
        Builder<InitiativeReorderRequest, InitiativeReorderRequestBuilder> {
  _$InitiativeReorderRequest? _$v;

  ListBuilder<String>? _combatantIds;
  ListBuilder<String> get combatantIds =>
      _$this._combatantIds ??= ListBuilder<String>();
  set combatantIds(ListBuilder<String>? combatantIds) =>
      _$this._combatantIds = combatantIds;

  InitiativeReorderRequestBuilder() {
    InitiativeReorderRequest._defaults(this);
  }

  InitiativeReorderRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _combatantIds = $v.combatantIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InitiativeReorderRequest other) {
    _$v = other as _$InitiativeReorderRequest;
  }

  @override
  void update(void Function(InitiativeReorderRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InitiativeReorderRequest build() => _build();

  _$InitiativeReorderRequest _build() {
    _$InitiativeReorderRequest _$result;
    try {
      _$result = _$v ??
          _$InitiativeReorderRequest._(
            combatantIds: combatantIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'combatantIds';
        combatantIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'InitiativeReorderRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
