# app_api_client.api.EncountersApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createEncounter**](EncountersApi.md#createencounter) | **POST** /api/v1/game-sessions/{sessionId}/encounters | Create an encounter in a game session
[**deleteEncounter**](EncountersApi.md#deleteencounter) | **DELETE** /api/v1/encounters/{id} | Delete an encounter
[**getEncounter**](EncountersApi.md#getencounter) | **GET** /api/v1/encounters/{id} | Get an encounter by ID
[**listEncounters**](EncountersApi.md#listencounters) | **GET** /api/v1/game-sessions/{sessionId}/encounters | List encounters for a game session
[**updateEncounter**](EncountersApi.md#updateencounter) | **PATCH** /api/v1/encounters/{id} | Update an encounter


# **createEncounter**
> Encounter createEncounter(sessionId, encounterCreate)

Create an encounter in a game session

Creates a new encounter owned by the game session. The encounter is seeded with `status: setup`, `round: 0`, and `activeCombatantId: null`. Combatants can be freely added or removed while the encounter is in `setup` status (Block 3 surface). 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getEncountersApi();
final String sessionId = sessionId_example; // String | Game session identifier (cuid2)
final EncounterCreate encounterCreate = {"name":"Ambush in the Bazaar"}; // EncounterCreate | 

try {
    final response = api.createEncounter(sessionId, encounterCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->createEncounter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**| Game session identifier (cuid2) | 
 **encounterCreate** | [**EncounterCreate**](EncounterCreate.md)|  | 

### Return type

[**Encounter**](Encounter.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteEncounter**
> deleteEncounter(id)

Delete an encounter

Permanently deletes an encounter and cascades to all of its combatants (Block 3 schema). The encounter's parent game session must be owned by the authenticated user. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getEncountersApi();
final String id = id_example; // String | Encounter identifier (cuid2)

try {
    api.deleteEncounter(id);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->deleteEncounter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Encounter identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEncounter**
> Encounter getEncounter(id)

Get an encounter by ID

Returns the full encounter DTO. The encounter's parent game session must be owned by the authenticated user — the server checks `encounter.gameSession.ownerId === caller.id`. Returns 404 if the encounter does not exist or 403 if the caller does not own the parent session. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getEncountersApi();
final String id = id_example; // String | Encounter identifier (cuid2)

try {
    final response = api.getEncounter(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->getEncounter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Encounter identifier (cuid2) | 

### Return type

[**Encounter**](Encounter.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEncounters**
> EncounterList listEncounters(sessionId, cursor, limit, status)

List encounters for a game session

Returns a cursor-paginated list of encounters belonging to the game session identified by `sessionId`. Optionally filter by `status`. Only the GM who owns the session may call this endpoint. Results are ordered newest-first by `createdAt`. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getEncountersApi();
final String sessionId = sessionId_example; // String | Game session identifier (cuid2)
final String cursor = cursor_example; // String | Opaque pagination cursor returned by the previous page
final int limit = 56; // int | Number of encounters to return (1–100, default 20)
final EncounterStatus status = ; // EncounterStatus | Filter encounters by status

try {
    final response = api.listEncounters(sessionId, cursor, limit, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->listEncounters: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionId** | **String**| Game session identifier (cuid2) | 
 **cursor** | **String**| Opaque pagination cursor returned by the previous page | [optional] 
 **limit** | **int**| Number of encounters to return (1–100, default 20) | [optional] [default to 20]
 **status** | [**EncounterStatus**](.md)| Filter encounters by status | [optional] 

### Return type

[**EncounterList**](EncounterList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateEncounter**
> Encounter updateEncounter(id, encounterUpdate)

Update an encounter

Applies PATCH semantics to an encounter. All fields are optional.  **Allowed status transitions:** - `setup → active` — starts combat. Bumps `round` to 1, sets   `activeCombatantId` to the first combatant in initiative order.   **Requires at least one combatant** on the encounter; if the   encounter has zero combatants the server returns 422   `ENCOUNTER_NO_COMBATANTS` (combatants are added via the Block 3   surface at `POST /api/v1/encounters/{id}/combatants`). - `active → ended` — closes combat. The encounter becomes   read-only history; `activeCombatantId` is set to null.  **Forbidden transitions** (422 `ENCOUNTER_INVALID_TRANSITION`): - Any transition back to `setup` from `active` or `ended`. - `setup → ended` (must go through `active` first). - Any transition out of `ended`.  Renaming and notes editing are permitted regardless of status. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getEncountersApi();
final String id = id_example; // String | Encounter identifier (cuid2)
final EncounterUpdate encounterUpdate = {"name":"Ambush in the Bazaar — Act II"}; // EncounterUpdate | 

try {
    final response = api.updateEncounter(id, encounterUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->updateEncounter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Encounter identifier (cuid2) | 
 **encounterUpdate** | [**EncounterUpdate**](EncounterUpdate.md)|  | 

### Return type

[**Encounter**](Encounter.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

