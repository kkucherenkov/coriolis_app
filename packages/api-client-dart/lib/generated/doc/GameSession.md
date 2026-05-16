# app_api_client.model.GameSession

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque session identifier (cuid2) | 
**ownerId** | **String** | User identifier of the GM who owns this session | 
**name** | **String** | Short name for the session | 
**description** | **String** | Optional longer description | [optional] 
**status** | [**GameSessionStatus**](GameSessionStatus.md) |  | 
**dpCount** | **int** | Darkness Points counter; mutated by Feature 7.3 | 
**shipId** | **String** | Optional ship linked to the session (Epic 8) | [optional] 
**memberships** | [**BuiltList&lt;GameSessionMembership&gt;**](GameSessionMembership.md) | Active members of this session. Always includes the GM row. Single source of truth for \"who is at this table\" since Phase 8 Stream E removed the legacy `characterIds` array. Each row optionally carries `characterId` — that's how a player (or GM) links a PC to their seat.  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


