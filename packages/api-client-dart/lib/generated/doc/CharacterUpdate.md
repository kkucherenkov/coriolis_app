# app_api_client.model.CharacterUpdate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | [optional] 
**concept** | [**Concept**](Concept.md) |  | [optional] 
**iconId** | [**IconId**](IconId.md) |  | [optional] 
**upbringing** | [**Upbringing**](Upbringing.md) | Allowed only while `status` is `draft` — used by the wizard to let players reconsider their pick before forging. Once the character is `active`, this field is immutable.  | [optional] 
**origin** | **String** |  | [optional] 
**reputation** | **int** | Update the character's current reputation (e.g. after a roleplay event). Initial value is set from `upbringing` at creation time; while the character is a `draft`, changing `upbringing` resets `reputation` to the new upbringing's baseline.  | [optional] 
**attributes** | [**Attributes**](Attributes.md) |  | [optional] 
**skills** | [**Skills**](Skills.md) |  | [optional] 
**hp** | [**CharacterCreateHp**](CharacterCreateHp.md) |  | [optional] 
**mp** | [**CharacterCreateHp**](CharacterCreateHp.md) |  | [optional] 
**experience** | **int** |  | [optional] 
**conditions** | [**ConditionFlags**](ConditionFlags.md) |  | [optional] 
**criticalInjuries** | [**BuiltList&lt;CriticalInjury&gt;**](CriticalInjury.md) | Replaces the entire critical injuries list when provided. Use the dedicated nested-item pattern (POST/PATCH/DELETE on individual injuries) once that surface is added in a later epic.  | [optional] 
**notes** | **String** |  | [optional] 
**status** | **String** | Lifecycle state transition. Only `draft → active` (forge) is permitted. Attempting `active → draft` returns 422 `INVALID_STATUS_TRANSITION`.  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


