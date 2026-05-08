# app_api_client.model.Ship

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque ship identifier (cuid2) | 
**ownerId** | **String** | Identifier of the owning user (cuid2) | 
**name** | **String** | Ship name (1–80 characters) | 
**class_** | [**ShipClass**](ShipClass.md) |  | 
**model** | **String** | Model / shipyard name (e.g. \"Helebian Class III freighter\") | 
**registry** | **String** | Registry number / transponder code (e.g. \"KUA-7741-M\") | 
**hull** | [**ShipHull**](ShipHull.md) |  | 
**energy** | [**ShipEnergy**](ShipEnergy.md) |  | 
**armor** | **int** | Armor rating — number of dice rolled for the armor check (Броня) | 
**maneuverability** | **int** | Maneuverability modifier (Манёвренность). Signed integer — negative for large classes (Class IV is −1, Class V is −2). Affects pilot skill checks in ship combat per ST3001 ГЛАВА 7.  | 
**signature** | **int** | Signature modifier (Заметность). Signed integer. Negative values mean the ship is harder to detect; positive values mean it is more visible. Applied to opponent sensor checks per ГЛАВА 7.  | 
**speed** | **int** | Speed in astronomical units per day (Скорость per ГЛАВА 7 Table 7.5) | 
**cargoCapacity** | **int** | Total cargo capacity in tonnes across all hold modules (Вместимость per ГЛАВА 7 Table 7.6: Class III = 50 tonnes).  | 
**modules** | [**BuiltList&lt;ShipModule&gt;**](ShipModule.md) | Installed modules including the three mandatory ones (BRIDGE, REACTOR, DRIVE). Optional modules consume the class module-slot budget.  | 
**crew** | [**BuiltList&lt;CrewSlot&gt;**](CrewSlot.md) | Crew assignment roster | 
**problems** | **BuiltList&lt;String&gt;** | List of active ship problems (free-text entries, e.g. damage effects or wear-and-tear notes per ГЛАВА 7 wear table).  | 
**history** | **String** | Free-form ship history / background text (Markdown) | 
**notes** | **String** | GM / player operational notes (Markdown) | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


