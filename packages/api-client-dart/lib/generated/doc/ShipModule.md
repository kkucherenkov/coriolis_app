# app_api_client.model.ShipModule

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque module identifier (cuid2) | 
**slot** | [**ShipModuleSlot**](ShipModuleSlot.md) |  | 
**name** | **String** | Module name (e.g. \"Graviton Projector\", \"Smuggler hold\") | 
**energyUse** | **int** | Energy points consumed by this module when active | 
**notes** | **String** | Free-text notes; used for damage state, special conditions, etc. | [optional] 
**weaponBonus** | **int** | Modifier dice added to the attack pool (Мод. column in Table 7.9) | 
**weaponRange** | [**ShipWeaponRange**](ShipWeaponRange.md) |  | 
**weaponDamage** | **int** | Structural damage dealt on a hit | 
**weaponCritThreshold** | **int** | Number of successes required to trigger a critical effect | 
**torpedoCount** | **int** | Number of torpedoes currently loaded | [optional] 
**mineCount** | **int** | Number of mines currently loaded | [optional] 
**cargoTons** | **int** | Cargo capacity in tonnes (class-dependent per Table 7.6) | [optional] 
**concealed** | **bool** | True for a потайной грузовой отсек (concealed hold) | [optional] [default to false]
**detectionBonus** | **int** | Modifier added to sensor / dataDjinn checks | [optional] [default to 1]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


