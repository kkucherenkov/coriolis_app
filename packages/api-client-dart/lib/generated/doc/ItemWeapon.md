# app_api_client.model.ItemWeapon

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque identifier (cuid2) | 
**type** | **String** |  | 
**name** | **String** | Item name | 
**damage** | **int** | Base damage dice | 
**range** | [**ItemRangeEnum**](ItemRangeEnum.md) |  | 
**bonus** | **int** | Bonus dice added to the attack pool | 
**crit** | **int** | Critical threshold (roll this many successes to crit) | 
**weight** | **num** | Encumbrance weight in slots (0.5 increments) | 
**features** | **BuiltList&lt;String&gt;** | Feature tags (e.g. \"Burst\", \"Explosive\") | 
**equipped** | **bool** | Whether the item is currently equipped | 
**initiative** | **int** | Per-weapon initiative modifier added to the d6 initiative roll when the wielder uses this weapon (ST3001 ГЛАВА 6 «Инициатива» column on each weapon table; ГЛАВА 5 §«Раунды, ходы и инициатива» — «Некоторые виды оружия могут временно повысить значение твоей инициативы. Воспользовавшись этим преимуществом, ты обязан атаковать оружием, которое его обеспечивает»). Canonical printed values in ГЛАВА 6 are 0..+2; the broader −5..+5 envelope leaves room for GM-defined exotics and house-rule penalties without needing a spec bump. Defaults to 0 — most weapons don't carry an initiative bonus.  | [optional] [default to 0]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


