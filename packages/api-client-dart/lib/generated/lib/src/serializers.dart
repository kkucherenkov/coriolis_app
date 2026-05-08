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

import 'package:app_api_client/src/model/attributes.dart';
import 'package:app_api_client/src/model/character.dart';
import 'package:app_api_client/src/model/character_create.dart';
import 'package:app_api_client/src/model/character_create_hp.dart';
import 'package:app_api_client/src/model/character_encumbrance.dart';
import 'package:app_api_client/src/model/character_hp.dart';
import 'package:app_api_client/src/model/character_list.dart';
import 'package:app_api_client/src/model/character_mp.dart';
import 'package:app_api_client/src/model/character_update.dart';
import 'package:app_api_client/src/model/condition_flags.dart';
import 'package:app_api_client/src/model/critical_injury.dart';
import 'package:app_api_client/src/model/critical_injury_severity.dart';
import 'package:app_api_client/src/model/dependency_status.dart';
import 'package:app_api_client/src/model/health_status.dart';
import 'package:app_api_client/src/model/health_status_dependencies.dart';
import 'package:app_api_client/src/model/icon_id.dart';
import 'package:app_api_client/src/model/item.dart';
import 'package:app_api_client/src/model/item_armor.dart';
import 'package:app_api_client/src/model/item_base.dart';
import 'package:app_api_client/src/model/item_create.dart';
import 'package:app_api_client/src/model/item_create_one_of.dart';
import 'package:app_api_client/src/model/item_create_one_of1.dart';
import 'package:app_api_client/src/model/item_create_one_of2.dart';
import 'package:app_api_client/src/model/item_create_one_of3.dart';
import 'package:app_api_client/src/model/item_create_one_of4.dart';
import 'package:app_api_client/src/model/item_create_one_of5.dart';
import 'package:app_api_client/src/model/item_cybernetic.dart';
import 'package:app_api_client/src/model/item_gear.dart';
import 'package:app_api_client/src/model/item_other.dart';
import 'package:app_api_client/src/model/item_range_enum.dart';
import 'package:app_api_client/src/model/item_ship_module.dart';
import 'package:app_api_client/src/model/item_slot_type.dart';
import 'package:app_api_client/src/model/item_update.dart';
import 'package:app_api_client/src/model/item_weapon.dart';
import 'package:app_api_client/src/model/me.dart';
import 'package:app_api_client/src/model/me_update.dart';
import 'package:app_api_client/src/model/model0.dart';
import 'package:app_api_client/src/model/model1.dart';
import 'package:app_api_client/src/model/model2.dart';
import 'package:app_api_client/src/model/model3.dart';
import 'package:app_api_client/src/model/model4.dart';
import 'package:app_api_client/src/model/model5.dart';
import 'package:app_api_client/src/model/problem.dart';
import 'package:app_api_client/src/model/realtime_token.dart';
import 'package:app_api_client/src/model/relationship.dart';
import 'package:app_api_client/src/model/relationship_kind.dart';
import 'package:app_api_client/src/model/skills.dart';
import 'package:app_api_client/src/model/talent.dart';
import 'package:app_api_client/src/model/talent_create.dart';
import 'package:app_api_client/src/model/talent_update.dart';

part 'serializers.g.dart';

@SerializersFor([
  Attributes,
  Character,
  CharacterCreate,
  CharacterCreateHp,
  CharacterEncumbrance,
  CharacterHp,
  CharacterList,
  CharacterMp,
  CharacterUpdate,
  ConditionFlags,
  CriticalInjury,
  CriticalInjurySeverity,
  DependencyStatus,
  HealthStatus,
  HealthStatusDependencies,
  IconId,
  Item,
  ItemArmor,
  ItemBase,$ItemBase,
  ItemCreate,
  ItemCreateOneOf,
  ItemCreateOneOf1,
  ItemCreateOneOf2,
  ItemCreateOneOf3,
  ItemCreateOneOf4,
  ItemCreateOneOf5,
  ItemCybernetic,
  ItemGear,
  ItemOther,
  ItemRangeEnum,
  ItemShipModule,
  ItemSlotType,
  ItemUpdate,
  ItemWeapon,
  Me,
  MeUpdate,
  Model0,
  Model1,
  Model2,
  Model3,
  Model4,
  Model5,
  Problem,
  RealtimeToken,
  Relationship,
  RelationshipKind,
  Skills,
  Talent,
  TalentCreate,
  TalentUpdate,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(ItemBase.serializer)
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
