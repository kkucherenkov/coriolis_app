# app_api_client.model.ItemCreate

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
**weight** | **num** | Encumbrance weight in slots | 
**features** | **BuiltList&lt;String&gt;** | Feature tags (e.g. \"Vacuum Sealed\", \"Exo-Skeleton\") | 
**equipped** | **bool** |  | [default to false]
**armorRating** | **int** | Armor rating — reduces incoming damage | 
**quantity** | **int** | Number of units | 
**notes** | **String** | Optional free-text notes | [optional] 
**xpCost** | **int** | XP spent to acquire this implant (canonical cost 5 XP per ГЛАВА 4; accepts 0..15 for GM concessions and high-rank exotics). Birr price is carried in the item's `cost` field.  | 
**effect** | **String** | Description of the module's effect and energy use | 
**slot** | [**ShipModuleSlot**](ShipModuleSlot.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


