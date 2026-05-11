# app_api_client.model.ItemArmor

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
**armorRating** | **int** | Armor rating — reduces incoming damage | 
**weight** | **num** | Encumbrance weight in slots | 
**features** | **BuiltList&lt;String&gt;** | Feature tags (e.g. \"Vacuum Sealed\", \"Exo-Skeleton\") | 
**equipped** | **bool** |  | 
**extraSlotCount** | **int** | Extra encumbrance slots this armor grants its wearer when equipped (ST3001 ТАБЛИЦА 6.14 «Дополнительные свойства» column). The wearer's encumbrance limit becomes `STR × 2 + sum(equipped armor extraSlotCount)` per the rules-engine. Canonical values from the printed table: most armors 0; Тяжёлый экзоскафандр / Лёгкая броня / Тяжёлая броня 1; Экзодоспех 2; Тяжёлый экзодоспех 5. The 0..6 envelope leaves one point of headroom for GM-defined exotics. Stacks across multiple equipped pieces (e.g. armour + tactical shield), but only when each piece carries the property — most shields are 0.  | [optional] [default to 0]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


