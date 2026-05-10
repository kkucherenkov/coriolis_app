# app_api_client.model.NpcCreate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** | NPC name (1–120 characters) | 
**description** | **String** | Free-form description (Markdown, max 2000 chars) | [optional] 
**attributes** | [**Attributes**](Attributes.md) | Attribute block; missing keys default to 2 | [optional] 
**skills** | [**Skills**](Skills.md) | Skill block; missing keys default to 0 | [optional] 
**hp** | [**NpcCreateHp**](NpcCreateHp.md) |  | [optional] 
**mp** | [**NpcCreateMp**](NpcCreateMp.md) |  | [optional] 
**signature** | **int** | Sensor signature score; defaults to 0 | [optional] [default to 0]
**keySkillModifier** | **int** | Key skill modifier for combat tracker; defaults to 0 | [optional] [default to 0]
**armor** | [**BuiltList&lt;ItemArmor&gt;**](ItemArmor.md) | Armor items; defaults to empty array | [optional] 
**weapons** | [**BuiltList&lt;ItemWeapon&gt;**](ItemWeapon.md) | Weapons; defaults to empty array | [optional] 
**tags** | **BuiltList&lt;String&gt;** | Categorisation tags; defaults to empty array | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


