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
**initiative** | **int** | Combat initiative value — the d6 base roll (1..6 per ST3001 ГЛАВА 5 «Раунды, ходы и инициатива» — «Бросьте по кубику за всех участников сражения») plus per-weapon initiative modifiers (ГЛАВА 6 «Инициатива» column on each weapon table) and any ambush / situational +2 from ГЛАВА 5 §«Повышение инициативы». The 1..10 range accommodates a base roll of 6 plus stacked modifiers (e.g. Посох +2 + ambush +2 = 10). Null until the encounter's initiative is rolled. Set server-side only.  | 
**turnOrder** | **int** | 0-based index in the turn sequence after initiative is sorted. Null until initiative is rolled. Combatant at index 0 goes first. Set server-side only.  | 
**hpCurrent** | **int** | Current hit points. **PRD override** — ST3001 ГЛАВА 5 «Урон» («запас пунктов здоровья не может опуститься ниже нуля») clamps HP at 0; the canonical mechanic is «Небоеспособность» the moment HP reaches 0. The greenfield product allows the field to go negative so the GM tracker can show damage overflow on a single attack (e.g. a 5-HP target taking 8 damage renders as `hpCurrent: -3` until the GM resets to 0 next round). UI clients SHOULD render negative values in red and surface a one-line note that the canon clamp applies for healing math (any heal first brings hpCurrent up to 0, then upward).  | 
**hpMax** | **int** | Maximum hit points snapshotted from the source at add-time. | 
**armor** | **int** | Armor rating (number of armor dice). Snapshotted from the source at add-time. | 
**signature** | **int** | NPC sensor signature score, snapshotted from `Npc.signature` at add-time (defaults to 0 for PC combatants). **PRD override** — ST3001 has no per-combatant numeric `signature` stat; the canonical mechanic for being spotted / hidden is the `скрытность` skill (ГЛАВА 3 «СКРЫТНОСТЬ») rolled at the moment of detection. The field is reserved for future GM tooling (sensor sweep, ambush detection, ship-combat sensor pings — ГЛАВА 7 covers ship-scale sensor rules but assigns those values to the ship, not the crew). Today the field is mostly informational; clients SHOULD allow editing but MUST NOT silently use it to bypass a `скрытность` check.  | 
**statusFlags** | **BuiltList&lt;String&gt;** | Free-form short tags describing combat status conditions. The canonical taxonomy in ST3001 ГЛАВА 5 «Раунды, ходы и инициатива» covers `incapacitated` (HP at 0 — cannot act), `prone` (knocked down) and `covered` (behind cover for armor purposes). The field is intentionally not enum-locked: GMs are expected to invent scene-specific tags (e.g. `bleeding`, `restrained`, `zero-g`), and a hard schema would force migrations every time a campaign needs a new condition. Clients SHOULD render the canonical tags with icons; unknown tags MUST be shown as plain text and preserved on PATCH round-trips.  | 
**notes** | **String** | Optional GM notes for this combatant in Markdown format (max 500 characters). | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


