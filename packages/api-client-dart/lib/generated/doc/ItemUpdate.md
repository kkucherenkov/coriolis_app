# app_api_client.model.ItemUpdate

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
**armorRating** | **int** |  | [optional] 
**extraSlotCount** | **int** | Extra encumbrance slots this armor grants its wearer when equipped (ST3001 ТАБЛИЦА 6.14 «Дополнительные свойства» column). Omit to leave unchanged.  | [optional] 
**quantity** | **int** |  | [optional] 
**notes** | **String** |  | [optional] 
**xpCost** | **int** |  | [optional] 
**effect** | **String** |  | [optional] 
**slot** | [**ShipModuleSlot**](ShipModuleSlot.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


