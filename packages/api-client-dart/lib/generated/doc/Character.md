# app_api_client.model.Character

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque character identifier (cuid2) | 
**ownerId** | **String** | Identifier of the owning user (cuid2) | 
**name** | **String** | Character name (1–80 characters) | 
**concept** | [**Concept**](Concept.md) |  | 
**role** | [**Role**](Role.md) |  | [optional] 
**roleUnmigrated** | **bool** | Server-side flag, true on rows backfilled by the canon-alignment migration that introduced `Character.role` (T-2026-05-10-010 Block E). The migration assigned each existing character the first canonical role of their amplua and set this flag so the web sheet can prompt the user to confirm or pick a different one. Cleared automatically by the server the first time the user PATCHes `role` to a non-null value (the explicit confirmation path). Always false on characters created after the migration ran. Read-only — clients do not set this; the server owns the lifecycle.  | [optional] [default to false]
**iconId** | [**IconId**](IconId.md) |  | 
**upbringing** | [**Upbringing**](Upbringing.md) | Social stratum the character was raised in. Set at creation and **immutable** — drives the starting attribute / skill point budgets and the initial values of `reputation` and `startingWealth`.  | 
**origin** | **String** | Free-text narrative description of where the character is from (home station, planet, or region). Has no mechanical effect.  | 
**reputation** | **int** | Current social reputation. Initial value is derived from `upbringing` (plebeian=2, stationary=4, aristocrat=6) and may change during play.  | 
**startingWealth** | **int** | The number of birrs (currency) the character started with at creation. Derived from `upbringing` (plebeian=500, stationary=1000, aristocrat=5000). Immutable historical record.  | 
**birr** | **int** | Current spendable birr balance (the character's wallet). Seeded from `startingWealth` when the wizard transitions `status: draft → active` (the forge step). Mutable any time after activation — debited on Bazaar purchases via the items API and credited from session payouts via PATCH. While the character is still a `draft`, the server keeps `birr` in lock-step with `startingWealth` so changing `upbringing` does not strand a stale balance; explicit PATCHes to `birr` on a draft are rejected with `BIRR_DRAFT_IMMUTABLE`.  | [optional] 
**crewConcept** | [**CrewConcept**](CrewConcept.md) |  | 
**mutant** | **bool** | Whether this character is a mutant (пасынок) per Coriolis ST3001 ch.4 §Стигмы пасынков. Mutants additionally pick one starting talent of `kind: stigma` from the catalog (any of the three stigmas) through the regular `addTalent` endpoint. Mutable while `status: draft` and immutable once `active` — `MUTANT_IMMUTABLE`. When `true`, `mutantLineage` must be set; when `false`, `mutantLineage` must be `null`.  | [default to false]
**mutantLineage** | [**MutantLineage**](MutantLineage.md) |  | 
**attributes** | [**Attributes**](Attributes.md) |  | 
**skills** | [**Skills**](Skills.md) |  | 
**hp** | [**CharacterHp**](CharacterHp.md) |  | 
**mp** | [**CharacterMp**](CharacterMp.md) |  | 
**encumbrance** | [**CharacterEncumbrance**](CharacterEncumbrance.md) |  | 
**experience** | **int** | Total XP earned | 
**conditions** | [**ConditionFlags**](ConditionFlags.md) |  | 
**criticalInjuries** | [**BuiltList&lt;CriticalInjury&gt;**](CriticalInjury.md) |  | 
**talents** | [**BuiltList&lt;Talent&gt;**](Talent.md) |  | 
**relationships** | [**BuiltList&lt;Relationship&gt;**](Relationship.md) |  | 
**inventory** | [**BuiltList&lt;Item&gt;**](Item.md) |  | 
**notes** | **String** | Free-form notes (Markdown; soft cap 4096 characters) | 
**status** | **String** | Lifecycle state of the character.  - `draft` — character is a work-in-progress created by the wizard.   Draft characters are excluded from the default character list   (`GET /api/v1/characters`) unless `?includeDrafts=true` is passed. - `active` — character is complete and visible on the dashboard.  Transitioning from `draft` to `active` (forging) is done by sending `PATCH /api/v1/characters/{id}` with `{ \"status\": \"active\" }`. The reverse transition (`active → draft`) is rejected with 422 `INVALID_STATUS_TRANSITION`.  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


