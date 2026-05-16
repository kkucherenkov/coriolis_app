# app_api_client.model.ChatMessage

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**gameSessionId** | **String** |  | 
**authorMembershipId** | **String** | GameSessionMembership.id; null for system messages | 
**authorDisplayName** | **String** | Denormalised at read time | [optional] 
**targetMembershipId** | **String** | null = broadcast; non-null = whisper | 
**kind** | [**ChatMessageKind**](ChatMessageKind.md) |  | 
**body** | **String** | null for kind=system; non-empty trimmed text for kind=text | [optional] 
**systemKey** | **String** | i18n key for kind=system, e.g. chat.system.member_joined | [optional] 
**systemParams** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**editedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**deletedAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


