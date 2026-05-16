# app_api_client.model.PostChatMessageRequest

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**kind** | **String** | Client-submitted messages must be of kind=text; system messages are server-generated only. | 
**body** | **String** |  | 
**targetMembershipId** | **String** | null or omitted = broadcast; non-null = whisper to this membership | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


