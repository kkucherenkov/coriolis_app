# app_api_client.model.ShipModuleHold

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
**cargoTons** | **int** | Cargo capacity in tonnes (class-dependent per Table 7.6) | [optional] 
**concealed** | **bool** | True for a потайной грузовой отсек (concealed hold) | [optional] [default to false]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


