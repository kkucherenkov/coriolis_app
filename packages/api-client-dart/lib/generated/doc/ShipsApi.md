# app_api_client.api.ShipsApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addShipModule**](ShipsApi.md#addshipmodule) | **POST** /api/v1/ships/{id}/modules | Add a module to a ship
[**assignCrew**](ShipsApi.md#assigncrew) | **POST** /api/v1/ships/{id}/crew | Assign a character to a crew position
[**createShip**](ShipsApi.md#createship) | **POST** /api/v1/ships | Create a new ship
[**deleteShip**](ShipsApi.md#deleteship) | **DELETE** /api/v1/ships/{id} | Delete a ship
[**deleteShipModule**](ShipsApi.md#deleteshipmodule) | **DELETE** /api/v1/ship-modules/{id} | Remove a module from a ship
[**duplicateShip**](ShipsApi.md#duplicateship) | **POST** /api/v1/ships/{id}/duplicate | Duplicate a ship
[**exportShip**](ShipsApi.md#exportship) | **GET** /api/v1/ships/{id}/export | Export a ship as JSON
[**getShip**](ShipsApi.md#getship) | **GET** /api/v1/ships/{id} | Get a ship by ID
[**listShips**](ShipsApi.md#listships) | **GET** /api/v1/ships | List the authenticated user&#39;s ships
[**unassignCrew**](ShipsApi.md#unassigncrew) | **DELETE** /api/v1/ships/{id}/crew/{characterId} | Remove a character from the crew
[**updateShip**](ShipsApi.md#updateship) | **PATCH** /api/v1/ships/{id} | Partially update a ship
[**updateShipModule**](ShipsApi.md#updateshipmodule) | **PATCH** /api/v1/ship-modules/{id} | Update a ship module


# **addShipModule**
> ShipModule addShipModule(id, shipModuleCreate)

Add a module to a ship

Installs a new module on the ship. The `slot` discriminator determines which type-specific fields are accepted. Validates that the slot type is appropriate for the requested module. The ship must be owned by the caller. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String id = id_example; // String | Ship identifier (cuid2)
final ShipModuleCreate shipModuleCreate = {"slot":"WEAPON","name":"Graviton Projector","energyUse":2,"weaponBonus":1,"weaponRange":"medium","weaponDamage":2,"weaponCritThreshold":2}; // ShipModuleCreate | 

try {
    final response = api.addShipModule(id, shipModuleCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->addShipModule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Ship identifier (cuid2) | 
 **shipModuleCreate** | [**ShipModuleCreate**](ShipModuleCreate.md)|  | 

### Return type

[**ShipModule**](ShipModule.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **assignCrew**
> CrewSlot assignCrew(id, assignCrewRequest)

Assign a character to a crew position

Assigns one of the caller's own characters to a crew position on the ship. The ship must be owned by the caller. The character must also be owned by the caller (returns `CHARACTER_NOT_OWNED` otherwise). Returns `CREW_POSITION_TAKEN` if that position is already filled. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String id = id_example; // String | Ship identifier (cuid2)
final AssignCrewRequest assignCrewRequest = {"position":"captain","characterId":"cuid_tariq01"}; // AssignCrewRequest | 

try {
    final response = api.assignCrew(id, assignCrewRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->assignCrew: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Ship identifier (cuid2) | 
 **assignCrewRequest** | [**AssignCrewRequest**](AssignCrewRequest.md)|  | 

### Return type

[**CrewSlot**](CrewSlot.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createShip**
> Ship createShip(shipCreate)

Create a new ship

Creates a ship owned by the authenticated user. `name` and `class` are required; all other fields default to class-appropriate values per ST3001 ГЛАВА 7 Table 7.5. Server assigns `id`, `ownerId`, `createdAt`, `updatedAt`. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final ShipCreate shipCreate = {"name":"Narzal","class":"courier-yacht"}; // ShipCreate | 

try {
    final response = api.createShip(shipCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->createShip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shipCreate** | [**ShipCreate**](ShipCreate.md)|  | 

### Return type

[**Ship**](Ship.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteShip**
> deleteShip(id)

Delete a ship

Permanently deletes a ship and all its modules, crew assignments, and share links. This action is irreversible. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String id = id_example; // String | Ship identifier (cuid2)

try {
    api.deleteShip(id);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->deleteShip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Ship identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteShipModule**
> deleteShipModule(id)

Remove a module from a ship

Permanently removes an installed module. Authorization: caller must own the parent ship. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String id = id_example; // String | Ship module identifier (cuid2)

try {
    api.deleteShipModule(id);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->deleteShipModule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Ship module identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **duplicateShip**
> Ship duplicateShip(id)

Duplicate a ship

Creates a deep copy of the ship (including modules and problems) and assigns it to the authenticated user. The copy receives a new `id` and the name has \" (copy)\" appended. Crew assignments and share links are not duplicated. The source ship must be owned by the caller. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String id = id_example; // String | Ship identifier (cuid2)

try {
    final response = api.duplicateShip(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->duplicateShip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Ship identifier (cuid2) | 

### Return type

[**Ship**](Ship.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **exportShip**
> Ship exportShip(id)

Export a ship as JSON

Returns the full canonical Ship DTO as a downloadable JSON payload. The response carries `Content-Disposition: attachment` so browsers prompt a download. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String id = id_example; // String | Ship identifier (cuid2)

try {
    final response = api.exportShip(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->exportShip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Ship identifier (cuid2) | 

### Return type

[**Ship**](Ship.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getShip**
> Ship getShip(id)

Get a ship by ID

Returns the full Ship DTO. Returns 404 if the ship does not exist or is not owned by the authenticated user. Owner-scoped: a ship owned by another user returns 403. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String id = id_example; // String | Ship identifier (cuid2)

try {
    final response = api.getShip(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->getShip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Ship identifier (cuid2) | 

### Return type

[**Ship**](Ship.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listShips**
> ShipList listShips(cursor, limit)

List the authenticated user's ships

Returns a cursor-paginated list of ships owned by the authenticated user. Pass `cursor` from a previous response's `nextCursor` to retrieve the following page. Results are ordered newest-first by `createdAt`. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String cursor = cursor_example; // String | Opaque pagination cursor returned by the previous page
final int limit = 56; // int | Number of ships to return (1–100, default 20)

try {
    final response = api.listShips(cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->listShips: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| Opaque pagination cursor returned by the previous page | [optional] 
 **limit** | **int**| Number of ships to return (1–100, default 20) | [optional] [default to 20]

### Return type

[**ShipList**](ShipList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unassignCrew**
> unassignCrew(id, characterId)

Remove a character from the crew

Removes the crew assignment for the given character ID on the ship. Both the ship and the character must be owned by the caller. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String id = id_example; // String | Ship identifier (cuid2)
final String characterId = characterId_example; // String | Character identifier to remove from the crew

try {
    api.unassignCrew(id, characterId);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->unassignCrew: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Ship identifier (cuid2) | 
 **characterId** | **String**| Character identifier to remove from the crew | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateShip**
> Ship updateShip(id, shipUpdate)

Partially update a ship

Applies PATCH semantics — omitted fields are left unchanged. Read-only fields (`id`, `ownerId`, `createdAt`, `updatedAt`) are rejected with 400 if included. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String id = id_example; // String | Ship identifier (cuid2)
final ShipUpdate shipUpdate = {"name":"Madara (repaired)"}; // ShipUpdate | 

try {
    final response = api.updateShip(id, shipUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->updateShip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Ship identifier (cuid2) | 
 **shipUpdate** | [**ShipUpdate**](ShipUpdate.md)|  | 

### Return type

[**Ship**](Ship.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateShipModule**
> ShipModule updateShipModule(id, shipModuleUpdate)

Update a ship module

Applies PATCH semantics to a ship module. The `slot` discriminator may not be changed after installation — attempting to do so returns 400 with code `MODULE_TYPE_MISMATCH`. Authorization: caller must own the parent ship. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getShipsApi();
final String id = id_example; // String | Ship module identifier (cuid2)
final ShipModuleUpdate shipModuleUpdate = {"slot":"WEAPON","name":"EMP Cannon","weaponDamage":1,"notes":"Systemed weapon — hits sensors"}; // ShipModuleUpdate | 

try {
    final response = api.updateShipModule(id, shipModuleUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ShipsApi->updateShipModule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Ship module identifier (cuid2) | 
 **shipModuleUpdate** | [**ShipModuleUpdate**](ShipModuleUpdate.md)|  | 

### Return type

[**ShipModule**](ShipModule.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

