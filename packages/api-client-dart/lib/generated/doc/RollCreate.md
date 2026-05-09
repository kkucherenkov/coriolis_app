# app_api_client.model.RollCreate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**label** | **String** | Human-readable roll label, e.g. \"Pilot · Evade\" | 
**pool** | **int** | Number of d6 to roll. Must be between 1 and 10 inclusive. Condition pool penalties must be pre-applied by the caller before submitting.  | 
**gameSessionId** | **String** | Optional game session identifier. Reserved for Feature 7.2. Pass null or omit until GameSession lands.  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


