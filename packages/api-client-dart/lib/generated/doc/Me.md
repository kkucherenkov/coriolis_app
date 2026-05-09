# app_api_client.model.Me

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque user identifier issued by Better Auth (cuid2) | 
**email** | **String** | Primary email address. Read-only via this API. | 
**displayName** | **String** | User-chosen display name shown in share-link banners and the avatar menu. Null when the user has not set one yet.  | 
**createdAt** | [**DateTime**](DateTime.md) | ISO-8601 instant when the account was created. Read-only via this API. | 
**theme** | **String** | UI theme preference. Synced across web + mobile so a player who toggles high-contrast on one device sees it everywhere. `dark` is the default; `high-contrast` increases colour contrast for users who need improved readability.  | [optional] [default to 'dark']

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


