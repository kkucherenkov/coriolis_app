# app_api_client.model.Combatant

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque combatant identifier (cuid2) | 
**encounterId** | **String** | Identifier of the parent encounter (cuid2) | 
**combatantType** | [**CombatantType**](CombatantType.md) |  | 
**sourceId** | **String** | Identifier of the source entity. When `combatantType` is `pc` this is the `Character.id`; when `npc` it is the `Npc.id`.  | 
**displayName** | **String** | Denormalised name of the combatant, copied from the source entity's `name` at add-time. Can be overridden in `CombatantCreate.displayName` or updated via `PATCH`.  | 
**initiative** | **int** | d6 initiative result (1–6 per ST3001 ГЛАВА 5 «Раунды, ходы и инициатива»: «Бросьте по кубику за всех участников сражения»). Null until the encounter's initiative is rolled (Block 4 operation). Set server-side only.  | 
**turnOrder** | **int** | 0-based index in the turn sequence after initiative is sorted. Null until initiative is rolled. Combatant at index 0 goes first. Set server-side only.  | 
**hpCurrent** | **int** | Current hit points. May go below 0 (CT3001 does not clamp). | 
**hpMax** | **int** | Maximum hit points snapshotted from the source at add-time. | 
**armor** | **int** | Armor rating (number of armor dice). Snapshotted from the source at add-time. | 
**signature** | **int** | Mystic Darkness signature value. Defaults to 0 for PC combatants; copied from `Npc.signature` for NPC combatants at add-time.  | 
**statusFlags** | **BuiltList&lt;String&gt;** | Free-form short tags describing combat status conditions. The canonical taxonomy in ST3001 ГЛАВА 5 «Раунды, ходы и инициатива» covers `incapacitated` (HP at 0 — cannot act), `prone` (knocked down) and `covered` (behind cover for armor purposes). The field is intentionally not enum-locked: GMs are expected to invent scene-specific tags (e.g. `bleeding`, `restrained`, `zero-g`), and a hard schema would force migrations every time a campaign needs a new condition. Clients SHOULD render the canonical tags with icons; unknown tags MUST be shown as plain text and preserved on PATCH round-trips.  | 
**notes** | **String** | Optional GM notes for this combatant in Markdown format (max 500 characters). | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


