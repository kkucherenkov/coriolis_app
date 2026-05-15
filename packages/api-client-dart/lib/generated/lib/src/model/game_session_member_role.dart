//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'game_session_member_role.g.dart';

class GameSessionMemberRole extends EnumClass {

  /// Role of a user within a GameSession.
  @BuiltValueEnumConst(wireName: r'gm')
  static const GameSessionMemberRole gm = _$gm;
  /// Role of a user within a GameSession.
  @BuiltValueEnumConst(wireName: r'player')
  static const GameSessionMemberRole player = _$player;

  static Serializer<GameSessionMemberRole> get serializer => _$gameSessionMemberRoleSerializer;

  const GameSessionMemberRole._(String name): super(name);

  static BuiltSet<GameSessionMemberRole> get values => _$values;
  static GameSessionMemberRole valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class GameSessionMemberRoleMixin = Object with _$GameSessionMemberRoleMixin;

