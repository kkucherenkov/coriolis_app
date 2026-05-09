// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeThemeEnum _$meThemeEnum_dark = const MeThemeEnum._('dark');
const MeThemeEnum _$meThemeEnum_highContrast =
    const MeThemeEnum._('highContrast');

MeThemeEnum _$meThemeEnumValueOf(String name) {
  switch (name) {
    case 'dark':
      return _$meThemeEnum_dark;
    case 'highContrast':
      return _$meThemeEnum_highContrast;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<MeThemeEnum> _$meThemeEnumValues =
    new BuiltSet<MeThemeEnum>(const <MeThemeEnum>[
  _$meThemeEnum_dark,
  _$meThemeEnum_highContrast,
]);

Serializer<MeThemeEnum> _$meThemeEnumSerializer = new _$MeThemeEnumSerializer();

class _$MeThemeEnumSerializer implements PrimitiveSerializer<MeThemeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'dark': 'dark',
    'highContrast': 'high-contrast',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'dark': 'dark',
    'high-contrast': 'highContrast',
  };

  @override
  final Iterable<Type> types = const <Type>[MeThemeEnum];
  @override
  final String wireName = 'MeThemeEnum';

  @override
  Object serialize(Serializers serializers, MeThemeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeThemeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeThemeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Me extends Me {
  @override
  final String id;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final DateTime? createdAt;
  @override
  final MeThemeEnum? theme;

  factory _$Me([void Function(MeBuilder)? updates]) =>
      (new MeBuilder()..update(updates))._build();

  _$Me._(
      {required this.id,
      required this.email,
      this.displayName,
      this.createdAt,
      this.theme})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'Me', 'id');
    BuiltValueNullFieldError.checkNotNull(email, r'Me', 'email');
  }

  @override
  Me rebuild(void Function(MeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeBuilder toBuilder() => new MeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Me &&
        id == other.id &&
        email == other.email &&
        displayName == other.displayName &&
        createdAt == other.createdAt &&
        theme == other.theme;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, theme.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Me')
          ..add('id', id)
          ..add('email', email)
          ..add('displayName', displayName)
          ..add('createdAt', createdAt)
          ..add('theme', theme))
        .toString();
  }
}

class MeBuilder implements Builder<Me, MeBuilder> {
  _$Me? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  MeThemeEnum? _theme;
  MeThemeEnum? get theme => _$this._theme;
  set theme(MeThemeEnum? theme) => _$this._theme = theme;

  MeBuilder() {
    Me._defaults(this);
  }

  MeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _displayName = $v.displayName;
      _createdAt = $v.createdAt;
      _theme = $v.theme;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Me other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Me;
  }

  @override
  void update(void Function(MeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Me build() => _build();

  _$Me _build() {
    final _$result = _$v ??
        new _$Me._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Me', 'id'),
            email: BuiltValueNullFieldError.checkNotNull(email, r'Me', 'email'),
            displayName: displayName,
            createdAt: createdAt,
            theme: theme);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
