//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:app_api_client/src/date_serializer.dart';
import 'package:app_api_client/src/model/date.dart';

import 'package:app_api_client/src/model/accept_invite_body.dart';
import 'package:app_api_client/src/model/accept_invite_response.dart';
import 'package:app_api_client/src/model/assign_character_to_session.dart';
import 'package:app_api_client/src/model/assign_crew_request.dart';
import 'package:app_api_client/src/model/attributes.dart';
import 'package:app_api_client/src/model/character.dart';
import 'package:app_api_client/src/model/character_create.dart';
import 'package:app_api_client/src/model/character_create_hp.dart';
import 'package:app_api_client/src/model/character_encumbrance.dart';
import 'package:app_api_client/src/model/character_hp.dart';
import 'package:app_api_client/src/model/character_list.dart';
import 'package:app_api_client/src/model/character_mp.dart';
import 'package:app_api_client/src/model/character_update.dart';
import 'package:app_api_client/src/model/chat_block_request.dart';
import 'package:app_api_client/src/model/chat_block_summary.dart';
import 'package:app_api_client/src/model/chat_conversation_list.dart';
import 'package:app_api_client/src/model/chat_conversation_summary.dart';
import 'package:app_api_client/src/model/chat_message.dart';
import 'package:app_api_client/src/model/chat_message_kind.dart';
import 'package:app_api_client/src/model/chat_message_list.dart';
import 'package:app_api_client/src/model/combatant.dart';
import 'package:app_api_client/src/model/combatant_create.dart';
import 'package:app_api_client/src/model/combatant_list.dart';
import 'package:app_api_client/src/model/combatant_type.dart';
import 'package:app_api_client/src/model/combatant_update.dart';
import 'package:app_api_client/src/model/concept.dart';
import 'package:app_api_client/src/model/condition_flags.dart';
import 'package:app_api_client/src/model/crew_concept.dart';
import 'package:app_api_client/src/model/crew_position.dart';
import 'package:app_api_client/src/model/crew_slot.dart';
import 'package:app_api_client/src/model/critical_injury.dart';
import 'package:app_api_client/src/model/critical_injury_severity.dart';
import 'package:app_api_client/src/model/dependency_status.dart';
import 'package:app_api_client/src/model/dp_adjustment.dart';
import 'package:app_api_client/src/model/dp_event.dart';
import 'package:app_api_client/src/model/dp_event_list.dart';
import 'package:app_api_client/src/model/dp_source.dart';
import 'package:app_api_client/src/model/edit_chat_message_request.dart';
import 'package:app_api_client/src/model/encounter.dart';
import 'package:app_api_client/src/model/encounter_create.dart';
import 'package:app_api_client/src/model/encounter_list.dart';
import 'package:app_api_client/src/model/encounter_status.dart';
import 'package:app_api_client/src/model/encounter_update.dart';
import 'package:app_api_client/src/model/game_session.dart';
import 'package:app_api_client/src/model/game_session_create.dart';
import 'package:app_api_client/src/model/game_session_list.dart';
import 'package:app_api_client/src/model/game_session_member_role.dart';
import 'package:app_api_client/src/model/game_session_membership.dart';
import 'package:app_api_client/src/model/game_session_status.dart';
import 'package:app_api_client/src/model/game_session_update.dart';
import 'package:app_api_client/src/model/get_my_memberships200_response.dart';
import 'package:app_api_client/src/model/health_status.dart';
import 'package:app_api_client/src/model/health_status_dependencies.dart';
import 'package:app_api_client/src/model/icon_id.dart';
import 'package:app_api_client/src/model/initiative_reorder_request.dart';
import 'package:app_api_client/src/model/initiative_roll_result.dart';
import 'package:app_api_client/src/model/invite_metadata.dart';
import 'package:app_api_client/src/model/invite_preview.dart';
import 'package:app_api_client/src/model/invite_rotated.dart';
import 'package:app_api_client/src/model/item.dart';
import 'package:app_api_client/src/model/item_armor.dart';
import 'package:app_api_client/src/model/item_armor_create.dart';
import 'package:app_api_client/src/model/item_armor_update.dart';
import 'package:app_api_client/src/model/item_base.dart';
import 'package:app_api_client/src/model/item_create.dart';
import 'package:app_api_client/src/model/item_cybernetic.dart';
import 'package:app_api_client/src/model/item_cybernetic_create.dart';
import 'package:app_api_client/src/model/item_cybernetic_update.dart';
import 'package:app_api_client/src/model/item_gear.dart';
import 'package:app_api_client/src/model/item_gear_create.dart';
import 'package:app_api_client/src/model/item_gear_update.dart';
import 'package:app_api_client/src/model/item_other.dart';
import 'package:app_api_client/src/model/item_other_create.dart';
import 'package:app_api_client/src/model/item_other_update.dart';
import 'package:app_api_client/src/model/item_range_enum.dart';
import 'package:app_api_client/src/model/item_ship_module.dart';
import 'package:app_api_client/src/model/item_ship_module_create.dart';
import 'package:app_api_client/src/model/item_ship_module_update.dart';
import 'package:app_api_client/src/model/item_update.dart';
import 'package:app_api_client/src/model/item_weapon.dart';
import 'package:app_api_client/src/model/item_weapon_create.dart';
import 'package:app_api_client/src/model/item_weapon_update.dart';
import 'package:app_api_client/src/model/link_membership_character_request.dart';
import 'package:app_api_client/src/model/list_blocks200_response.dart';
import 'package:app_api_client/src/model/mark_read_request.dart';
import 'package:app_api_client/src/model/me.dart';
import 'package:app_api_client/src/model/me_export_bundle.dart';
import 'package:app_api_client/src/model/me_export_encounter.dart';
import 'package:app_api_client/src/model/me_export_game_session.dart';
import 'package:app_api_client/src/model/me_export_user.dart';
import 'package:app_api_client/src/model/me_update.dart';
import 'package:app_api_client/src/model/mutant_lineage.dart';
import 'package:app_api_client/src/model/my_membership_summary.dart';
import 'package:app_api_client/src/model/npc.dart';
import 'package:app_api_client/src/model/npc_create.dart';
import 'package:app_api_client/src/model/npc_create_hp.dart';
import 'package:app_api_client/src/model/npc_create_mp.dart';
import 'package:app_api_client/src/model/npc_hp.dart';
import 'package:app_api_client/src/model/npc_list.dart';
import 'package:app_api_client/src/model/npc_mp.dart';
import 'package:app_api_client/src/model/npc_update.dart';
import 'package:app_api_client/src/model/npc_update_hp.dart';
import 'package:app_api_client/src/model/post_chat_message_request.dart';
import 'package:app_api_client/src/model/problem.dart';
import 'package:app_api_client/src/model/realtime_token.dart';
import 'package:app_api_client/src/model/relationship.dart';
import 'package:app_api_client/src/model/relationship_kind.dart';
import 'package:app_api_client/src/model/role.dart';
import 'package:app_api_client/src/model/roll.dart';
import 'package:app_api_client/src/model/roll_breakdown.dart';
import 'package:app_api_client/src/model/roll_create.dart';
import 'package:app_api_client/src/model/roll_kind.dart';
import 'package:app_api_client/src/model/roll_list.dart';
import 'package:app_api_client/src/model/share_link.dart';
import 'package:app_api_client/src/model/share_link_create.dart';
import 'package:app_api_client/src/model/share_link_list.dart';
import 'package:app_api_client/src/model/ship.dart';
import 'package:app_api_client/src/model/ship_class.dart';
import 'package:app_api_client/src/model/ship_create.dart';
import 'package:app_api_client/src/model/ship_create_energy.dart';
import 'package:app_api_client/src/model/ship_create_hull.dart';
import 'package:app_api_client/src/model/ship_energy.dart';
import 'package:app_api_client/src/model/ship_hull.dart';
import 'package:app_api_client/src/model/ship_list.dart';
import 'package:app_api_client/src/model/ship_module.dart';
import 'package:app_api_client/src/model/ship_module_base.dart';
import 'package:app_api_client/src/model/ship_module_create.dart';
import 'package:app_api_client/src/model/ship_module_hold.dart';
import 'package:app_api_client/src/model/ship_module_hold_create.dart';
import 'package:app_api_client/src/model/ship_module_hold_update.dart';
import 'package:app_api_client/src/model/ship_module_other.dart';
import 'package:app_api_client/src/model/ship_module_other_create.dart';
import 'package:app_api_client/src/model/ship_module_other_update.dart';
import 'package:app_api_client/src/model/ship_module_sensor.dart';
import 'package:app_api_client/src/model/ship_module_sensor_create.dart';
import 'package:app_api_client/src/model/ship_module_sensor_update.dart';
import 'package:app_api_client/src/model/ship_module_slot.dart';
import 'package:app_api_client/src/model/ship_module_torpedo.dart';
import 'package:app_api_client/src/model/ship_module_torpedo_create.dart';
import 'package:app_api_client/src/model/ship_module_torpedo_update.dart';
import 'package:app_api_client/src/model/ship_module_update.dart';
import 'package:app_api_client/src/model/ship_module_weapon.dart';
import 'package:app_api_client/src/model/ship_module_weapon_create.dart';
import 'package:app_api_client/src/model/ship_module_weapon_update.dart';
import 'package:app_api_client/src/model/ship_update.dart';
import 'package:app_api_client/src/model/ship_update_hull.dart';
import 'package:app_api_client/src/model/ship_weapon_range.dart';
import 'package:app_api_client/src/model/skills.dart';
import 'package:app_api_client/src/model/talent.dart';
import 'package:app_api_client/src/model/talent_create.dart';
import 'package:app_api_client/src/model/talent_kind.dart';
import 'package:app_api_client/src/model/talent_update.dart';
import 'package:app_api_client/src/model/turn_advance_result.dart';
import 'package:app_api_client/src/model/upbringing.dart';

part 'serializers.g.dart';

@SerializersFor([
  AcceptInviteBody,
  AcceptInviteResponse,
  AssignCharacterToSession,
  AssignCrewRequest,
  Attributes,
  Character,
  CharacterCreate,
  CharacterCreateHp,
  CharacterEncumbrance,
  CharacterHp,
  CharacterList,
  CharacterMp,
  CharacterUpdate,
  ChatBlockRequest,
  ChatBlockSummary,
  ChatConversationList,
  ChatConversationSummary,
  ChatMessage,
  ChatMessageKind,
  ChatMessageList,
  Combatant,
  CombatantCreate,
  CombatantList,
  CombatantType,
  CombatantUpdate,
  Concept,
  ConditionFlags,
  CrewConcept,
  CrewPosition,
  CrewSlot,
  CriticalInjury,
  CriticalInjurySeverity,
  DependencyStatus,
  DpAdjustment,
  DpEvent,
  DpEventList,
  DpSource,
  EditChatMessageRequest,
  Encounter,$Encounter,
  EncounterCreate,
  EncounterList,
  EncounterStatus,
  EncounterUpdate,
  GameSession,$GameSession,
  GameSessionCreate,
  GameSessionList,
  GameSessionMemberRole,
  GameSessionMembership,
  GameSessionStatus,
  GameSessionUpdate,
  GetMyMemberships200Response,
  HealthStatus,
  HealthStatusDependencies,
  IconId,
  InitiativeReorderRequest,
  InitiativeRollResult,
  InviteMetadata,
  InvitePreview,
  InviteRotated,
  Item,
  ItemArmor,
  ItemArmorCreate,
  ItemArmorUpdate,
  ItemBase,$ItemBase,
  ItemCreate,
  ItemCybernetic,
  ItemCyberneticCreate,
  ItemCyberneticUpdate,
  ItemGear,
  ItemGearCreate,
  ItemGearUpdate,
  ItemOther,
  ItemOtherCreate,
  ItemOtherUpdate,
  ItemRangeEnum,
  ItemShipModule,
  ItemShipModuleCreate,
  ItemShipModuleUpdate,
  ItemUpdate,
  ItemWeapon,
  ItemWeaponCreate,
  ItemWeaponUpdate,
  LinkMembershipCharacterRequest,
  ListBlocks200Response,
  MarkReadRequest,
  Me,
  MeExportBundle,
  MeExportEncounter,
  MeExportGameSession,
  MeExportUser,
  MeUpdate,
  MutantLineage,
  MyMembershipSummary,
  Npc,
  NpcCreate,
  NpcCreateHp,
  NpcCreateMp,
  NpcHp,
  NpcList,
  NpcMp,
  NpcUpdate,
  NpcUpdateHp,
  PostChatMessageRequest,
  Problem,
  RealtimeToken,
  Relationship,
  RelationshipKind,
  Role,
  Roll,
  RollBreakdown,
  RollCreate,
  RollKind,
  RollList,
  ShareLink,
  ShareLinkCreate,
  ShareLinkList,
  Ship,
  ShipClass,
  ShipCreate,
  ShipCreateEnergy,
  ShipCreateHull,
  ShipEnergy,
  ShipHull,
  ShipList,
  ShipModule,
  ShipModuleBase,$ShipModuleBase,
  ShipModuleCreate,
  ShipModuleHold,
  ShipModuleHoldCreate,
  ShipModuleHoldUpdate,
  ShipModuleOther,
  ShipModuleOtherCreate,
  ShipModuleOtherUpdate,
  ShipModuleSensor,
  ShipModuleSensorCreate,
  ShipModuleSensorUpdate,
  ShipModuleSlot,
  ShipModuleTorpedo,
  ShipModuleTorpedoCreate,
  ShipModuleTorpedoUpdate,
  ShipModuleUpdate,
  ShipModuleWeapon,
  ShipModuleWeaponCreate,
  ShipModuleWeaponUpdate,
  ShipUpdate,
  ShipUpdateHull,
  ShipWeaponRange,
  Skills,
  Talent,
  TalentCreate,
  TalentKind,
  TalentUpdate,
  TurnAdvanceResult,
  Upbringing,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(GameSessionMembership)]),
        () => ListBuilder<GameSessionMembership>(),
      )
      ..add(Encounter.serializer)
      ..add(GameSession.serializer)
      ..add(ItemBase.serializer)
      ..add(ShipModuleBase.serializer)
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
