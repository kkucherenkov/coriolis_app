# app_api_client.api.DiceApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createRoll**](DiceApi.md#createroll) | **POST** /api/v1/characters/{id}/rolls | Roll dice for a character
[**listRolls**](DiceApi.md#listrolls) | **GET** /api/v1/characters/{id}/rolls | List roll history for a character
[**pushRoll**](DiceApi.md#pushroll) | **PATCH** /api/v1/rolls/{id}/push | Push (reroll) a roll


# **createRoll**
> Roll createRoll(id, rollCreate)

Roll dice for a character

Rolls `pool` d6 server-side using a cryptographically secure RNG. Hits are counted as the number of 6s. The caller provides a human-readable `label` (e.g. \"Pilot · Evade\") and an optional `gameSessionId` (reserved for Feature 7.2 — pass null until GameSession lands).  Pool is clamped by the server from the submitted value. Condition penalties must be pre-applied by the caller before sending `pool`; the server does not re-apply them from character state.  When an optional `breakdown` object is supplied alongside `pool`, the server validates that `attribute + skill + gear + modifier + helpers === pool`; a mismatch is rejected with HTTP 400 `ROLL_BREAKDOWN_MISMATCH`. Programmatic callers (internal command handlers, dice engine) can omit `breakdown` entirely. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getDiceApi();
final String id = id_example; // String | Character identifier (cuid2)
final RollCreate rollCreate = ; // RollCreate | 

try {
    final response = api.createRoll(id, rollCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DiceApi->createRoll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 
 **rollCreate** | [**RollCreate**](RollCreate.md)|  | 

### Return type

[**Roll**](Roll.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRolls**
> RollList listRolls(id, limit)

List roll history for a character

Returns the most recent rolls for the character, ordered newest-first. Default limit is 50; maximum is 100. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getDiceApi();
final String id = id_example; // String | Character identifier (cuid2)
final int limit = 56; // int | Number of rolls to return (1–100, default 50)

try {
    final response = api.listRolls(id, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DiceApi->listRolls: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Character identifier (cuid2) | 
 **limit** | **int**| Number of rolls to return (1–100, default 50) | [optional] [default to 50]

### Return type

[**RollList**](RollList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pushRoll**
> Roll pushRoll(id)

Push (reroll) a roll

Rerolls all non-6 dice exactly once. After a push the roll cannot be pushed again (`pushed` becomes `true`). Returns 400 with code `PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL` if the roll's `kind` is not `skill` (ST3001 ГЛАВА 3 §«Вознесение молитв»). Returns 422 with code `ROLL_NOT_PUSHABLE` if: - The roll has already been pushed. - The owning character has the Exhausted condition (PRD §10). 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getDiceApi();
final String id = id_example; // String | Roll identifier (cuid2)

try {
    final response = api.pushRoll(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DiceApi->pushRoll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Roll identifier (cuid2) | 

### Return type

[**Roll**](Roll.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

