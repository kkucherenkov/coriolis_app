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
**initiative** | **int** | Per-weapon initiative modifier added to the d6 initiative roll when the wielder uses this weapon (ST3001 ГЛАВА 6 «Инициатива» column on each weapon table; ГЛАВА 5 §«Раунды, ходы и инициатива» — «Некоторые виды оружия могут временно повысить значение твоей инициативы. Воспользовавшись этим преимуществом, ты обязан атаковать оружием, которое его обеспечивает»). Canonical printed values in ГЛАВА 6 are 0..+2; the broader −5..+5 envelope leaves room for GM-defined exotics and house-rule penalties without needing a spec bump. Defaults to 0 — most weapons don't carry an initiative bonus.  | [optional] [default to 0]
**armorRating** | **int** | Armor rating — reduces incoming damage | 
**extraSlotCount** | **int** | Extra encumbrance slots this armor grants its wearer when equipped (ST3001 ТАБЛИЦА 6.14 «Дополнительные свойства» column). The wearer's encumbrance limit becomes `STR × 2 + sum(equipped armor extraSlotCount)` per the rules-engine. Canonical values from the printed table: most armors 0; Тяжёлый экзоскафандр / Лёгкая броня / Тяжёлая броня 1; Экзодоспех 2; Тяжёлый экзодоспех 5. The 0..6 envelope leaves one point of headroom for GM-defined exotics. Stacks across multiple equipped pieces (e.g. armour + tactical shield), but only when each piece carries the property — most shields are 0.  | [optional] [default to 0]
**quantity** | **int** | Number of units | 
**notes** | **String** | Optional free-text notes | [optional] 
**xpCost** | **int** | XP spent to acquire this cybernetic implant. Cybernetics count as both equipment and talents (ST3001 ГЛАВА 6 «КИБЕРНЕТИЧЕСКИЕ ИМПЛАНТАТЫ»: «считается и снаряжением, и достоинством, так что на его покупку тебе понадобятся не только бирры, но и пункты опыта»). The canonical acquisition cost is 5 XP per ГЛАВА 4 «Новые достоинства» («Накопив 5 пунктов опыта, персонаж получает возможность обменять их на любое новое достоинство»); the field accepts 0..15 to allow GM concessions (0 for in-game gifts) and high-rank exotics (up to 3 ranks × 5 XP). The implant's birr price lives in the regular `cost` (or wherever ItemBase carries item value) — XP is tracked separately because it draws from the character's XP pool, not their wallet.  | 
**effect** | **String** | Description of the module's effect and energy use | 
**slot** | [**ShipModuleSlot**](ShipModuleSlot.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


