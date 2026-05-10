# app_api_client.model.Encounter

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque encounter identifier (cuid2) | 
**gameSessionId** | **String** | Identifier of the parent game session (cuid2) | 
**name** | **String** | Short descriptive name for the encounter (1–80 characters) | 
**status** | [**EncounterStatus**](EncounterStatus.md) |  | 
**round** | **int** | Current combat round. Starts at 0 while in `setup`. Bumped to 1 when the encounter transitions to `active`. Increments by 1 each time the turn order wraps back to the first combatant (Block 4 turn-advance operation).  | [default to 0]
**activeCombatantId** | **String** | Identifier of the combatant whose turn it currently is. Null when `status` is `setup` (initiative not yet rolled) or `ended` (combat closed). Set by the server on the `setup → active` transition and updated by the turn-advance operation (Block 4).  | 
**notes** | **String** | Optional GM notes for the encounter in Markdown format (max 4096 characters). May be edited at any status.  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


