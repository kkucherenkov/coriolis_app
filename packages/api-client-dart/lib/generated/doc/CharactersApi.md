# app_api_client.api.CharactersApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addCharacterItem**](CharactersApi.md#addcharacteritem) | **POST** /api/v1/characters/{id}/items | Add an item to a character&#39;s inventory
[**addCharacterTalent**](CharactersApi.md#addcharactertalent) | **POST** /api/v1/characters/{id}/talents | Add a talent to a character
[**createCharacter**](CharactersApi.md#createcharacter) | **POST** /api/v1/characters | Create a new character
[**deleteCharacter**](CharactersApi.md#deletecharacter) | **DELETE** /api/v1/characters/{id} | Delete a character
[**deleteItem**](CharactersApi.md#deleteitem) | **DELETE** /api/v1/items/{id} | Delete an item
[**deleteTalent**](CharactersApi.md#deletetalent) | **DELETE** /api/v1/talents/{id} | Delete a talent
[**duplicateCharacter**](CharactersApi.md#duplicatecharacter) | **POST** /api/v1/characters/{id}/duplicate | Duplicate a character
[**exportCharacter**](CharactersApi.md#exportcharacter) | **GET** /api/v1/characters/{id}/export | Export a character as JSON
[**getCharacter**](CharactersApi.md#getcharacter) | **GET** /api/v1/characters/{id} | Get a character by ID
[**listCharacters**](CharactersApi.md#listcharacters) | **GET** /api/v1/characters | List the authenticated user&#39;s characters
[**updateCharacter**](CharactersApi.md#updatecharacter) | **PATCH** /api/v1/characters/{id} | Partially update a character
[**updateItem**](CharactersApi.md#updateitem) | **PATCH** /api/v1/items/{id} | Update an item
[**updateTalent**](CharactersApi.md#updatetalent) | **PATCH** /api/v1/talents/{id} | Update a talent


# **addCharacterItem**
> Item addCharacterItem(id, itemCreate)

Add an item to a character's inventory

Creates an item of the specified `type` under the character. The discriminator field `type` determines which additional fields are accepted and required. `id` is assigned by the server. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Character identifier (cuid2)
final ItemCreate itemCreate = {"type":"WEAPON","name":"Vulcan Carbine","damage":2,"range":"short","bonus":2,"crit":2,"weight":0.8,"features":[],"equipped":true}; // ItemCreate | 

try {
    final response = api.addCharacterItem(id, itemCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->addCharacterItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 
 **itemCreate** | [**ItemCreate**](ItemCreate.md)|  | 

### Return type

[**Item**](Item.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addCharacterTalent**
> Talent addCharacterTalent(id, talentCreate)

Add a talent to a character

Creates a talent record attached to the character. Talents are free-form (name + description + rank); there is no server-side talent library in v1.  `kind` defaults to `personal`. Each character can have at most one talent of each non-`personal` kind (`crew`, `iconGift`, `stigma`); a duplicate non-personal kind is rejected with 400 `TALENT_KIND_DUPLICATE`. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Character identifier (cuid2)
final TalentCreate talentCreate = {"kind":"personal","name":"Wing-Mate","description":"Re-roll one die when assisting a fellow pilot.","rank":2}; // TalentCreate | 

try {
    final response = api.addCharacterTalent(id, talentCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->addCharacterTalent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 
 **talentCreate** | [**TalentCreate**](TalentCreate.md)|  | 

### Return type

[**Talent**](Talent.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCharacter**
> Character createCharacter(characterCreate)

Create a new character

Creates a character owned by the authenticated user. `name` is the only required field; all other fields default to empty arrays, null, or 0. Server-derived fields (`hp.max`, `mp.max`, `encumbrance.max`) are populated from the provided attribute values or defaults.  Attribute defaults are 2 per attribute when not provided. Skills default to 0. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final CharacterCreate characterCreate = {"name":"Rana Sadir","upbringing":"plebeian"}; // CharacterCreate | 

try {
    final response = api.createCharacter(characterCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->createCharacter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **characterCreate** | [**CharacterCreate**](CharacterCreate.md)|  | 

### Return type

[**Character**](Character.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteCharacter**
> deleteCharacter(id)

Delete a character

Permanently deletes a character and all its nested items, talents, relationships, and share links. This action is irreversible. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Character identifier (cuid2)

try {
    api.deleteCharacter(id);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->deleteCharacter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteItem**
> deleteItem(id)

Delete an item

Permanently deletes an item from a character's inventory. Authorization: caller must own the parent character. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Item identifier (cuid2)

try {
    api.deleteItem(id);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->deleteItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Item identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteTalent**
> deleteTalent(id)

Delete a talent

Permanently removes a talent from a character. Authorization: caller must own the parent character. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Talent identifier (cuid2)

try {
    api.deleteTalent(id);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->deleteTalent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Talent identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **duplicateCharacter**
> Character duplicateCharacter(id)

Duplicate a character

Creates a deep copy of the character (including items, talents, relationships, and conditions) and assigns it to the authenticated user. The copy receives a new `id` and the name has \" (copy)\" appended. Share links are not duplicated. The source character must be owned by the caller. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Character identifier (cuid2)

try {
    final response = api.duplicateCharacter(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->duplicateCharacter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 

### Return type

[**Character**](Character.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **exportCharacter**
> Character exportCharacter(id)

Export a character as JSON

Returns the full canonical Character DTO as a downloadable JSON payload. v1 ships JSON only; PDF and encounter-bundle exports are post-v1. The response carries `Content-Disposition: attachment` so browsers prompt a download. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Character identifier (cuid2)

try {
    final response = api.exportCharacter(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->exportCharacter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 

### Return type

[**Character**](Character.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCharacter**
> Character getCharacter(id)

Get a character by ID

Returns the full character DTO. Returns 404 if the character does not exist or is not owned by the authenticated user. Owner-scoped: a character owned by another user returns 403 (not 404) when the caller is authenticated, to aid debugging while preserving access boundaries. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Character identifier (cuid2)

try {
    final response = api.getCharacter(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->getCharacter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 

### Return type

[**Character**](Character.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCharacters**
> CharacterList listCharacters(cursor, limit, includeDrafts)

List the authenticated user's characters

Returns a cursor-paginated list of characters owned by the authenticated user. Pass `cursor` from a previous response's `nextCursor` to retrieve the following page. Results are ordered newest-first by `createdAt`. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String cursor = cursor_example; // String | Opaque pagination cursor returned by the previous page
final int limit = 56; // int | Number of characters to return (1–100, default 20)
final bool includeDrafts = true; // bool | When `false` (default), only `active` characters are returned — draft wizard-in-progress characters are hidden from the dashboard. When `true`, both `active` and `draft` characters are returned so the wizard UI can display in-progress records. 

try {
    final response = api.listCharacters(cursor, limit, includeDrafts);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->listCharacters: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| Opaque pagination cursor returned by the previous page | [optional] 
 **limit** | **int**| Number of characters to return (1–100, default 20) | [optional] [default to 20]
 **includeDrafts** | **bool**| When `false` (default), only `active` characters are returned — draft wizard-in-progress characters are hidden from the dashboard. When `true`, both `active` and `draft` characters are returned so the wizard UI can display in-progress records.  | [optional] [default to false]

### Return type

[**CharacterList**](CharacterList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateCharacter**
> Character updateCharacter(id, characterUpdate)

Partially update a character

Applies PATCH semantics — omitted fields are left unchanged. Read-only fields (`id`, `ownerId`, `hp.max`, `mp.max`, `encumbrance.max`, `createdAt`, `updatedAt`) are rejected with 400 if included.  Server-derived fields (`hp.max`, `mp.max`, `encumbrance.max`) are recalculated after each write and reflected in the response. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Character identifier (cuid2)
final CharacterUpdate characterUpdate = {"name":"Tariq al-Asari (Pilot)"}; // CharacterUpdate | 

try {
    final response = api.updateCharacter(id, characterUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->updateCharacter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 
 **characterUpdate** | [**CharacterUpdate**](CharacterUpdate.md)|  | 

### Return type

[**Character**](Character.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateItem**
> Item updateItem(id, itemUpdate)

Update an item

Applies PATCH semantics to an item. The `type` discriminator may not be changed after creation — attempting to do so returns 400 with code `ITEM_TYPE_MISMATCH`. Authorization: caller must own the parent character. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Item identifier (cuid2)
final ItemUpdate itemUpdate = {"type":"WEAPON","name":"Vulcan Carbine MkII","bonus":3,"equipped":true}; // ItemUpdate | 

try {
    final response = api.updateItem(id, itemUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->updateItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Item identifier (cuid2) | 
 **itemUpdate** | [**ItemUpdate**](ItemUpdate.md)|  | 

### Return type

[**Item**](Item.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTalent**
> Talent updateTalent(id, talentUpdate)

Update a talent

Applies PATCH semantics to a talent. Authorization: caller must own the parent character. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getCharactersApi();
final String id = id_example; // String | Talent identifier (cuid2)
final TalentUpdate talentUpdate = {"rank":3}; // TalentUpdate | 

try {
    final response = api.updateTalent(id, talentUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CharactersApi->updateTalent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Talent identifier (cuid2) | 
 **talentUpdate** | [**TalentUpdate**](TalentUpdate.md)|  | 

### Return type

[**Talent**](Talent.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

