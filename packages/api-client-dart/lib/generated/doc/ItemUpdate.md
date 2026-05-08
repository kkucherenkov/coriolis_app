# app_api_client.model.ItemUpdate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | [optional] 
**damage** | **int** | WEAPON only | [optional] 
**range** | [**ItemRangeEnum**](ItemRangeEnum.md) | WEAPON only | [optional] 
**bonus** | **int** | WEAPON only | [optional] 
**crit** | **int** | WEAPON only | [optional] 
**armorRating** | **int** | ARMOR only | [optional] 
**weight** | **num** |  | [optional] 
**features** | **BuiltList&lt;String&gt;** | WEAPON or ARMOR | [optional] 
**equipped** | **bool** | WEAPON or ARMOR | [optional] 
**quantity** | **int** | GEAR only | [optional] 
**notes** | **String** | GEAR or OTHER | [optional] 
**bodyPoints** | **int** | CYBERNETIC only | [optional] 
**effect** | **String** | CYBERNETIC or SHIP_MODULE | [optional] 
**slot** | [**ItemSlotType**](ItemSlotType.md) | SHIP_MODULE only | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


