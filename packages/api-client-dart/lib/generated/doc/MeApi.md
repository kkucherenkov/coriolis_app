# app_api_client.api.MeApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMyMemberships**](MeApi.md#getmymemberships) | **GET** /api/v1/me/memberships | List the caller&#39;s active session memberships


# **getMyMemberships**
> GetMyMemberships200Response getMyMemberships()

List the caller's active session memberships

Returns all active (non-left) session memberships for the authenticated user across all game sessions. Leaver rows (non-null `leftAt`) are excluded. Includes the linked character name and ID for each membership when set. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getMeApi();

try {
    final response = api.getMyMemberships();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeApi->getMyMemberships: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetMyMemberships200Response**](GetMyMemberships200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

