// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeUpdateThemeEnum _$meUpdateThemeEnum_dark =
    const MeUpdateThemeEnum._('dark');
const MeUpdateThemeEnum _$meUpdateThemeEnum_highContrast =
    const MeUpdateThemeEnum._('highContrast');

MeUpdateThemeEnum _$meUpdateThemeEnumValueOf(String name) {
  switch (name) {
    case 'dark':
      return _$meUpdateThemeEnum_dark;
    case 'highContrast':
      return _$meUpdateThemeEnum_highContrast;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<MeUpdateThemeEnum> _$meUpdateThemeEnumValues =
    new BuiltSet<MeUpdateThemeEnum>(const <MeUpdateThemeEnum>[
  _$meUpdateThemeEnum_dark,
  _$meUpdateThemeEnum_highContrast,
]);

Serializer<MeUpdateThemeEnum> _$meUpdateThemeEnumSerializer =
    new _$MeUpdateThemeEnumSerializer();

class _$MeUpdateThemeEnumSerializer
    implements PrimitiveSerializer<MeUpdateThemeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'dark': 'dark',
    'highContrast': 'high-contrast',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'dark': 'dark',
    'high-contrast': 'highContrast',
  };

  @override
  final Iterable<Type> types = const <Type>[MeUpdateThemeEnum];
  @override
  final String wireName = 'MeUpdateThemeEnum';

  @override
  Object serialize(Serializers serializers, MeUpdateThemeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeUpdateThemeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeUpdateThemeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeUpdate extends MeUpdate {
  @override
  final String? displayName;
  @override
  final MeUpdateThemeEnum? theme;

  factory _$MeUpdate([void Function(MeUpdateBuilder)? updates]) =>
      (new MeUpdateBuilder()..update(updates))._build();

  _$MeUpdate._({this.displayName, this.theme}) : super._();

  @override
  MeUpdate rebuild(void Function(MeUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeUpdateBuilder toBuilder() => new MeUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeUpdate &&
        displayName == other.displayName &&
        theme == other.theme;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, theme.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeUpdate')
          ..add('displayName', displayName)
          ..add('theme', theme))
        .toString();
  }
}

class MeUpdateBuilder implements Builder<MeUpdate, MeUpdateBuilder> {
  _$MeUpdate? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  MeUpdateThemeEnum? _theme;
  MeUpdateThemeEnum? get theme => _$this._theme;
  set theme(MeUpdateThemeEnum? theme) => _$this._theme = theme;

  MeUpdateBuilder() {
    MeUpdate._defaults(this);
  }

  MeUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _theme = $v.theme;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeUpdate other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$MeUpdate;
  }

  @override
  void update(void Function(MeUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeUpdate build() => _build();

  _$MeUpdate _build() {
    final _$result =
        _$v ?? new _$MeUpdate._(displayName: displayName, theme: theme);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
