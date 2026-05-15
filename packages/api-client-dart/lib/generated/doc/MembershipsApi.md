# app_api_client.api.MembershipsApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptInvite**](MembershipsApi.md#acceptinvite) | **POST** /api/v1/invites/{token}/accept | Accept an invite link and join the session
[**getInvitePreview**](MembershipsApi.md#getinvitepreview) | **GET** /api/v1/invites/{token}/preview | Public invite preview


# **acceptInvite**
> AcceptInviteResponse acceptInvite(token, acceptInviteBody)

Accept an invite link and join the session

Validates the invite token and creates a membership for the authenticated caller. Idempotent — if the caller is already an active member the existing membership is returned with 200. Returns 410 when the invite has been revoked. An optional `characterId` may be supplied to link a character at join time. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getMembershipsApi();
final String token = token_example; // String | 
final AcceptInviteBody acceptInviteBody = {}; // AcceptInviteBody | 

try {
    final response = api.acceptInvite(token, acceptInviteBody);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MembershipsApi->acceptInvite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 
 **acceptInviteBody** | [**AcceptInviteBody**](AcceptInviteBody.md)|  | [optional] 

### Return type

[**AcceptInviteResponse**](AcceptInviteResponse.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInvitePreview**
> InvitePreview getInvitePreview(token)

Public invite preview

Returns session name + GM display name. Does not require authentication. If the caller is authenticated and already an active member, alreadyJoined is true. Returns 404 if the token is unknown or the invite is revoked. 

### Example
```dart
import 'package:app_api_client/api.dart';

final api = AppApiClient().getMembershipsApi();
final String token = token_example; // String | 

try {
    final response = api.getInvitePreview(token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MembershipsApi->getInvitePreview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

[**InvitePreview**](InvitePreview.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

