// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_export_bundle.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeExportBundleDollarSchemaVersionEnum
    _$meExportBundleDollarSchemaVersionEnum_n1 =
    const MeExportBundleDollarSchemaVersionEnum._('n1');

MeExportBundleDollarSchemaVersionEnum
    _$meExportBundleDollarSchemaVersionEnumValueOf(String name) {
  switch (name) {
    case 'n1':
      return _$meExportBundleDollarSchemaVersionEnum_n1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeExportBundleDollarSchemaVersionEnum>
    _$meExportBundleDollarSchemaVersionEnumValues = BuiltSet<
        MeExportBundleDollarSchemaVersionEnum>(const <MeExportBundleDollarSchemaVersionEnum>[
  _$meExportBundleDollarSchemaVersionEnum_n1,
]);

Serializer<MeExportBundleDollarSchemaVersionEnum>
    _$meExportBundleDollarSchemaVersionEnumSerializer =
    _$MeExportBundleDollarSchemaVersionEnumSerializer();

class _$MeExportBundleDollarSchemaVersionEnumSerializer
    implements PrimitiveSerializer<MeExportBundleDollarSchemaVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n1': '1',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '1': 'n1',
  };

  @override
  final Iterable<Type> types = const <Type>[
    MeExportBundleDollarSchemaVersionEnum
  ];
  @override
  final String wireName = 'MeExportBundleDollarSchemaVersionEnum';

  @override
  Object serialize(
          Serializers serializers, MeExportBundleDollarSchemaVersionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeExportBundleDollarSchemaVersionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeExportBundleDollarSchemaVersionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeExportBundle extends MeExportBundle {
  @override
  final MeExportBundleDollarSchemaVersionEnum dollarSchemaVersion;
  @override
  final DateTime exportedAt;
  @override
  final MeExportUser user;
  @override
  final BuiltList<Character> characters;
  @override
  final BuiltList<Ship> ships;
  @override
  final BuiltList<Npc> npcs;
  @override
  final BuiltList<MeExportGameSession> gameSessions;

  factory _$MeExportBundle([void Function(MeExportBundleBuilder)? updates]) =>
      (MeExportBundleBuilder()..update(updates))._build();

  _$MeExportBundle._(
      {required this.dollarSchemaVersion,
      required this.exportedAt,
      required this.user,
      required this.characters,
      required this.ships,
      required this.npcs,
      required this.gameSessions})
      : super._();
  @override
  MeExportBundle rebuild(void Function(MeExportBundleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeExportBundleBuilder toBuilder() => MeExportBundleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeExportBundle &&
        dollarSchemaVersion == other.dollarSchemaVersion &&
        exportedAt == other.exportedAt &&
        user == other.user &&
        characters == other.characters &&
        ships == other.ships &&
        npcs == other.npcs &&
        gameSessions == other.gameSessions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dollarSchemaVersion.hashCode);
    _$hash = $jc(_$hash, exportedAt.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, characters.hashCode);
    _$hash = $jc(_$hash, ships.hashCode);
    _$hash = $jc(_$hash, npcs.hashCode);
    _$hash = $jc(_$hash, gameSessions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeExportBundle')
          ..add('dollarSchemaVersion', dollarSchemaVersion)
          ..add('exportedAt', exportedAt)
          ..add('user', user)
          ..add('characters', characters)
          ..add('ships', ships)
          ..add('npcs', npcs)
          ..add('gameSessions', gameSessions))
        .toString();
  }
}

class MeExportBundleBuilder
    implements Builder<MeExportBundle, MeExportBundleBuilder> {
  _$MeExportBundle? _$v;

  MeExportBundleDollarSchemaVersionEnum? _dollarSchemaVersion;
  MeExportBundleDollarSchemaVersionEnum? get dollarSchemaVersion =>
      _$this._dollarSchemaVersion;
  set dollarSchemaVersion(
          MeExportBundleDollarSchemaVersionEnum? dollarSchemaVersion) =>
      _$this._dollarSchemaVersion = dollarSchemaVersion;

  DateTime? _exportedAt;
  DateTime? get exportedAt => _$this._exportedAt;
  set exportedAt(DateTime? exportedAt) => _$this._exportedAt = exportedAt;

  MeExportUserBuilder? _user;
  MeExportUserBuilder get user => _$this._user ??= MeExportUserBuilder();
  set user(MeExportUserBuilder? user) => _$this._user = user;

  ListBuilder<Character>? _characters;
  ListBuilder<Character> get characters =>
      _$this._characters ??= ListBuilder<Character>();
  set characters(ListBuilder<Character>? characters) =>
      _$this._characters = characters;

  ListBuilder<Ship>? _ships;
  ListBuilder<Ship> get ships => _$this._ships ??= ListBuilder<Ship>();
  set ships(ListBuilder<Ship>? ships) => _$this._ships = ships;

  ListBuilder<Npc>? _npcs;
  ListBuilder<Npc> get npcs => _$this._npcs ??= ListBuilder<Npc>();
  set npcs(ListBuilder<Npc>? npcs) => _$this._npcs = npcs;

  ListBuilder<MeExportGameSession>? _gameSessions;
  ListBuilder<MeExportGameSession> get gameSessions =>
      _$this._gameSessions ??= ListBuilder<MeExportGameSession>();
  set gameSessions(ListBuilder<MeExportGameSession>? gameSessions) =>
      _$this._gameSessions = gameSessions;

  MeExportBundleBuilder() {
    MeExportBundle._defaults(this);
  }

  MeExportBundleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dollarSchemaVersion = $v.dollarSchemaVersion;
      _exportedAt = $v.exportedAt;
      _user = $v.user.toBuilder();
      _characters = $v.characters.toBuilder();
      _ships = $v.ships.toBuilder();
      _npcs = $v.npcs.toBuilder();
      _gameSessions = $v.gameSessions.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeExportBundle other) {
    _$v = other as _$MeExportBundle;
  }

  @override
  void update(void Function(MeExportBundleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeExportBundle build() => _build();

  _$MeExportBundle _build() {
    _$MeExportBundle _$result;
    try {
      _$result = _$v ??
          _$MeExportBundle._(
            dollarSchemaVersion: BuiltValueNullFieldError.checkNotNull(
                dollarSchemaVersion, r'MeExportBundle', 'dollarSchemaVersion'),
            exportedAt: BuiltValueNullFieldError.checkNotNull(
                exportedAt, r'MeExportBundle', 'exportedAt'),
            user: user.build(),
            characters: characters.build(),
            ships: ships.build(),
            npcs: npcs.build(),
            gameSessions: gameSessions.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
        _$failedField = 'characters';
        characters.build();
        _$failedField = 'ships';
        ships.build();
        _$failedField = 'npcs';
        npcs.build();
        _$failedField = 'gameSessions';
        gameSessions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MeExportBundle', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
