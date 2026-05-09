# app_api_client.api.UsersApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteMe**](UsersApi.md#deleteme) | **DELETE** /api/v1/me | Soft-delete the authenticated user&#39;s account.
[**getMe**](UsersApi.md#getme) | **GET** /api/v1/me | Get the authenticated user&#39;s profile.
[**updateMe**](UsersApi.md#updateme) | **PATCH** /api/v1/me | Update the authenticated user&#39;s mutable profile fields.


# **deleteMe**
> deleteMe()

Soft-delete the authenticated user's account.

Initiates a soft-delete of the authenticated user's account per PRD §4.2.  **Semantics:** - All active Better Auth sessions for this account are revoked   immediately — the current request is the last one they will authorise. - The user record's `deletedAt` timestamp is set to the current UTC time. - Characters, ships, and share links owned by the user remain readable   (via existing share slugs) until a daily cron job hard-deletes them   30 days after `deletedAt`.  **Idempotency:** calling DELETE on an account whose `deletedAt` is already set (i.e. an already soft-deleted account) returns `204` without error. This prevents clients from treating a retry as a failure.  **No 404:** because the caller must be authenticated to reach this endpoint, and sessions are revoked on deletion, there is no scenario where a live session is attached to a non-existent account. A 404 path does not exist for this operation. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getUsersApi();

try {
    api.deleteMe();
} on DioException catch (e) {
    print('Exception when calling UsersApi->deleteMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMe**
> Me getMe()

Get the authenticated user's profile.

Returns the current user's profile fields sourced from the Better Auth `user` table. `email` and `createdAt` are read-only in this DTO — they are managed by Better Auth and cannot be changed via this endpoint.  See PRD §4.1 for full product context. Soft-deleted users receive a `404` because their sessions are revoked on deletion; this endpoint will therefore never return a user whose `deletedAt` is set (that field is an internal flag and is not exposed in this DTO). 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getUsersApi();

try {
    final response = api.getMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Me**](Me.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateMe**
> Me updateMe(meUpdate)

Update the authenticated user's mutable profile fields.

Applies a partial update (PATCH semantics) to the authenticated user's profile. `displayName` and `theme` are mutable via this endpoint.  `email` and `createdAt` are managed by Better Auth and are silently ignored if included in the request body — attempting to send them is treated as a `400` so the contract is unambiguous.  `displayName` constraints: - Must be between 1 and 80 characters when non-null (80 matches the   character-name guidance in PRD §5.2). - May be set to `null` to clear the field. - An empty string (`\"\"`) is rejected with `400`.  `theme` constraints: - Must be one of `dark` or `high-contrast` when provided. - Omitting the field preserves the current value. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getUsersApi();
final MeUpdate meUpdate = {"displayName":"Kalim al-Rashid"}; // MeUpdate | 

try {
    final response = api.updateMe(meUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->updateMe: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meUpdate** | [**MeUpdate**](MeUpdate.md)|  | 

### Return type

[**Me**](Me.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

