# app_api_client.model.TalentCreate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**kind** | [**TalentKind**](TalentKind.md) | Defaults to `personal`. Pass `crew` / `iconGift` / `stigma` to record a starting-talent slot of that kind (only one of each non-`personal` kind is allowed per character).  | [optional] 
**name** | **String** | Talent name | 
**description** | **String** | Rules text or flavour description | 
**rank** | **int** | Talent rank (defaults to 1 when not provided) | [optional] [default to 1]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


