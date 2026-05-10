# app_api_client.model.InitiativeRollResult

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**combatants** | [**BuiltList&lt;Combatant&gt;**](Combatant.md) | Full updated combatant list sorted by `turnOrder` ascending (0 = acts first). Every combatant carries a non-null `initiative` and `turnOrder` after this operation.  | 
**round** | **int** | Current combat round after the operation. For `rollInitiative` this is always 1 (the `setup → active` transition sets `round` from 0 to 1). For `reorderInitiative` this reflects the encounter's current round (unchanged by a reorder).  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


