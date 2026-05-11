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
**initiative** | **int** | Per-weapon initiative modifier (ST3001 ГЛАВА 6 «Инициатива» column). Canonical printed values 0..+2; accepts −5..+5 for GM flex. Defaults to 0 — most weapons don't carry an initiative bonus.  | [optional] [default to 0]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


