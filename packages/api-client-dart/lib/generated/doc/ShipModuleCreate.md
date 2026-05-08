# app_api_client.model.ShipModuleCreate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**slot** | [**ShipModuleSlot**](ShipModuleSlot.md) |  | 
**name** | **String** |  | 
**energyUse** | **int** |  | 
**weaponBonus** | **int** | Modifier dice added to the attack pool | 
**weaponRange** | [**ShipWeaponRange**](ShipWeaponRange.md) |  | 
**weaponDamage** | **int** | Structural damage dealt on a hit | 
**weaponCritThreshold** | **int** | Number of successes required to trigger a critical effect | 
**notes** | **String** |  | [optional] 
**torpedoCount** | **int** | Number of torpedoes currently loaded | [optional] [default to 0]
**mineCount** | **int** | Number of mines currently loaded | [optional] [default to 0]
**cargoTons** | **int** | Cargo capacity in tonnes | [optional] [default to 0]
**concealed** | **bool** | True for a concealed hold | [optional] [default to false]
**detectionBonus** | **int** | Modifier added to sensor / dataDjinn checks | [optional] [default to 1]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


