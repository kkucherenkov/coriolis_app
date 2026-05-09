# app_api_client.api.GameSessionsApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adjustDp**](GameSessionsApi.md#adjustdp) | **POST** /api/v1/game-sessions/{id}/dp | Adjust Darkness Points for a game session
[**assignCharacterToSession**](GameSessionsApi.md#assigncharactertosession) | **POST** /api/v1/game-sessions/{id}/characters | Assign a character to a game session
[**createGameSession**](GameSessionsApi.md#creategamesession) | **POST** /api/v1/game-sessions | Create a new game session
[**deleteGameSession**](GameSessionsApi.md#deletegamesession) | **DELETE** /api/v1/game-sessions/{id} | Delete a game session
[**getGameSession**](GameSessionsApi.md#getgamesession) | **GET** /api/v1/game-sessions/{id} | Get a game session by ID
[**listDpEvents**](GameSessionsApi.md#listdpevents) | **GET** /api/v1/game-sessions/{id}/dp/events | List Darkness Point audit events for a session
[**listGameSessions**](GameSessionsApi.md#listgamesessions) | **GET** /api/v1/game-sessions | List the authenticated GM&#39;s game sessions
[**unassignCharacterFromSession**](GameSessionsApi.md#unassigncharacterfromsession) | **DELETE** /api/v1/game-sessions/{id}/characters/{characterId} | Remove a character from a game session
[**updateGameSession**](GameSessionsApi.md#updategamesession) | **PATCH** /api/v1/game-sessions/{id} | Update a game session


# **adjustDp**
> GameSession adjustDp(id, dpAdjustment)

Adjust Darkness Points for a game session

Atomically adjusts the Darkness Points counter for the session.  **ACL rules:** - Negative `delta`: only the GM who owns the session may apply. - Positive `delta`: the GM owner may apply; the system applies   automatically via the roll-push pipeline.  **Error codes:** - `DP_INVALID_DELTA` (422) — `delta` is 0. - `DP_BELOW_ZERO` (422) — applying `delta` would take `dpCount` below 0. - `GAME_SESSION_NOT_OWNER` (403) — negative delta from non-owner. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final DpAdjustment dpAdjustment = {"delta":1,"reason":"Roll pushed by player"}; // DpAdjustment | 

try {
    final response = api.adjustDp(id, dpAdjustment);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->adjustDp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **dpAdjustment** | [**DpAdjustment**](DpAdjustment.md)|  | 

### Return type

[**GameSession**](GameSession.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **assignCharacterToSession**
> GameSession assignCharacterToSession(id, assignCharacterToSession)

Assign a character to a game session

Assigns one of the caller's own characters to the game session. The character must be owned by the same user as the session (GM). Assigning an already-assigned character is idempotent — returns the current session state without creating a duplicate. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final AssignCharacterToSession assignCharacterToSession = {"characterId":"cuid_char01"}; // AssignCharacterToSession | 

try {
    final response = api.assignCharacterToSession(id, assignCharacterToSession);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->assignCharacterToSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **assignCharacterToSession** | [**AssignCharacterToSession**](AssignCharacterToSession.md)|  | 

### Return type

[**GameSession**](GameSession.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createGameSession**
> GameSession createGameSession(gameSessionCreate)

Create a new game session

Creates a game session owned by the authenticated user (the GM). `name` is the only required field; all other fields are optional. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final GameSessionCreate gameSessionCreate = {"name":"The Long Night"}; // GameSessionCreate | 

try {
    final response = api.createGameSession(gameSessionCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->createGameSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **gameSessionCreate** | [**GameSessionCreate**](GameSessionCreate.md)|  | 

### Return type

[**GameSession**](GameSession.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteGameSession**
> deleteGameSession(id)

Delete a game session

Permanently deletes a game session. Cascades to the character assignment join table. The session must be owned by the caller. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)

try {
    api.deleteGameSession(id);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->deleteGameSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getGameSession**
> GameSession getGameSession(id)

Get a game session by ID

Returns the full game session DTO. Returns 404 if the session does not exist or is not owned by the authenticated user. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)

try {
    final response = api.getGameSession(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->getGameSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 

### Return type

[**GameSession**](GameSession.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDpEvents**
> DpEventList listDpEvents(id, cursor, limit)

List Darkness Point audit events for a session

Returns a cursor-paginated audit log of all DP adjustments made to the session, ordered newest-first. Only accessible by the GM owner. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final String cursor = cursor_example; // String | Opaque pagination cursor from the previous page
final int limit = 56; // int | Number of events to return (1–100, default 20)

try {
    final response = api.listDpEvents(id, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->listDpEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **cursor** | **String**| Opaque pagination cursor from the previous page | [optional] 
 **limit** | **int**| Number of events to return (1–100, default 20) | [optional] [default to 20]

### Return type

[**DpEventList**](DpEventList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGameSessions**
> GameSessionList listGameSessions(cursor, limit, status)

List the authenticated GM's game sessions

Returns a cursor-paginated list of game sessions owned by the authenticated user. Pass `cursor` from a previous response's `nextCursor` to retrieve the following page. Results are ordered newest-first by `createdAt`. Optionally filter by `status`. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String cursor = cursor_example; // String | Opaque pagination cursor returned by the previous page
final int limit = 56; // int | Number of sessions to return (1–100, default 20)
final GameSessionStatus status = ; // GameSessionStatus | Filter sessions by status

try {
    final response = api.listGameSessions(cursor, limit, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->listGameSessions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| Opaque pagination cursor returned by the previous page | [optional] 
 **limit** | **int**| Number of sessions to return (1–100, default 20) | [optional] [default to 20]
 **status** | [**GameSessionStatus**](.md)| Filter sessions by status | [optional] 

### Return type

[**GameSessionList**](GameSessionList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unassignCharacterFromSession**
> unassignCharacterFromSession(id, characterId)

Remove a character from a game session

Removes the character from the session's character list. The session must be owned by the caller. Silently succeeds if the character was not assigned. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final String characterId = characterId_example; // String | Character identifier (cuid2)

try {
    api.unassignCharacterFromSession(id, characterId);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->unassignCharacterFromSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **characterId** | **String**| Character identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateGameSession**
> GameSession updateGameSession(id, gameSessionUpdate)

Update a game session

Applies PATCH semantics to a game session. All fields are optional. Status transitions: `active → archived` and `archived → active` are both permitted. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final GameSessionUpdate gameSessionUpdate = {"status":"archived"}; // GameSessionUpdate | 

try {
    final response = api.updateGameSession(id, gameSessionUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->updateGameSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **gameSessionUpdate** | [**GameSessionUpdate**](GameSessionUpdate.md)|  | 

### Return type

[**GameSession**](GameSession.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

