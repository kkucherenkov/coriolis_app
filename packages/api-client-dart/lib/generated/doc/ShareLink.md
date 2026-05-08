# app_api_client.model.ShareLink

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque share-link identifier (cuid2). Used for revocation. | 
**slug** | **String** | 24-character URL-safe slug. Use in the public URL: `/api/v1/public/character/{slug}`.  | 
**characterId** | **String** | ID of the character this link exposes. | 
**includeGmNotes** | **bool** | Whether the `notes` field is included in the public character response. Always false if not set at creation time.  | 
**label** | **String** | Owner-assigned label for this link. | [optional] 
**expiresAt** | [**DateTime**](DateTime.md) | Expiry instant. Null for permanent links. | 
**revokedAt** | [**DateTime**](DateTime.md) | Revocation instant. Null if active. When set, the public endpoint returns 410 Gone.  | 
**lastViewedAt** | [**DateTime**](DateTime.md) | ISO-8601 instant of the last recorded public view. Updated asynchronously (up to 60 seconds lag) via the view-tracker flush job. Null until the first view is flushed.  | 
**viewCount** | **int** | Cumulative count of public views. Updated asynchronously; may lag by up to 60 seconds.  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


