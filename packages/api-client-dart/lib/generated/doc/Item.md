# app_api_client.model.Item

## Load the model package
```dart
import 'package:app_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Opaque identifier (cuid2) | 
**type** | **String** |  | 
**name** | **String** | Item name | 
**damage** | **int** | Base damage dice | 
**range** | [**ItemRangeEnum**](ItemRangeEnum.md) |  | 
**bonus** | **int** | Bonus dice added to the attack pool | 
**crit** | **int** | Critical threshold (roll this many successes to crit) | 
**weight** | **num** | Encumbrance weight in slots | 
**features** | **BuiltList&lt;String&gt;** | Feature tags (e.g. \"Vacuum Sealed\", \"Exo-Skeleton\") | 
**equipped** | **bool** |  | 
**armorRating** | **int** | Armor rating — reduces incoming damage | 
**quantity** | **int** | Number of units | 
**notes** | **String** | Optional free-text notes | [optional] 
**xpCost** | **int** | XP spent to acquire this cybernetic implant. Cybernetics count as both equipment and talents (ST3001 ГЛАВА 6 «КИБЕРНЕТИЧЕСКИЕ ИМПЛАНТАТЫ»: «считается и снаряжением, и достоинством, так что на его покупку тебе понадобятся не только бирры, но и пункты опыта»). The canonical acquisition cost is 5 XP per ГЛАВА 4 «Новые достоинства» («Накопив 5 пунктов опыта, персонаж получает возможность обменять их на любое новое достоинство»); the field accepts 0..15 to allow GM concessions (0 for in-game gifts) and high-rank exotics (up to 3 ranks × 5 XP). The implant's birr price lives in the regular `cost` (or wherever ItemBase carries item value) — XP is tracked separately because it draws from the character's XP pool, not their wallet.  | 
**effect** | **String** | Description of the module's effect and energy use | 
**slot** | [**ItemSlotType**](ItemSlotType.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


