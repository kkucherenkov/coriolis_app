# app_api_client.model.ItemWeaponCreate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**type** | **String** |  | 
**name** | **String** |  | 
**damage** | **int** | Base damage dice | 
**range** | [**ItemRangeEnum**](ItemRangeEnum.md) |  | 
**bonus** | **int** | Bonus dice added to the attack pool | 
**crit** | **int** | Critical threshold | 
**weight** | **num** | Encumbrance weight in slots (0.5 increments) | 
**features** | **BuiltList&lt;String&gt;** | Feature tags (e.g. \"Burst\", \"Explosive\") | 
**equipped** | **bool** |  | [default to false]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


