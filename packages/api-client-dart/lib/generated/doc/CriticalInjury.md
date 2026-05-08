# app_api_client.model.CriticalInjury

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque identifier (cuid2) | 
**name** | **String** | Short name of the injury (e.g. \"Broken arm\") | 
**severity** | [**CriticalInjurySeverity**](CriticalInjurySeverity.md) |  | 
**effect** | **String** | Free-text description of the mechanical or narrative effect | 
**acquiredAt** | [**DateTime**](DateTime.md) | ISO-8601 instant when the injury was recorded | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


