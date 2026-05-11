# app_api_client.model.ItemWeaponUpdate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**type** | **String** |  | [optional] 
**name** | **String** |  | [optional] 
**damage** | **int** |  | [optional] 
**range** | [**ItemRangeEnum**](ItemRangeEnum.md) |  | [optional] 
**bonus** | **int** |  | [optional] 
**crit** | **int** |  | [optional] 
**weight** | **num** |  | [optional] 
**features** | **BuiltList&lt;String&gt;** |  | [optional] 
**equipped** | **bool** |  | [optional] 
**initiative** | **int** | Per-weapon initiative modifier (ST3001 ГЛАВА 6 «Инициатива» column). Accepts −5..+5. Omit to leave unchanged.  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


