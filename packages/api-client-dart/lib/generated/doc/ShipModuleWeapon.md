# app_api_client.model.ShipModuleWeapon

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque module identifier (cuid2) | 
**slot** | **String** |  | 
**name** | **String** | Module name (e.g. \"Graviton Projector\", \"Smuggler hold\") | 
**energyUse** | **int** | Energy points consumed by this module when active | 
**notes** | **String** | Free-text notes; used for damage state, special conditions, etc. | [optional] 
**weaponBonus** | **int** | Modifier dice added to the attack pool (Мод. column in Table 7.9) | 
**weaponRange** | [**ShipWeaponRange**](ShipWeaponRange.md) |  | 
**weaponDamage** | **int** | Structural damage dealt on a hit | 
**weaponCritThreshold** | **int** | Number of successes required to trigger a critical effect | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


