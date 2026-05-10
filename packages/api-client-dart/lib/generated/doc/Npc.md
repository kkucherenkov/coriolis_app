# app_api_client.model.Npc

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque NPC identifier (cuid2) | 
**ownerId** | **String** | Identifier of the owning user (cuid2) | 
**name** | **String** | NPC name (1–120 characters) | 
**description** | **String** | Free-form GM notes or narrative description (Markdown, max 2000 chars) | [optional] 
**attributes** | [**Attributes**](Attributes.md) |  | 
**skills** | [**Skills**](Skills.md) |  | 
**hp** | [**NpcHp**](NpcHp.md) |  | 
**mp** | [**NpcMp**](NpcMp.md) |  | 
**signature** | **int** | NPC sensor signature for ship-combat sensor checks (ST3001 ГЛАВА 14). Signed integer; 0 is baseline; negative makes the NPC harder to detect; positive makes them easier.  | [default to 0]
**keySkillModifier** | **int** | Signed integer bonus applied by the combat tracker to the NPC's attack or defence roll pool when resolving opposed key-skill checks (ST3001 ГЛАВА 14). Positive values give the NPC an advantage; negative values impose a penalty.  | [optional] [default to 0]
**armor** | [**BuiltList&lt;ItemArmor&gt;**](ItemArmor.md) | Armor items carried by the NPC | 
**weapons** | [**BuiltList&lt;ItemWeapon&gt;**](ItemWeapon.md) | Weapons carried by the NPC | 
**tags** | **BuiltList&lt;String&gt;** | Free-form GM-side categorisation labels (e.g. \"Pirate\", \"Cyborg\", \"Boss\"). Used for filtering in the NPC list and for encounter-table grouping. Each tag is a 1–40 character string.  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


