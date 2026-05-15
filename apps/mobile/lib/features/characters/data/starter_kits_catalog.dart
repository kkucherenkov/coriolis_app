/// Coriolis ST3001 — starter-kit catalogue (Dart hand-port).
///
/// Single source of truth for wizard Step 8 (Gear) picker on mobile.
/// Ported verbatim from `packages/specs/src/starter-kits.ts`.
///
/// ## Wire contract
///
/// `Item.name` is locale-invariant: the wizard POSTs the **EN** name to
/// the backend. `pickStarterKitItemName` is for display only.
///
/// ## Catalogue shape
///
/// 33 entries — 11 amplua × 3 roles each. All three roles within an
/// amplua share the same gear table (ST3001 ch.2 СНАРЯЖЕНИЕ tables).
/// Every kit has `fixed: []` and `choices` of length 5, each choice
/// has exactly 2 options.
library;

import 'package:collection/collection.dart';

// ── Value types ─────────────────────────────────────────────────────────────

enum StarterKitItemKind { weapon, armor, gear, cybernetic, other }

class StarterKitItemTemplate {
  const StarterKitItemTemplate({required this.kind, required this.name});

  final StarterKitItemKind kind;

  /// Localised display names keyed by locale code (`'en'|'ru'|'uk'|'el'`).
  final Map<String, String> name;
}

class StarterKitItem {
  const StarterKitItem({required this.id, required this.template});

  /// Stable kebab-case id — matches the TS source id verbatim.
  final String id;
  final StarterKitItemTemplate template;
}

class StarterKitChoice {
  const StarterKitChoice({
    required this.id,
    required this.label,
    required this.options,
    this.pickCount = 1,
  });

  final String id;
  final Map<String, String> label;
  final List<StarterKitItem> options;
  final int pickCount;
}

class StarterKit {
  const StarterKit({
    required this.concept,
    required this.role,
    required this.fixed,
    required this.choices,
  });

  final String concept;
  final String role;
  final List<StarterKitItem> fixed;
  final List<StarterKitChoice> choices;
}

// ── Amplua kit templates (ST3001 ГЛАВА 2 СНАРЯЖЕНИЕ tables) ─────────────────

const _kitArtist = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'alam-fan',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Hand fan of Alam', 'ru': 'Веер Алама', 'uk': '[uk-todo] Hand fan of Alam', 'el': '[el-todo] Hand fan of Alam'},
          ),
        ),
        StarterKitItem(
          id: 'tabula',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tabula', 'ru': 'Табула', 'uk': '[uk-todo] Tabula', 'el': '[el-todo] Tabula'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'opor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Opor', 'ru': 'Опор', 'uk': '[uk-todo] Opor', 'el': '[el-todo] Opor'},
          ),
        ),
        StarterKitItem(
          id: 'sensor-analyzer',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Sensor analyzer', 'ru': 'Сенсорный анализатор', 'uk': '[uk-todo] Sensor analyzer', 'el': '[el-todo] Sensor analyzer'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'luxury-outfit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Luxury outfit', 'ru': 'Роскошный наряд', 'uk': '[uk-todo] Luxury outfit', 'el': '[el-todo] Luxury outfit'},
          ),
        ),
        StarterKitItem(
          id: 'musical-instrument',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Musical instrument', 'ru': 'Музыкальный инструмент', 'uk': '[uk-todo] Musical instrument', 'el': '[el-todo] Musical instrument'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'beautiful-appearance-biomod',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Beautiful appearance (biomod)', 'ru': 'Прекрасная внешность (мод.)', 'uk': '[uk-todo] Beautiful appearance (biomod)', 'el': '[el-todo] Beautiful appearance (biomod)'},
          ),
        ),
        StarterKitItem(
          id: 'rare-poetry-collection',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Collection of rare poetry', 'ru': 'Сборник редких стихов', 'uk': '[uk-todo] Collection of rare poetry', 'el': '[el-todo] Collection of rare poetry'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'memoirs-meizelmann',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': '"Memoirs" by Meizelmann', 'ru': '«Мемуары» Мейзельмана', 'uk': '[uk-todo] "Memoirs" by Meizelmann', 'el': '[el-todo] "Memoirs" by Meizelmann'},
          ),
        ),
        StarterKitItem(
          id: 'alkamaar-restaurant-card',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Regular customer card at Alkamaar restaurant', 'ru': 'Карта постоянного клиента ресторана «Алькамаар»', 'uk': '[uk-todo] Regular customer card at Alkamaar restaurant', 'el': '[el-todo] Regular customer card at Alkamaar restaurant'},
          ),
        ),
      ],
    ),
  ],
);

const _kitNetworker = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'comlink-iv',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (IV)', 'ru': 'Коммуникатор (IV)', 'uk': '[uk-todo] Comlink (IV)', 'el': '[el-todo] Comlink (IV)'},
          ),
        ),
        StarterKitItem(
          id: 'holograph-i',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Holograph (I)', 'ru': 'Голограф (I)', 'uk': '[uk-todo] Holograph (I)', 'el': '[el-todo] Holograph (I)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'broadband-sensor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Broadband sensor', 'ru': 'Широкополосный сенсор', 'uk': '[uk-todo] Broadband sensor', 'el': '[el-todo] Broadband sensor'},
          ),
        ),
        StarterKitItem(
          id: 'computer-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Computer (S)', 'ru': 'Компьютер (С)', 'uk': '[uk-todo] Computer (S)', 'el': '[el-todo] Computer (S)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'pocket-vulcan-pistol',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Pocket Vulcan pistol', 'ru': 'Карманный вулкан-пистолет', 'uk': '[uk-todo] Pocket Vulcan pistol', 'el': '[el-todo] Pocket Vulcan pistol'},
          ),
        ),
        StarterKitItem(
          id: 'neuroshock-stun',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Neuroshocker', 'ru': 'Нейрошокер', 'uk': '[uk-todo] Neuroshocker', 'el': '[el-todo] Neuroshocker'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'tabula',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tabula', 'ru': 'Табула', 'uk': '[uk-todo] Tabula', 'el': '[el-todo] Tabula'},
          ),
        ),
        StarterKitItem(
          id: 'transactor-1000-birr',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Transactor with 1000 birr', 'ru': 'Транзактор с 1000 бирров на счету', 'uk': '[uk-todo] Transactor with 1000 birr', 'el': '[el-todo] Transactor with 1000 birr'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'opor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Opor', 'ru': 'Опор', 'uk': '[uk-todo] Opor', 'el': '[el-todo] Opor'},
          ),
        ),
        StarterKitItem(
          id: 'arrash',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Arrash', 'ru': 'Арраш', 'uk': '[uk-todo] Arrash', 'el': '[el-todo] Arrash'},
          ),
        ),
      ],
    ),
  ],
);

const _kitFugitive = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'anonymous-clothing',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Anonymous clothing', 'ru': 'Обезличивающая одежда', 'uk': '[uk-todo] Anonymous clothing', 'el': '[el-todo] Anonymous clothing'},
          ),
        ),
        StarterKitItem(
          id: 'birr-chip-500',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Birr-chip with 500 birr', 'ru': 'Бирка с 500 бирров', 'uk': '[uk-todo] Birr-chip with 500 birr', 'el': '[el-todo] Birr-chip with 500 birr'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'comlink-ii',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (II)', 'ru': 'Коммуникатор (II)', 'uk': '[uk-todo] Comlink (II)', 'el': '[el-todo] Comlink (II)'},
          ),
        ),
        StarterKitItem(
          id: 'protective-clothing',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Protective clothing', 'ru': 'Защитная одежда', 'uk': '[uk-todo] Protective clothing', 'el': '[el-todo] Protective clothing'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'vulcan-carbine',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vulcan carbine', 'ru': 'Вулкан-карабин', 'uk': '[uk-todo] Vulcan carbine', 'el': '[el-todo] Vulcan carbine'},
          ),
        ),
        StarterKitItem(
          id: 'vibro-sword',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vibro sword', 'ru': 'Вибромеч', 'uk': '[uk-todo] Vibro sword', 'el': '[el-todo] Vibro sword'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'thermal-suit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Thermal suit', 'ru': 'Термостатический комбинезон', 'uk': '[uk-todo] Thermal suit', 'el': '[el-todo] Thermal suit'},
          ),
        ),
        StarterKitItem(
          id: 'vacsuit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Vacsuit', 'ru': 'Экзоскафандр', 'uk': '[uk-todo] Vacsuit', 'el': '[el-todo] Vacsuit'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'transactor-fake-id',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Transactor with forged ID', 'ru': 'Транзактор с фальшивым удостоверением личности', 'uk': '[uk-todo] Transactor with forged ID', 'el': '[el-todo] Transactor with forged ID'},
          ),
        ),
        StarterKitItem(
          id: 'mask',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Mask', 'ru': 'Маска', 'uk': '[uk-todo] Mask', 'el': '[el-todo] Mask'},
          ),
        ),
      ],
    ),
  ],
);

const _kitNegotiator = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'tabula',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tabula', 'ru': 'Табула', 'uk': '[uk-todo] Tabula', 'el': '[el-todo] Tabula'},
          ),
        ),
        StarterKitItem(
          id: 'interpreter-implant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Interpreter (implant)', 'ru': 'Интерпретатор (имп.)', 'uk': '[uk-todo] Interpreter (implant)', 'el': '[el-todo] Interpreter (implant)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'comlink-v',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (V)', 'ru': 'Коммуникатор (V)', 'uk': '[uk-todo] Comlink (V)', 'el': '[el-todo] Comlink (V)'},
          ),
        ),
        StarterKitItem(
          id: 'megaphone',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Megaphone', 'ru': 'Громкоговоритель', 'uk': '[uk-todo] Megaphone', 'el': '[el-todo] Megaphone'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'luxury-outfit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Luxury outfit', 'ru': 'Роскошный наряд', 'uk': '[uk-todo] Luxury outfit', 'el': '[el-todo] Luxury outfit'},
          ),
        ),
        StarterKitItem(
          id: 'kamra-d6-doses',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Kamra (d6 doses)', 'ru': 'Камбра (d6 доз)', 'uk': '[uk-todo] Kamra (d6 doses)', 'el': '[el-todo] Kamra (d6 doses)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'lie-detector-implant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Lie detector (implant)', 'ru': 'Детектор лжи (имп.)', 'uk': '[uk-todo] Lie detector (implant)', 'el': '[el-todo] Lie detector (implant)'},
          ),
        ),
        StarterKitItem(
          id: 'auto-translator',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Auto-translator', 'ru': 'Автоматический переводчик', 'uk': '[uk-todo] Auto-translator', 'el': '[el-todo] Auto-translator'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'pocket-vulcan-pistol',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Pocket Vulcan pistol', 'ru': 'Карманный вулкан-пистолет', 'uk': '[uk-todo] Pocket Vulcan pistol', 'el': '[el-todo] Pocket Vulcan pistol'},
          ),
        ),
        StarterKitItem(
          id: 'mercury-knife',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Mercury knife', 'ru': 'Ртутный нож', 'uk': '[uk-todo] Mercury knife', 'el': '[el-todo] Mercury knife'},
          ),
        ),
      ],
    ),
  ],
);

const _kitOperative = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'pocket-vulcan-pistol',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Pocket Vulcan pistol', 'ru': 'Карманный вулкан-пистолет', 'uk': '[uk-todo] Pocket Vulcan pistol', 'el': '[el-todo] Pocket Vulcan pistol'},
          ),
        ),
        StarterKitItem(
          id: 'advanced-melee-weapon',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Advanced melee weapon', 'ru': 'Передовое оружие ближнего боя', 'uk': '[uk-todo] Advanced melee weapon', 'el': '[el-todo] Advanced melee weapon'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'broadband-sensor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Broadband sensor', 'ru': 'Широкополосный сенсор', 'uk': '[uk-todo] Broadband sensor', 'el': '[el-todo] Broadband sensor'},
          ),
        ),
        StarterKitItem(
          id: 'computer-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Computer (S)', 'ru': 'Компьютер (С)', 'uk': '[uk-todo] Computer (S)', 'el': '[el-todo] Computer (S)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'modulating-mask',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Modulating mask', 'ru': 'Модулирующая маска', 'uk': '[uk-todo] Modulating mask', 'el': '[el-todo] Modulating mask'},
          ),
        ),
        StarterKitItem(
          id: 'mechanical-lockpick',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Mechanical lockpick', 'ru': 'Механическая отмычка', 'uk': '[uk-todo] Mechanical lockpick', 'el': '[el-todo] Mechanical lockpick'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'recon-probe',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Recon probe', 'ru': 'Разведзонд', 'uk': '[uk-todo] Recon probe', 'el': '[el-todo] Recon probe'},
          ),
        ),
        StarterKitItem(
          id: 'fake-id-set',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Set of forged IDs', 'ru': 'Набор фальшивых удостоверений личности', 'uk': '[uk-todo] Set of forged IDs', 'el': '[el-todo] Set of forged IDs'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'electronic-lockpick',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Electronic lockpick', 'ru': 'Электронная отмычка', 'uk': '[uk-todo] Electronic lockpick', 'el': '[el-todo] Electronic lockpick'},
          ),
        ),
        StarterKitItem(
          id: 'poison-5-doses',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Poison (5 doses)', 'ru': 'Яд (5 доз)', 'uk': '[uk-todo] Poison (5 doses)', 'el': '[el-todo] Poison (5 doses)'},
          ),
        ),
      ],
    ),
  ],
);

const _kitPilot = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'tool-kit-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tool kit (S)', 'ru': 'Набор инструментов (С)', 'uk': '[uk-todo] Tool kit (S)', 'el': '[el-todo] Tool kit (S)'},
          ),
        ),
        StarterKitItem(
          id: 'piloting-talisman',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Piloting talisman', 'ru': 'Талисман пилотирования', 'uk': '[uk-todo] Piloting talisman', 'el': '[el-todo] Piloting talisman'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'vacsuit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Vacsuit', 'ru': 'Экзоскафандр', 'uk': '[uk-todo] Vacsuit', 'el': '[el-todo] Vacsuit'},
          ),
        ),
        StarterKitItem(
          id: 'manual-maneuvering-unit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Manual maneuvering unit', 'ru': 'Ручной маневровый двигатель', 'uk': '[uk-todo] Manual maneuvering unit', 'el': '[el-todo] Manual maneuvering unit'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'targeting-reticle-implant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Targeting reticle (implant)', 'ru': 'Целеуказатель (имп.)', 'uk': '[uk-todo] Targeting reticle (implant)', 'el': '[el-todo] Targeting reticle (implant)'},
          ),
        ),
        StarterKitItem(
          id: 'comlink-iv',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (IV)', 'ru': 'Коммуникатор (IV)', 'uk': '[uk-todo] Comlink (IV)', 'el': '[el-todo] Comlink (IV)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'rail-pistol',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Rail pistol', 'ru': 'Рельсовый пистолет', 'uk': '[uk-todo] Rail pistol', 'el': '[el-todo] Rail pistol'},
          ),
        ),
        StarterKitItem(
          id: 'neuroshock-stun',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Neuroshocker', 'ru': 'Нейрошокер', 'uk': '[uk-todo] Neuroshocker', 'el': '[el-todo] Neuroshocker'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'flight-suit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Flight suit', 'ru': 'Лётный комбинезон', 'uk': '[uk-todo] Flight suit', 'el': '[el-todo] Flight suit'},
          ),
        ),
        StarterKitItem(
          id: 'luxury-outfit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Luxury outfit', 'ru': 'Роскошный наряд', 'uk': '[uk-todo] Luxury outfit', 'el': '[el-todo] Luxury outfit'},
          ),
        ),
      ],
    ),
  ],
);

const _kitPreacher = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'holy-scriptures',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Holy scriptures', 'ru': 'Священные писания', 'uk': '[uk-todo] Holy scriptures', 'el': '[el-todo] Holy scriptures'},
          ),
        ),
        StarterKitItem(
          id: 'censer',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Censer', 'ru': 'Кадило', 'uk': '[uk-todo] Censer', 'el': '[el-todo] Censer'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'talisman-any',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Talisman (any)', 'ru': 'Талисман (любой)', 'uk': '[uk-todo] Talisman (any)', 'el': '[el-todo] Talisman (any)'},
          ),
        ),
        StarterKitItem(
          id: 'ritual-robes',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Ritual robes', 'ru': 'Ритуальное облачение', 'uk': '[uk-todo] Ritual robes', 'el': '[el-todo] Ritual robes'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'reliquary',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Reliquary', 'ru': 'Реликварий', 'uk': '[uk-todo] Reliquary', 'el': '[el-todo] Reliquary'},
          ),
        ),
        StarterKitItem(
          id: 'prophecy-scrolls',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Prophecy scrolls', 'ru': 'Рукописи с пророчествами', 'uk': '[uk-todo] Prophecy scrolls', 'el': '[el-todo] Prophecy scrolls'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'm-stims-5',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': '5 Medi-stims', 'ru': '5 м-стимов', 'uk': '[uk-todo] 5 Medi-stims', 'el': '[el-todo] 5 Medi-stims'},
          ),
        ),
        StarterKitItem(
          id: 'blessed-herbs-10',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': '10 doses of blessed healing herbs', 'ru': '10 порций освящённых целебных трав', 'uk': '[uk-todo] 10 doses of blessed healing herbs', 'el': '[el-todo] 10 doses of blessed healing herbs'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'tabula',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tabula', 'ru': 'Табула', 'uk': '[uk-todo] Tabula', 'el': '[el-todo] Tabula'},
          ),
        ),
        StarterKitItem(
          id: 'writing-kit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Writing kit', 'ru': 'Писчие принадлежности', 'uk': '[uk-todo] Writing kit', 'el': '[el-todo] Writing kit'},
          ),
        ),
      ],
    ),
  ],
);

const _kitScientist = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'comlink-iii',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (III)', 'ru': 'Коммуникатор (III)', 'uk': '[uk-todo] Comlink (III)', 'el': '[el-todo] Comlink (III)'},
          ),
        ),
        StarterKitItem(
          id: 'broadband-sensor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Broadband sensor', 'ru': 'Широкополосный сенсор', 'uk': '[uk-todo] Broadband sensor', 'el': '[el-todo] Broadband sensor'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'portable-lab',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Portable lab', 'ru': 'Портативная лаборатория', 'uk': '[uk-todo] Portable lab', 'el': '[el-todo] Portable lab'},
          ),
        ),
        StarterKitItem(
          id: 'computer-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Computer (S)', 'ru': 'Компьютер (С)', 'uk': '[uk-todo] Computer (S)', 'el': '[el-todo] Computer (S)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'vacsuit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Vacsuit', 'ru': 'Экзоскафандр', 'uk': '[uk-todo] Vacsuit', 'el': '[el-todo] Vacsuit'},
          ),
        ),
        StarterKitItem(
          id: 'data-library',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Data library', 'ru': 'Электронная библиотека', 'uk': '[uk-todo] Data library', 'el': '[el-todo] Data library'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'pressure-tent',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Pressure tent', 'ru': 'Герметичный шатёр', 'uk': '[uk-todo] Pressure tent', 'el': '[el-todo] Pressure tent'},
          ),
        ),
        StarterKitItem(
          id: 'med-kit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Med-kit', 'ru': 'М-комплект', 'uk': '[uk-todo] Med-kit', 'el': '[el-todo] Med-kit'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'tool-kit-p',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tool kit (P)', 'ru': 'Набор инструментов (П)', 'uk': '[uk-todo] Tool kit (P)', 'el': '[el-todo] Tool kit (P)'},
          ),
        ),
        StarterKitItem(
          id: 'compass',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Compass', 'ru': 'Компас', 'uk': '[uk-todo] Compass', 'el': '[el-todo] Compass'},
          ),
        ),
      ],
    ),
  ],
);

const _kitSailor = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'tool-kit-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tool kit (S)', 'ru': 'Набор инструментов (С)', 'uk': '[uk-todo] Tool kit (S)', 'el': '[el-todo] Tool kit (S)'},
          ),
        ),
        StarterKitItem(
          id: 'sealant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Sealant', 'ru': 'Герметик', 'uk': '[uk-todo] Sealant', 'el': '[el-todo] Sealant'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'power-knuckles',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Power knuckles', 'ru': 'Силовой кастет', 'uk': '[uk-todo] Power knuckles', 'el': '[el-todo] Power knuckles'},
          ),
        ),
        StarterKitItem(
          id: 'sensor-analyzer',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Sensor analyzer', 'ru': 'Сенсорный анализатор', 'uk': '[uk-todo] Sensor analyzer', 'el': '[el-todo] Sensor analyzer'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'arrash',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Arrash', 'ru': 'Арраш', 'uk': '[uk-todo] Arrash', 'el': '[el-todo] Arrash'},
          ),
        ),
        StarterKitItem(
          id: 'tobacco',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Tobacco', 'ru': 'Табак', 'uk': '[uk-todo] Tobacco', 'el': '[el-todo] Tobacco'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'exo-loader',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Exo-loader', 'ru': 'Экзопогрузчик', 'uk': '[uk-todo] Exo-loader', 'el': '[el-todo] Exo-loader'},
          ),
        ),
        StarterKitItem(
          id: 'vacsuit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Vacsuit', 'ru': 'Экзоскафандр', 'uk': '[uk-todo] Vacsuit', 'el': '[el-todo] Vacsuit'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'hyper-cable',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Hyper-cable', 'ru': 'Гипертрос', 'uk': '[uk-todo] Hyper-cable', 'el': '[el-todo] Hyper-cable'},
          ),
        ),
        StarterKitItem(
          id: 'vibro-knife',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vibro knife', 'ru': 'Вибронож', 'uk': '[uk-todo] Vibro knife', 'el': '[el-todo] Vibro knife'},
          ),
        ),
      ],
    ),
  ],
);

const _kitSoldier = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'heavy-armor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Heavy armor', 'ru': 'Тяжёлая броня', 'uk': '[uk-todo] Heavy armor', 'el': '[el-todo] Heavy armor'},
          ),
        ),
        StarterKitItem(
          id: 'mercury-sword',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Mercury sword', 'ru': 'Ртутный меч', 'uk': '[uk-todo] Mercury sword', 'el': '[el-todo] Mercury sword'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'rail-pistol-sensor-sight-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Rail pistol with sensor sight (S)', 'ru': 'Рельсовый пистолет с сенсорным прицелом (С)', 'uk': '[uk-todo] Rail pistol with sensor sight (S)', 'el': '[el-todo] Rail pistol with sensor sight (S)'},
          ),
        ),
        StarterKitItem(
          id: 'vulcan-carbine',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vulcan carbine', 'ru': 'Вулкан-карабин', 'uk': '[uk-todo] Vulcan carbine', 'el': '[el-todo] Vulcan carbine'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'frag-grenade',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Frag grenade', 'ru': 'Осколочная граната', 'uk': '[uk-todo] Frag grenade', 'el': '[el-todo] Frag grenade'},
          ),
        ),
        StarterKitItem(
          id: 'reinforced-muscles-implant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Reinforced muscles (implant)', 'ru': 'Усиленные мышцы (имп.)', 'uk': '[uk-todo] Reinforced muscles (implant)', 'el': '[el-todo] Reinforced muscles (implant)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'officer-pad',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Officer pad', 'ru': 'Командирский планшет', 'uk': '[uk-todo] Officer pad', 'el': '[el-todo] Officer pad'},
          ),
        ),
        StarterKitItem(
          id: 'sensor-sight-p',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Sensor sight (P)', 'ru': 'Сенсорный прицел (П)', 'uk': '[uk-todo] Sensor sight (P)', 'el': '[el-todo] Sensor sight (P)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'comlink-ii',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (II)', 'ru': 'Коммуникатор (II)', 'uk': '[uk-todo] Comlink (II)', 'el': '[el-todo] Comlink (II)'},
          ),
        ),
        StarterKitItem(
          id: 'med-kit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Med-kit', 'ru': 'М-комплект', 'uk': '[uk-todo] Med-kit', 'el': '[el-todo] Med-kit'},
          ),
        ),
      ],
    ),
  ],
);

const _kitPioneer = _AmpluaKit(
  fixed: [],
  choices: [
    StarterKitChoice(
      id: 'row-1',
      label: {'en': 'Row 1', 'ru': 'Ряд 1', 'uk': '[uk-todo] Row 1', 'el': '[el-todo] Row 1'},
      options: [
        StarterKitItem(
          id: 'drone-uav',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'UAV drone', 'ru': 'БПЛА', 'uk': '[uk-todo] UAV drone', 'el': '[el-todo] UAV drone'},
          ),
        ),
        StarterKitItem(
          id: 'comlink-v',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (V)', 'ru': 'Коммуникатор (V)', 'uk': '[uk-todo] Comlink (V)', 'el': '[el-todo] Comlink (V)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2', 'uk': '[uk-todo] Row 2', 'el': '[el-todo] Row 2'},
      options: [
        StarterKitItem(
          id: 'vibro-axe',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vibro axe', 'ru': 'Вибросекира', 'uk': '[uk-todo] Vibro axe', 'el': '[el-todo] Vibro axe'},
          ),
        ),
        StarterKitItem(
          id: 'vulcan-carbine',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vulcan carbine', 'ru': 'Вулкан-карабин', 'uk': '[uk-todo] Vulcan carbine', 'el': '[el-todo] Vulcan carbine'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3', 'uk': '[uk-todo] Row 3', 'el': '[el-todo] Row 3'},
      options: [
        StarterKitItem(
          id: 'm-stims-5',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': '5 Medi-stims', 'ru': '5 м-стимов', 'uk': '[uk-todo] 5 Medi-stims', 'el': '[el-todo] 5 Medi-stims'},
          ),
        ),
        StarterKitItem(
          id: 'data-library',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Data library', 'ru': 'Электронная библиотека', 'uk': '[uk-todo] Data library', 'el': '[el-todo] Data library'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4', 'uk': '[uk-todo] Row 4', 'el': '[el-todo] Row 4'},
      options: [
        StarterKitItem(
          id: 'optimized-metabolism-implant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Optimized metabolism (implant)', 'ru': 'Оптимизированный метаболизм (имп.)', 'uk': '[uk-todo] Optimized metabolism (implant)', 'el': '[el-todo] Optimized metabolism (implant)'},
          ),
        ),
        StarterKitItem(
          id: 'vacsuit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Vacsuit', 'ru': 'Экзоскафандр', 'uk': '[uk-todo] Vacsuit', 'el': '[el-todo] Vacsuit'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5', 'uk': '[uk-todo] Row 5', 'el': '[el-todo] Row 5'},
      options: [
        StarterKitItem(
          id: 'sensor-analyzer',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Sensor analyzer', 'ru': 'Сенсорный анализатор', 'uk': '[uk-todo] Sensor analyzer', 'el': '[el-todo] Sensor analyzer'},
          ),
        ),
        StarterKitItem(
          id: 'compass',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Compass', 'ru': 'Компас', 'uk': '[uk-todo] Compass', 'el': '[el-todo] Compass'},
          ),
        ),
      ],
    ),
  ],
);

// ── Internal amplua-kit container ────────────────────────────────────────────

class _AmpluaKit {
  const _AmpluaKit({required this.fixed, required this.choices});

  final List<StarterKitItem> fixed;
  final List<StarterKitChoice> choices;
}

// ── (concept × role) expansion → 33 StarterKit entries ──────────────────────

List<StarterKit> _expandKits() {
  const ampluae = [
    (concept: 'artist', roles: ['companion', 'musician', 'poet'], kit: _kitArtist),
    (concept: 'networker', roles: ['analyst', 'correspondent', 'network-djinn'], kit: _kitNetworker),
    (concept: 'fugitive', roles: ['criminal', 'mystic', 'revolutionary'], kit: _kitFugitive),
    (concept: 'negotiator', roles: ['agitator', 'diplomat', 'dealer'], kit: _kitNegotiator),
    (concept: 'operative', roles: ['assassin', 'guard', 'spy'], kit: _kitOperative),
    (concept: 'pilot', roles: ['ace', 'driver', 'trucker'], kit: _kitPilot),
    (concept: 'pioneer', roles: ['colonist', 'prospector', 'scout'], kit: _kitPioneer),
    (concept: 'preacher', roles: ['ascetic', 'missionary', 'prophet'], kit: _kitPreacher),
    (concept: 'scientist', roles: ['archaeologist', 'medicurg', 'technologist'], kit: _kitScientist),
    (concept: 'sailor', roles: ['ship-engineer', 'labourer', 'loader'], kit: _kitSailor),
    (concept: 'soldier', roles: ['legionnaire', 'mercenary', 'officer'], kit: _kitSoldier),
  ];

  final out = <StarterKit>[];
  for (final a in ampluae) {
    for (final role in a.roles) {
      out.add(StarterKit(
        concept: a.concept,
        role: role,
        fixed: a.kit.fixed,
        choices: a.kit.choices,
      ));
    }
  }
  return out;
}

/// Complete starter-kit catalogue — 33 entries (11 amplua × 3 roles).
final List<StarterKit> kStarterKitCatalog = List.unmodifiable(_expandKits());

/// Returns the starter kit for [concept] + [role], or `null` if not found.
StarterKit? findStarterKit(String concept, String role) =>
    kStarterKitCatalog.firstWhereOrNull(
      (k) => k.concept == concept && k.role == role,
    );

/// Resolves the display name of [item] for [locale], falling back to `'en'`.
///
/// Display only — do NOT use for the wire request body; post the EN name.
String pickStarterKitItemName(StarterKitItem item, String locale) =>
    item.template.name[locale] ?? item.template.name['en']!;
