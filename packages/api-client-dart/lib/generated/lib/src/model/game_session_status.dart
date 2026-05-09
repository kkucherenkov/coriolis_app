//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'game_session_status.g.dart';

class GameSessionStatus extends EnumClass {

  /// Lifecycle state of a game session. - `active` — session is in progress or available. - `archived` — session is closed; hidden from the default list. Both directions of the transition are permitted. 
  @BuiltValueEnumConst(wireName: r'active')
  static const GameSessionStatus active = _$active;
  /// Lifecycle state of a game session. - `active` — session is in progress or available. - `archived` — session is closed; hidden from the default list. Both directions of the transition are permitted. 
  @BuiltValueEnumConst(wireName: r'archived')
  static const GameSessionStatus archived = _$archived;

  static Serializer<GameSessionStatus> get serializer => _$gameSessionStatusSerializer;

  const GameSessionStatus._(String name): super(name);

  static BuiltSet<GameSessionStatus> get values => _$values;
  static GameSessionStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class GameSessionStatusMixin = Object with _$GameSessionStatusMixin;

