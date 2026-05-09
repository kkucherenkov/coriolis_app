# app_api_client.api.SharingApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createShareLink**](SharingApi.md#createsharelink) | **POST** /api/v1/characters/{id}/share | Create a share link for a character
[**listShareLinks**](SharingApi.md#listsharelinks) | **GET** /api/v1/characters/{id}/shares | List share links for a character
[**revokeShareLink**](SharingApi.md#revokesharelink) | **DELETE** /api/v1/share-links/{id} | Revoke a share link


# **createShareLink**
> ShareLink createShareLink(id, shareLinkCreate)

Create a share link for a character

Creates a new share link for the authenticated user's character. The link is identified by a 24-character unguessable slug. Multiple links per character are allowed — useful for different audiences or different `includeGmNotes` settings.  The optional `label` (1–80 characters) helps the owner distinguish links. The optional `expiresAt` is an ISO-8601 instant; omit (or set to null) for a permanent link. The optional `includeGmNotes` flag (default false) controls whether the top-level `notes` field is included in the public character read. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getSharingApi();
final String id = id_example; // String | Character identifier (cuid2)
final ShareLinkCreate shareLinkCreate = {}; // ShareLinkCreate | 

try {
    final response = api.createShareLink(id, shareLinkCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SharingApi->createShareLink: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 
 **shareLinkCreate** | [**ShareLinkCreate**](ShareLinkCreate.md)|  | 

### Return type

[**ShareLink**](ShareLink.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listShareLinks**
> ShareLinkList listShareLinks(id)

List share links for a character

Returns all non-revoked share links for the authenticated user's character, ordered newest-first. Revoked links are excluded by default. A `?includeRevoked` query parameter may be added in a future version. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getSharingApi();
final String id = id_example; // String | Character identifier (cuid2)

try {
    final response = api.listShareLinks(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SharingApi->listShareLinks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 

### Return type

[**ShareLinkList**](ShareLinkList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeShareLink**
> revokeShareLink(id)

Revoke a share link

Soft-revokes a share link by setting its `revokedAt` timestamp. After revocation, `GET /api/v1/public/character/{slug}` returns 410 Gone. The link row is not deleted — historical view counts are preserved. The caller must own the character the link belongs to. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getSharingApi();
final String id = id_example; // String | Share link identifier (cuid2)

try {
    api.revokeShareLink(id);
} on DioException catch (e) {
    print('Exception when calling SharingApi->revokeShareLink: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Share link identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

