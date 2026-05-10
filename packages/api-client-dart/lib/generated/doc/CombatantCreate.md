# app_api_client.model.CombatantCreate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**combatantType** | [**CombatantType**](CombatantType.md) |  | 
**sourceId** | **String** | Identifier of the source entity. Must be a `Character.id` when `combatantType` is `pc`, or an `Npc.id` when `combatantType` is `npc`.  | 
**displayName** | **String** | Optional override for the combatant display name. When omitted the server copies the source entity's `name`.  | [optional] 
**notes** | **String** | Optional GM notes in Markdown (max 500 characters). | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


