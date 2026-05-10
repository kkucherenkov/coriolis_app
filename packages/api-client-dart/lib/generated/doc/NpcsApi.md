# app_api_client.api.NpcsApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createNpc**](NpcsApi.md#createnpc) | **POST** /api/v1/npcs | Create a new NPC
[**deleteNpc**](NpcsApi.md#deletenpc) | **DELETE** /api/v1/npcs/{id} | Delete an NPC
[**duplicateNpc**](NpcsApi.md#duplicatenpc) | **POST** /api/v1/npcs/{id}/duplicate | Duplicate an NPC
[**getNpc**](NpcsApi.md#getnpc) | **GET** /api/v1/npcs/{id} | Get an NPC by ID
[**listNpcs**](NpcsApi.md#listnpcs) | **GET** /api/v1/npcs | List the authenticated user&#39;s NPCs
[**updateNpc**](NpcsApi.md#updatenpc) | **PATCH** /api/v1/npcs/{id} | Partially update an NPC


# **createNpc**
> Npc createNpc(npcCreate)

Create a new NPC

Creates an NPC owned by the authenticated user. Only `name` is required; all other fields default to playable stubs so a quick encounter-filler can be created with a single call. Server assigns `id`, `ownerId`, `createdAt`, `updatedAt`.  Default seeds applied by the server when fields are omitted: - `attributes` — all four attributes set to 2 - `skills` — all 16 skills set to 0 - `hp` — `{ current: 4, max: 4 }` - `mp` — `{ current: 4, max: 4 }` - `armor` — empty array - `weapons` — empty array - `tags` — empty array - `signature` — 0 - `keySkillModifier` — 0 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getNpcsApi();
final NpcCreate npcCreate = {"name":"Pirate Scout"}; // NpcCreate | 

try {
    final response = api.createNpc(npcCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NpcsApi->createNpc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **npcCreate** | [**NpcCreate**](NpcCreate.md)|  | 

### Return type

[**Npc**](Npc.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteNpc**
> deleteNpc(id)

Delete an NPC

Permanently deletes an NPC. This action is irreversible. NPCs referenced by active encounters are rejected with 409 `NPC_IN_USE` — remove the combatant from the encounter first. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getNpcsApi();
final String id = id_example; // String | NPC identifier (cuid2)

try {
    api.deleteNpc(id);
} on DioException catch (e) {
    print('Exception when calling NpcsApi->deleteNpc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| NPC identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **duplicateNpc**
> Npc duplicateNpc(id)

Duplicate an NPC

Creates a deep copy of the NPC (attributes, skills, hp, mp, armor, weapons, tags) and assigns it to the authenticated user. The copy receives a new `id` and a name suffix: \"(copy)\" for the first duplicate, \"(copy 2)\" for the second, and so on. The source NPC must be owned by the caller. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getNpcsApi();
final String id = id_example; // String | NPC identifier (cuid2)

try {
    final response = api.duplicateNpc(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NpcsApi->duplicateNpc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| NPC identifier (cuid2) | 

### Return type

[**Npc**](Npc.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNpc**
> Npc getNpc(id)

Get an NPC by ID

Returns the full Npc DTO. Returns 404 if the NPC does not exist and 403 if it is owned by a different user. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getNpcsApi();
final String id = id_example; // String | NPC identifier (cuid2)

try {
    final response = api.getNpc(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NpcsApi->getNpc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| NPC identifier (cuid2) | 

### Return type

[**Npc**](Npc.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listNpcs**
> NpcList listNpcs(cursor, limit, tag)

List the authenticated user's NPCs

Returns a cursor-paginated list of NPCs owned by the authenticated user. Pass `cursor` from a previous response's `nextCursor` to retrieve the following page. Results are ordered newest-first by `createdAt`. Optionally filter by `tag` (exact match against any element of the NPC's `tags` array). 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getNpcsApi();
final String cursor = cursor_example; // String | Opaque pagination cursor returned by the previous page
final int limit = 56; // int | Number of NPCs to return (1–100, default 20)
final String tag = tag_example; // String | Filter NPCs that have this tag (exact match, case-sensitive)

try {
    final response = api.listNpcs(cursor, limit, tag);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NpcsApi->listNpcs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| Opaque pagination cursor returned by the previous page | [optional] 
 **limit** | **int**| Number of NPCs to return (1–100, default 20) | [optional] [default to 20]
 **tag** | **String**| Filter NPCs that have this tag (exact match, case-sensitive) | [optional] 

### Return type

[**NpcList**](NpcList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateNpc**
> Npc updateNpc(id, npcUpdate)

Partially update an NPC

Applies PATCH semantics — omitted fields are left unchanged. Read-only fields (`id`, `ownerId`, `createdAt`, `updatedAt`) are rejected with 400 if included. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getNpcsApi();
final String id = id_example; // String | NPC identifier (cuid2)
final NpcUpdate npcUpdate = {"name":"Elite Zarqali Guard"}; // NpcUpdate | 

try {
    final response = api.updateNpc(id, npcUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NpcsApi->updateNpc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| NPC identifier (cuid2) | 
 **npcUpdate** | [**NpcUpdate**](NpcUpdate.md)|  | 

### Return type

[**Npc**](Npc.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

