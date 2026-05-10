# app_api_client.model.CombatantUpdate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**displayName** | **String** | Update the combatant display name. | [optional] 
**hpCurrent** | **int** | Update current hit points (may go negative). | [optional] 
**armor** | **int** | Update armor rating. | [optional] 
**signature** | **int** | Update the mystic signature value. | [optional] 
**statusFlags** | **BuiltList&lt;String&gt;** | Replace the full set of status flags. Well-known values: `broken`, `exposed`, `covered`, `prone`.  | [optional] 
**notes** | **String** | Update GM notes in Markdown (max 500 characters). | [optional] 
**initiative** | **int** | Read-only. Initiative is set exclusively by the Block 4 initiative-roll operation (d6 per ST3001 ГЛАВА 5). This field is listed here for documentation purposes only; any value supplied in a PATCH request will be ignored.  | [optional] 
**turnOrder** | **int** | Read-only. Turn order index is set exclusively by the Block 4 initiative operations. This field is listed here for documentation purposes only; any value supplied in a PATCH request will be ignored.  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


