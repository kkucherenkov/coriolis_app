# app_api_client.api.PublicApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCharacterOgImage**](PublicApi.md#getcharacterogimage) | **GET** /api/v1/public/og/character/{slug}.png | OG image for a shared character (Feature 6.3 — not yet implemented)
[**getPublicCharacter**](PublicApi.md#getpubliccharacter) | **GET** /api/v1/public/character/{slug} | Get a publicly-shared character by slug


# **getCharacterOgImage**
> Uint8List getCharacterOgImage(slug)

OG image for a shared character (Feature 6.3 — not yet implemented)

Returns a PNG Open Graph image for the shared character. Intended for social-media preview unfurling.  **This endpoint is not yet implemented.** It will always return 501 until Feature 6.3 lands the server-side renderer. Consumers should plan for the following cache headers on the eventual 200 response: `Cache-Control: public, max-age=3600, stale-while-revalidate=86400`. 

### Example
```dart
import 'package:app_api_client/api.dart';

final api = AppApiClient().getPublicApi();
final String slug = slug_example; // String | 24-character unambiguous nanoid slug identifying a share link

try {
    final response = api.getCharacterOgImage(slug);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getCharacterOgImage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**| 24-character unambiguous nanoid slug identifying a share link | 

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/png, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicCharacter**
> Character getPublicCharacter(slug)

Get a publicly-shared character by slug

Returns the character associated with the given share-link slug. No authentication is required.  The `notes` field (top-level GM notes) is included only when the share link was created with `includeGmNotes: true`. If the link does not include GM notes, `notes` is always returned as `null` regardless of whether the character actually has notes.  Error semantics: - `404` — slug does not exist or was never created. - `410` — slug existed but has been revoked or has expired. 

### Example
```dart
import 'package:app_api_client/api.dart';

final api = AppApiClient().getPublicApi();
final String slug = slug_example; // String | 24-character unambiguous nanoid slug identifying a share link

try {
    final response = api.getPublicCharacter(slug);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getPublicCharacter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**| 24-character unambiguous nanoid slug identifying a share link | 

### Return type

[**Character**](Character.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

