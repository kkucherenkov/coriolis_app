# app_api_client.api.EncountersApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addCombatant**](EncountersApi.md#addcombatant) | **POST** /api/v1/encounters/{id}/combatants | Add a combatant to an encounter
[**advanceTurn**](EncountersApi.md#advanceturn) | **POST** /api/v1/encounters/{id}/turn/advance | Advance to the next combatant&#39;s turn
[**createEncounter**](EncountersApi.md#createencounter) | **POST** /api/v1/game-sessions/{sessionId}/encounters | Create an encounter in a game session
[**deleteCombatant**](EncountersApi.md#deletecombatant) | **DELETE** /api/v1/combatants/{id} | Remove a combatant from an encounter
[**deleteEncounter**](EncountersApi.md#deleteencounter) | **DELETE** /api/v1/encounters/{id} | Delete an encounter
[**getEncounter**](EncountersApi.md#getencounter) | **GET** /api/v1/encounters/{id} | Get an encounter by ID
[**listCombatants**](EncountersApi.md#listcombatants) | **GET** /api/v1/encounters/{id}/combatants | List combatants for an encounter
[**listEncounters**](EncountersApi.md#listencounters) | **GET** /api/v1/game-sessions/{sessionId}/encounters | List encounters for a game session
[**reorderInitiative**](EncountersApi.md#reorderinitiative) | **PATCH** /api/v1/encounters/{id}/initiative | Manually reorder the turn order (GM only)
[**rollInitiative**](EncountersApi.md#rollinitiative) | **POST** /api/v1/encounters/{id}/initiative/roll | Roll initiative for all combatants and start combat
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

# **advanceTurn**
> TurnAdvanceResult advanceTurn(id)

Advance to the next combatant's turn

Moves `encounter.activeCombatantId` forward by one position in the turn order: `(currentIndex + 1) % combatants.length`.  **Wrap behaviour:** when the advance moves past the last combatant (index `combatants.length - 1`), the turn wraps to index 0 and `encounter.round` is incremented by 1. `TurnAdvanceResult.isNewRound` is `true` in that case.  **Allowed only while `status` is `active`.** Returns 422 `ENCOUNTER_INVALID_STATUS` otherwise.  **Defensive guard:** returns 422 `ENCOUNTER_INITIATIVE_NOT_ROLLED` when `activeCombatantId` is null (i.e. initiative was never set, which should not be reachable via normal `rollInitiative` flow but is possible if a future code path bypasses that operation).  **Error codes (422):** - `ENCOUNTER_INVALID_STATUS` — encounter is not in `active` status. - `ENCOUNTER_INITIATIVE_NOT_ROLLED` — `activeCombatantId` is null;   initiative must be rolled before turns can be advanced. 

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
    final response = api.advanceTurn(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->advanceTurn: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Encounter identifier (cuid2) | 

### Return type

[**TurnAdvanceResult**](TurnAdvanceResult.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
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

# **reorderInitiative**
> InitiativeRollResult reorderInitiative(id, initiativeReorderRequest)

Manually reorder the turn order (GM only)

Allows the GM to rearrange the turn order without re-rolling initiative dice. The request body must contain the full ordered list of every combatant id in the encounter exactly once. The server reassigns `turnOrder` indices (0-based) matching the array position.  **This operation does NOT:** - Re-roll initiative dice (`initiative` values remain unchanged). - Change `encounter.activeCombatantId` (the combatant whose turn is   currently active stays active; the reorder takes effect from the   next turn advance). - Change `encounter.round`.  **Allowed only while `status` is `active`.** Returns 422 `ENCOUNTER_INVALID_STATUS` if called from `setup` (use `rollInitiative` instead) or `ended`.  **Validation error codes (422):** - `ENCOUNTER_INVALID_STATUS` — encounter is not in `active` status. - `INITIATIVE_INCOMPLETE` — at least one combatant id from the   encounter is absent from `combatantIds`. - `INITIATIVE_DUPLICATE` — the same id appears two or more times   in `combatantIds`. - `INITIATIVE_UNKNOWN_COMBATANT` — an id in `combatantIds` does not   belong to this encounter. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getEncountersApi();
final String id = id_example; // String | Encounter identifier (cuid2)
final InitiativeReorderRequest initiativeReorderRequest = {"combatantIds":["cuid_comb03","cuid_comb02","cuid_comb01","cuid_comb04"]}; // InitiativeReorderRequest | 

try {
    final response = api.reorderInitiative(id, initiativeReorderRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->reorderInitiative: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Encounter identifier (cuid2) | 
 **initiativeReorderRequest** | [**InitiativeReorderRequest**](InitiativeReorderRequest.md)|  | 

### Return type

[**InitiativeRollResult**](InitiativeRollResult.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rollInitiative**
> InitiativeRollResult rollInitiative(id)

Roll initiative for all combatants and start combat

Rolls a d10 (`crypto.randomInt(1, 11)`) for every combatant in the encounter, sorts them descending, assigns `turnOrder` indices (0-based), and transitions the encounter from `setup` to `active`.  **Side-effects (all atomic):** 1. Encounter `status` transitions `setup → active`. 2. `encounter.round` is set from 0 to 1. 3. `encounter.activeCombatantId` is set to the combatant with    `turnOrder: 0` (highest initiative result). 4. Every combatant row is updated with its `initiative` and `turnOrder`.  **Tie-breaking:** equal initiative rolls are broken by `agility` descending (`attributes.agility` for PC combatants; `npcSnapshot.agility` for NPC combatants snapshotted at add-time). Remaining ties (equal initiative **and** equal agility) are left in an arbitrary but stable order — the GM should use the `PATCH /api/v1/encounters/{id}/initiative` reorder operation to set a definitive order before the first turn.  **Error codes (422):** - `ENCOUNTER_INVALID_TRANSITION` — encounter is not in `setup` status.   Initiative roll is only valid from `setup`; if the encounter is   already `active` or `ended` this guard fires. - `ENCOUNTER_NO_COMBATANTS` — the encounter has no combatants. Add at   least one via `POST /api/v1/encounters/{id}/combatants` before   rolling initiative. 

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
    final response = api.rollInitiative(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EncountersApi->rollInitiative: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Encounter identifier (cuid2) | 

### Return type

[**InitiativeRollResult**](InitiativeRollResult.md)

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

