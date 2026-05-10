# app_api_client.model.TurnAdvanceResult

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**activeCombatantId** | **String** | Id of the combatant whose turn is now active (the new `encounter.activeCombatantId` after the advance).  | 
**round** | **int** | Current combat round after the advance. Incremented by 1 when the turn wraps from the last combatant back to index 0.  | 
**isNewRound** | **bool** | `true` when the advance wrapped past the last combatant and started a new round; `false` when the next combatant is within the same round.  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


