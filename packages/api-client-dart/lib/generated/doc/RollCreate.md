# app_api_client.model.RollCreate

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**kind** | [**RollKind**](RollKind.md) | What kind of roll to create. Defaults to `skill` when omitted (back-compat for callers from before T-2026-05-10-015 landed). Once persisted, the kind is immutable.  | [optional] [default to RollKind.skill]
**label** | **String** | Human-readable roll label, e.g. \"Pilot · Evade\" | 
**pool** | **int** | Number of d6 to roll. Must be between 0 and 20 inclusive. Condition pool penalties must be pre-applied by the caller before submitting.  «Ноль кубиков» (ГЛАВА 3 line 161): if modifiers reduce the pool to zero (or below), submit `pool: 0`. The engine then rolls 2d6 and counts a success only when both dice are 6.  PRD override — ST3001 does not name a hard upper bound. We cap at 20 to keep wire payloads bounded; realistic attribute + skill + gear + helpers stacks max out around 12–14.  | 
**gameSessionId** | **String** | Optional game session identifier. Reserved for Feature 7.2. Pass null or omit until GameSession lands.  | [optional] 
**breakdown** | [**RollBreakdown**](RollBreakdown.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


