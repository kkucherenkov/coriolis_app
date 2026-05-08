# app_api_client.model.CharacterUpdate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** |  | [optional] 
**concept** | **String** |  | [optional] 
**iconId** | [**IconId**](IconId.md) |  | [optional] 
**attributes** | [**Attributes**](Attributes.md) |  | [optional] 
**skills** | [**Skills**](Skills.md) |  | [optional] 
**hp** | [**CharacterCreateHp**](CharacterCreateHp.md) |  | [optional] 
**mp** | [**CharacterCreateHp**](CharacterCreateHp.md) |  | [optional] 
**experience** | **int** |  | [optional] 
**conditions** | [**ConditionFlags**](ConditionFlags.md) |  | [optional] 
**criticalInjuries** | [**BuiltList&lt;CriticalInjury&gt;**](CriticalInjury.md) | Replaces the entire critical injuries list when provided. Use the dedicated nested-item pattern (POST/PATCH/DELETE on individual injuries) once that surface is added in a later epic.  | [optional] 
**notes** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


