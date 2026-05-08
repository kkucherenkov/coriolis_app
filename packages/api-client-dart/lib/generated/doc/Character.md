# app_api_client.model.Character

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque character identifier (cuid2) | 
**ownerId** | **String** | Identifier of the owning user (cuid2) | 
**name** | **String** | Character name (1–80 characters) | 
**concept** | **String** | Short concept phrase — the role the character plays at the table (1–120 chars when non-null) | 
**iconId** | [**IconId**](IconId.md) |  | 
**attributes** | [**Attributes**](Attributes.md) |  | 
**skills** | [**Skills**](Skills.md) |  | 
**hp** | [**CharacterHp**](CharacterHp.md) |  | 
**mp** | [**CharacterMp**](CharacterMp.md) |  | 
**encumbrance** | [**CharacterEncumbrance**](CharacterEncumbrance.md) |  | 
**experience** | **int** | Total XP earned | 
**conditions** | [**ConditionFlags**](ConditionFlags.md) |  | 
**criticalInjuries** | [**BuiltList&lt;CriticalInjury&gt;**](CriticalInjury.md) |  | 
**talents** | [**BuiltList&lt;Talent&gt;**](Talent.md) |  | 
**relationships** | [**BuiltList&lt;Relationship&gt;**](Relationship.md) |  | 
**inventory** | [**BuiltList&lt;Item&gt;**](Item.md) |  | 
**notes** | **String** | Free-form notes (Markdown; soft cap 4096 characters) | 
**status** | **String** | Lifecycle state of the character.  - `draft` — character is a work-in-progress created by the wizard.   Draft characters are excluded from the default character list   (`GET /api/v1/characters`) unless `?includeDrafts=true` is passed. - `active` — character is complete and visible on the dashboard.  Transitioning from `draft` to `active` (forging) is done by sending `PATCH /api/v1/characters/{id}` with `{ \"status\": \"active\" }`. The reverse transition (`active → draft`) is rejected with 422 `INVALID_STATUS_TRANSITION`.  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


