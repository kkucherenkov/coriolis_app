# app_api_client.api.EncountersApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addCombatant**](EncountersApi.md#addcombatant) | **POST** /api/v1/encounters/{id}/combatants | Add a combatant to an encounter
[**createEncounter**](EncountersApi.md#createencounter) | **POST** /api/v1/game-sessions/{sessionId}/encounters | Create an encounter in a game session
[**deleteCombatant**](EncountersApi.md#deletecombatant) | **DELETE** /api/v1/combatants/{id} | Remove a combatant from an encounter
[**deleteEncounter**](EncountersApi.md#deleteencounter) | **DELETE** /api/v1/encounters/{id} | Delete an encounter
[**getEncounter**](EncountersApi.md#getencounter) | **GET** /api/v1/encounters/{id} | Get an encounter by ID
[**listCombatants**](EncountersApi.md#listcombatants) | **GET** /api/v1/encounters/{id}/combatants | List combatants for an encounter
[**listEncounters**](EncountersApi.md#listencounters) | **GET** /api/v1/game-sessions/{sessionId}/encounters | List encounters for a game session
[**updateCombatant**](EncountersApi.md#updatecombatant) | **PATCH** /api/v1/combatants/{id} | Update a combatant
[**updateEncounter**](EncountersApi.md#updateencounter) | **PATCH** /api/v1/encounters/{id} | Update an encounter


# **addCombatant**
> Combatant addCombatant(id, combatantCreate)

Add a combatant to an encounter

Adds a PC or NPC as a combatant to the encounter. The server snapshots `hpCurrent`, `hpMax`, `armor`, and `signature` from the source entity at the moment of this call. Subsequent changes to the source's stats (e.g. the player saving their character sheet mid-combat) do NOT propagate to the combatant record — the GM mutates `hpCurrent` directly on the combatant via `PATCH /api/v1/combatants/{id}`.  Only allowed while the encounter is in `setup` status. `initiative` and `turnOrder` remain null until the initiative roll operation in Block 4.  Error codes: - `COMBATANT_SOURCE_NOT_FOUND` — the `sourceId` does not exist - `COMBATANT_SOURCE_NOT_OWNED` — the caller does not own the source Character or Npc - `COMBATANT_DUPLICATE` — the same `(combatantType, sourceId)` pair is already on the encounter - `ENCOUNTER_LOCKED_FOR_COMBAT` — the encounter is `active` or `ended`; combatants may only be added during `setup` 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getEncountersApi();
final String id = id_example; // String | Encounter identifier (cuid2)
final CombatantCreate combatantCreate = {"combatantType":"pc","sourceId":"cuid_char01"}; // CombatantCreate | 

try {
    final response = api.addCombatant(id, combatantCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->addCombatant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Encounter identifier (cuid2) | 
 **combatantCreate** | [**CombatantCreate**](CombatantCreate.md)|  | 

### Return type

[**Combatant**](Combatant.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

# **deleteCombatant**
> deleteCombatant(id)

Remove a combatant from an encounter

Permanently removes the combatant from the encounter. Only allowed while the encounter is in `setup` status. Returns 422 `ENCOUNTER_LOCKED_FOR_COMBAT` when the encounter is `active` or `ended`.  ACL is resolved through the encounter's parent game session owner. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getEncountersApi();
final String id = id_example; // String | Combatant identifier (cuid2)

try {
    api.deleteCombatant(id);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->deleteCombatant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Combatant identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

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

# **listCombatants**
> CombatantList listCombatants(id)

List combatants for an encounter

Returns all combatants belonging to the encounter identified by `id`. Results are unordered until initiative is rolled (Block 4); after rolling they are returned sorted by `turnOrder` ascending.  Owner-gated through the encounter's parent game session. 

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
    final response = api.listCombatants(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->listCombatants: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Encounter identifier (cuid2) | 

### Return type

[**CombatantList**](CombatantList.md)

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

# **updateCombatant**
> Combatant updateCombatant(id, combatantUpdate)

Update a combatant

Applies PATCH semantics to a combatant. Only mutable fields are accepted: `hpCurrent`, `armor`, `signature`, `statusFlags`, `notes`, `displayName`. Immutable fields (`combatantType`, `sourceId`) are absent from the schema. `initiative` and `turnOrder` are read-only here and are only set via the initiative operations (Block 4).  Allowed during both `setup` and `active` encounters. Returns 422 `ENCOUNTER_ENDED` if the encounter status is `ended`.  ACL is resolved through the encounter's parent game session owner. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getEncountersApi();
final String id = id_example; // String | Combatant identifier (cuid2)
final CombatantUpdate combatantUpdate = {"hpCurrent":0,"statusFlags":["broken"]}; // CombatantUpdate | 

try {
    final response = api.updateCombatant(id, combatantUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->updateCombatant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Combatant identifier (cuid2) | 
 **combatantUpdate** | [**CombatantUpdate**](CombatantUpdate.md)|  | 

### Return type

[**Combatant**](Combatant.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
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

