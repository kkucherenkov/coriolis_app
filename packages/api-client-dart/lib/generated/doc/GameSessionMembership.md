# app_api_client.model.GameSessionMembership

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Stable cuid; used as targetMembershipId in chat whispers. | 
**gameSessionId** | **String** |  | 
**userId** | **String** |  | 
**role** | [**GameSessionMemberRole**](GameSessionMemberRole.md) |  | 
**displayName** | **String** | Cached display name of the user (denormalised for UI). | [optional] 
**characterId** | **String** |  | [optional] 
**characterName** | **String** |  | [optional] 
**joinedAt** | [**DateTime**](DateTime.md) |  | 
**leftAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


