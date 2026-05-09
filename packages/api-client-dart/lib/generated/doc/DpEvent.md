# app_api_client.model.DpEvent

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque event identifier (cuid2) | 
**gameSessionId** | **String** | Session the event belongs to | 
**delta** | **int** | How many DP were added (positive) or removed (negative) | 
**reason** | **String** | Optional human-readable reason | [optional] 
**source_** | [**DpSource**](DpSource.md) |  | 
**rollId** | **String** | Roll identifier when source is roll-push | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


