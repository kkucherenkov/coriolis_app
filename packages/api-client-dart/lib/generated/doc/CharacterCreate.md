# app_api_client.model.CharacterCreate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | 
**concept** | [**Concept**](Concept.md) |  | [optional] 
**iconId** | [**IconId**](IconId.md) |  | [optional] 
**upbringing** | [**Upbringing**](Upbringing.md) |  | 
**origin** | **String** |  | [optional] 
**attributes** | [**Attributes**](Attributes.md) |  | [optional] 
**skills** | [**Skills**](Skills.md) |  | [optional] 
**hp** | [**CharacterCreateHp**](CharacterCreateHp.md) |  | [optional] 
**mp** | [**CharacterCreateHp**](CharacterCreateHp.md) |  | [optional] 
**experience** | **int** |  | [optional] [default to 0]
**conditions** | [**ConditionFlags**](ConditionFlags.md) |  | [optional] 
**notes** | **String** |  | [optional] 
**status** | **String** | Initial lifecycle state. Omit (or set `active`) for normal creation. Set to `draft` when starting the character-creation wizard.  | [optional] [default to 'active']

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


