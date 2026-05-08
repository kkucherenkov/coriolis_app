# app_api_client.model.ShareLinkCreate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**includeGmNotes** | **bool** | When true, the public character endpoint returns the top-level `notes` field. When false (default), `notes` is always null in the public response regardless of the character's actual notes value.  | [optional] [default to false]
**expiresAt** | [**DateTime**](DateTime.md) | ISO-8601 instant after which the link stops resolving. Omit or set to null for a permanent link.  | [optional] 
**label** | **String** | Optional human-readable label to distinguish this link from others in the owner's list (e.g. \"GM copy\", \"public preview\").  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


