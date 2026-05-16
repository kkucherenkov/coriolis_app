# app_api_client.api.ChatApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteChatMessage**](ChatApi.md#deletechatmessage) | **DELETE** /api/v1/chat/messages/{id} | Delete (soft) a chat message
[**editChatMessage**](ChatApi.md#editchatmessage) | **PATCH** /api/v1/chat/messages/{id} | Edit a chat message body
[**getChatMessage**](ChatApi.md#getchatmessage) | **GET** /api/v1/chat/messages/{id} | Get a single chat message by ID


# **deleteChatMessage**
> deleteChatMessage(id)

Delete (soft) a chat message

Stamps `deletedAt` on the message. Authors may always delete their own broadcast messages. GMs may delete any broadcast. Whispers may only be deleted by the author — GM has no visibility into whispers and receives 404 rather than 403 (privacy contract). 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getChatApi();
final String id = id_example; // String | Chat message identifier (cuid2)

try {
    api.deleteChatMessage(id);
} on DioException catch (e) {
    print('Exception when calling ChatApi->deleteChatMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Chat message identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **editChatMessage**
> ChatMessage editChatMessage(id, editChatMessageRequest)

Edit a chat message body

Replaces the message body. Only the original author may edit. Returns 422 when the edit window (5 min) has expired. Returns 403 when the caller is not the author. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getChatApi();
final String id = id_example; // String | Chat message identifier (cuid2)
final EditChatMessageRequest editChatMessageRequest = {"body":"Corrected text"}; // EditChatMessageRequest | 

try {
    final response = api.editChatMessage(id, editChatMessageRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->editChatMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Chat message identifier (cuid2) | 
 **editChatMessageRequest** | [**EditChatMessageRequest**](EditChatMessageRequest.md)|  | 

### Return type

[**ChatMessage**](ChatMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getChatMessage**
> ChatMessage getChatMessage(id)

Get a single chat message by ID

Returns the message if the caller has visibility. Broadcast messages are visible to any active session member. Whisper messages are visible only to the author and the target — any other caller, including the GM, receives 404 (privacy contract: non-existence over forbidden). 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getChatApi();
final String id = id_example; // String | Chat message identifier (cuid2)

try {
    final response = api.getChatMessage(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatApi->getChatMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Chat message identifier (cuid2) | 

### Return type

[**ChatMessage**](ChatMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

