# app_api_client.api.GameSessionsApi

## Load the API package
```dart
import 'package:app_api_client/api.dart';
```

All URIs are relative to *http://localhost:3010*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adjustDp**](GameSessionsApi.md#adjustdp) | **POST** /api/v1/game-sessions/{id}/dp | Adjust Darkness Points for a game session
[**blockMember**](GameSessionsApi.md#blockmember) | **POST** /api/v1/game-sessions/{id}/blocks | Block a session member
[**createGameSession**](GameSessionsApi.md#creategamesession) | **POST** /api/v1/game-sessions | Create a new game session
[**deleteGameSession**](GameSessionsApi.md#deletegamesession) | **DELETE** /api/v1/game-sessions/{id} | Delete a game session
[**getGameSession**](GameSessionsApi.md#getgamesession) | **GET** /api/v1/game-sessions/{id} | Get a game session by ID
[**getInviteMetadata**](GameSessionsApi.md#getinvitemetadata) | **GET** /api/v1/game-sessions/{id}/invite | Read invite metadata (GM only)
[**linkMembershipCharacter**](GameSessionsApi.md#linkmembershipcharacter) | **PATCH** /api/v1/game-sessions/{id}/members/{membershipId} | Link or unlink a character to a membership
[**listBlocks**](GameSessionsApi.md#listblocks) | **GET** /api/v1/game-sessions/{id}/blocks | List the caller&#39;s block list for a session
[**listChatConversations**](GameSessionsApi.md#listchatconversations) | **GET** /api/v1/game-sessions/{id}/chat/conversations | List chat conversations for a session member
[**listChatMessages**](GameSessionsApi.md#listchatmessages) | **GET** /api/v1/game-sessions/{id}/chat/messages | List chat messages for a session conversation
[**listDpEvents**](GameSessionsApi.md#listdpevents) | **GET** /api/v1/game-sessions/{id}/dp/events | List Darkness Point audit events for a session
[**listGameSessions**](GameSessionsApi.md#listgamesessions) | **GET** /api/v1/game-sessions | List the authenticated GM&#39;s game sessions
[**listMembers**](GameSessionsApi.md#listmembers) | **GET** /api/v1/game-sessions/{id}/members | List session members (GM or member)
[**markChatConversationRead**](GameSessionsApi.md#markchatconversationread) | **POST** /api/v1/game-sessions/{id}/chat/conversations/{conversationKey}/read | Mark a conversation as read up to a timestamp
[**postChatMessage**](GameSessionsApi.md#postchatmessage) | **POST** /api/v1/game-sessions/{id}/chat/messages | Post a chat message to a session
[**removeMembership**](GameSessionsApi.md#removemembership) | **DELETE** /api/v1/game-sessions/{id}/members/{membershipId} | Kick (GM) or leave (member) — soft delete
[**revokeInvite**](GameSessionsApi.md#revokeinvite) | **DELETE** /api/v1/game-sessions/{id}/invite | Revoke the current invite (GM only)
[**rotateInvite**](GameSessionsApi.md#rotateinvite) | **POST** /api/v1/game-sessions/{id}/invite/rotate | Rotate (or first-generate) the session&#39;s invite link (GM only)
[**unblockMember**](GameSessionsApi.md#unblockmember) | **DELETE** /api/v1/game-sessions/{id}/blocks/{targetMembershipId} | Unblock a session member
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

# **blockMember**
> blockMember(id, chatBlockRequest)

Block a session member

Adds the target membership to the caller's block list for this session. Idempotent — blocking an already-blocked member is a no-op. Once blocked, the blocked member cannot whisper to the blocker. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final ChatBlockRequest chatBlockRequest = {"targetMembershipId":"cuid_mem02"}; // ChatBlockRequest | 

try {
    api.blockMember(id, chatBlockRequest);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->blockMember: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **chatBlockRequest** | [**ChatBlockRequest**](ChatBlockRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

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

# **getInviteMetadata**
> InviteMetadata getInviteMetadata(id)

Read invite metadata (GM only)

Returns whether an invite is active for this session and when it was last rotated. Never returns the plaintext URL — that is revealed exactly once by POST /invite/rotate. 

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
    final response = api.getInviteMetadata(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->getInviteMetadata: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 

### Return type

[**InviteMetadata**](InviteMetadata.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **linkMembershipCharacter**
> GameSessionMembership linkMembershipCharacter(id, membershipId, linkMembershipCharacterRequest)

Link or unlink a character to a membership

The owner of the membership (the player or the GM themselves) can change which character is attached. The GM can also operate on any membership for moderation. Pass `characterId: null` to unlink. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final String membershipId = membershipId_example; // String | Membership identifier (cuid2)
final LinkMembershipCharacterRequest linkMembershipCharacterRequest = {characterId=cuid_char01}; // LinkMembershipCharacterRequest | 

try {
    final response = api.linkMembershipCharacter(id, membershipId, linkMembershipCharacterRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->linkMembershipCharacter: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **membershipId** | **String**| Membership identifier (cuid2) | 
 **linkMembershipCharacterRequest** | [**LinkMembershipCharacterRequest**](LinkMembershipCharacterRequest.md)|  | 

### Return type

[**GameSessionMembership**](GameSessionMembership.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBlocks**
> ListBlocks200Response listBlocks(id)

List the caller's block list for a session

Returns all memberships the caller has blocked in this session. 

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
    final response = api.listBlocks(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->listBlocks: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 

### Return type

[**ListBlocks200Response**](ListBlocks200Response.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listChatConversations**
> ChatConversationList listChatConversations(id)

List chat conversations for a session member

Returns a summary of all conversations visible to the caller: the broadcast channel plus any whisper threads they participate in. Includes unread counts relative to the caller's read cursor. 

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
    final response = api.listChatConversations(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->listChatConversations: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 

### Return type

[**ChatConversationList**](ChatConversationList.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listChatMessages**
> ChatMessageList listChatMessages(id, conversation, cursor, limit)

List chat messages for a session conversation

Returns a cursor-paginated list of messages for the specified conversation. Pass `conversation=broadcast` (default) for the session broadcast channel, or pass a `membershipId` to read a whisper thread. Only the two participants of a whisper thread can see its messages. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final String conversation = conversation_example; // String | 'broadcast' or a membershipId (whisper partner)
final String cursor = cursor_example; // String | Opaque cursor from the previous page's nextCursor
final int limit = 56; // int | Number of messages to return (1–100, default 50)

try {
    final response = api.listChatMessages(id, conversation, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->listChatMessages: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **conversation** | **String**| 'broadcast' or a membershipId (whisper partner) | [optional] [default to 'broadcast']
 **cursor** | **String**| Opaque cursor from the previous page's nextCursor | [optional] 
 **limit** | **int**| Number of messages to return (1–100, default 50) | [optional] [default to 50]

### Return type

[**ChatMessageList**](ChatMessageList.md)

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

# **listMembers**
> BuiltList<GameSessionMembership> listMembers(id)

List session members (GM or member)

Returns active memberships for this session. Available to the GM and to any active member. Leaver rows (with non-null leftAt) are excluded. 

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
    final response = api.listMembers(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->listMembers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 

### Return type

[**BuiltList&lt;GameSessionMembership&gt;**](GameSessionMembership.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markChatConversationRead**
> markChatConversationRead(id, conversationKey, markReadRequest)

Mark a conversation as read up to a timestamp

Upserts the caller's read cursor for the given conversation. The `conversationKey` is URL-encoded; use `broadcast` for the session broadcast or a membershipId for a whisper thread. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final String conversationKey = conversationKey_example; // String | 'broadcast' or a membershipId (URL-encoded)
final MarkReadRequest markReadRequest = {"lastReadAt":"2026-05-17T10:05:00Z"}; // MarkReadRequest | 

try {
    api.markChatConversationRead(id, conversationKey, markReadRequest);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->markChatConversationRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **conversationKey** | **String**| 'broadcast' or a membershipId (URL-encoded) | 
 **markReadRequest** | [**MarkReadRequest**](MarkReadRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postChatMessage**
> ChatMessage postChatMessage(id, postChatMessageRequest)

Post a chat message to a session

Posts a broadcast (`targetMembershipId: null`) or whisper (`targetMembershipId: <membershipId>`) message. Returns 403 when the target has blocked the author. Returns 404 when the target is not an active session member. Rate-limited to 30 msg/min and 5/s burst per user. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final PostChatMessageRequest postChatMessageRequest = {"kind":"text","body":"Ready when you are, captain."}; // PostChatMessageRequest | 

try {
    final response = api.postChatMessage(id, postChatMessageRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->postChatMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **postChatMessageRequest** | [**PostChatMessageRequest**](PostChatMessageRequest.md)|  | 

### Return type

[**ChatMessage**](ChatMessage.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeMembership**
> removeMembership(id, membershipId)

Kick (GM) or leave (member) — soft delete

Stamps `leftAt` on the membership. The GM can kick any non-GM member; a player can self-leave. The GM cannot kick themselves. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final String membershipId = membershipId_example; // String | Membership identifier (cuid2)

try {
    api.removeMembership(id, membershipId);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->removeMembership: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **membershipId** | **String**| Membership identifier (cuid2) | 

### Return type

void (empty response body)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeInvite**
> revokeInvite(id)

Revoke the current invite (GM only)

Clears the invite hash on the session. Subsequent accept attempts return 410 Gone. Re-issuing requires POST /invite/rotate. 

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
    api.revokeInvite(id);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->revokeInvite: $e\n');
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

# **rotateInvite**
> InviteRotated rotateInvite(id)

Rotate (or first-generate) the session's invite link (GM only)

Generates a fresh 22-char URL-safe nanoid, stores its SHA-256 hash, and returns the plaintext URL exactly once. Any previously-issued invite immediately becomes invalid. 

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
    final response = api.rotateInvite(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->rotateInvite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 

### Return type

[**InviteRotated**](InviteRotated.md)

### Authorization

[cookieAuth](../README.md#cookieAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unblockMember**
> unblockMember(id, targetMembershipId)

Unblock a session member

Removes the target membership from the caller's block list. Idempotent — unblocking a member who was not blocked is a no-op. 

### Example
```dart
import 'package:app_api_client/api.dart';
// TODO Configure API key authorization: cookieAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('cookieAuth').apiKeyPrefix = 'Bearer';

final api = AppApiClient().getGameSessionsApi();
final String id = id_example; // String | Game session identifier (cuid2)
final String targetMembershipId = targetMembershipId_example; // String | Membership identifier of the member to unblock (cuid2)

try {
    api.unblockMember(id, targetMembershipId);
} on DioException catch (e) {
    print('Exception when calling GameSessionsApi->unblockMember: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Game session identifier (cuid2) | 
 **targetMembershipId** | **String**| Membership identifier of the member to unblock (cuid2) | 

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

