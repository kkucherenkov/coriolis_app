# app_api_client.model.Roll

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque roll identifier (cuid2) | 
**characterId** | **String** | Identifier of the character who made the roll | 
**gameSessionId** | **String** | Game session this roll belongs to. Null until Feature 7.2 (GameSession resource) ships. Clients should tolerate null.  | [optional] 
**label** | **String** | Human-readable roll label, e.g. \"Pilot · Evade\" | 
**pool** | **int** | Number of d6 rolled (after condition penalties applied by caller). `0` triggers the «Ноль кубиков» rule (ГЛАВА 3 line 161): the engine still rolls 2d6, but the proverka counts as a success only when both dice come up 6. PRD override — Coriolis ST3001 does not name a hard upper bound. We cap at 20 to keep DB rows and wire payloads bounded; realistic attribute + skill + gear + helpers stacks max out around 12–14.  | 
**dice** | **BuiltList&lt;int&gt;** | Current face values of all dice. After a push, rerolled non-6 values are updated in place. Length normally equals `pool`; for the zero- dice case (`pool === 0`) the array always has 2 elements regardless.  | 
**hits** | **int** | Number of 6s in the current dice array | 
**pushed** | **bool** | Whether this roll has been pushed. Once true, further pushes are rejected. | 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


