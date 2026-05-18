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

  /// Localised display names keyed by locale code (`'en'|'ru'`).
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'alam-fan',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Hand fan of Alam', 'ru': 'Веер Алама'},
          ),
        ),
        StarterKitItem(
          id: 'tabula',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tabula', 'ru': 'Табула'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'opor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Opor', 'ru': 'Опор'},
          ),
        ),
        StarterKitItem(
          id: 'sensor-analyzer',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Sensor analyzer', 'ru': 'Сенсорный анализатор'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'luxury-outfit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Luxury outfit', 'ru': 'Роскошный наряд'},
          ),
        ),
        StarterKitItem(
          id: 'musical-instrument',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Musical instrument', 'ru': 'Музыкальный инструмент'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'beautiful-appearance-biomod',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Beautiful appearance (biomod)', 'ru': 'Прекрасная внешность (мод.)'},
          ),
        ),
        StarterKitItem(
          id: 'rare-poetry-collection',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Collection of rare poetry', 'ru': 'Сборник редких стихов'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'memoirs-meizelmann',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': '"Memoirs" by Meizelmann', 'ru': '«Мемуары» Мейзельмана'},
          ),
        ),
        StarterKitItem(
          id: 'alkamaar-restaurant-card',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Regular customer card at Alkamaar restaurant', 'ru': 'Карта постоянного клиента ресторана «Алькамаар»'},
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'comlink-iv',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (IV)', 'ru': 'Коммуникатор (IV)'},
          ),
        ),
        StarterKitItem(
          id: 'holograph-i',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Holograph (I)', 'ru': 'Голограф (I)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'broadband-sensor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Broadband sensor', 'ru': 'Широкополосный сенсор'},
          ),
        ),
        StarterKitItem(
          id: 'computer-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Computer (S)', 'ru': 'Компьютер (С)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'pocket-vulcan-pistol',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Pocket Vulcan pistol', 'ru': 'Карманный вулкан-пистолет'},
          ),
        ),
        StarterKitItem(
          id: 'neuroshock-stun',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Neuroshocker', 'ru': 'Нейрошокер'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'tabula',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tabula', 'ru': 'Табула'},
          ),
        ),
        StarterKitItem(
          id: 'transactor-1000-birr',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Transactor with 1000 birr', 'ru': 'Транзактор с 1000 бирров на счету'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'opor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Opor', 'ru': 'Опор'},
          ),
        ),
        StarterKitItem(
          id: 'arrash',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Arrash', 'ru': 'Арраш'},
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'anonymous-clothing',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Anonymous clothing', 'ru': 'Обезличивающая одежда'},
          ),
        ),
        StarterKitItem(
          id: 'birr-chip-500',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Birr-chip with 500 birr', 'ru': 'Бирка с 500 бирров'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'comlink-ii',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (II)', 'ru': 'Коммуникатор (II)'},
          ),
        ),
        StarterKitItem(
          id: 'protective-clothing',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Protective clothing', 'ru': 'Защитная одежда'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'vulcan-carbine',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vulcan carbine', 'ru': 'Вулкан-карабин'},
          ),
        ),
        StarterKitItem(
          id: 'vibro-sword',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vibro sword', 'ru': 'Вибромеч'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'thermal-suit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Thermal suit', 'ru': 'Термостатический комбинезон'},
          ),
        ),
        StarterKitItem(
          id: 'vacsuit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Vacsuit', 'ru': 'Экзоскафандр'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'transactor-fake-id',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Transactor with forged ID', 'ru': 'Транзактор с фальшивым удостоверением личности'},
          ),
        ),
        StarterKitItem(
          id: 'mask',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Mask', 'ru': 'Маска'},
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'tabula',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tabula', 'ru': 'Табула'},
          ),
        ),
        StarterKitItem(
          id: 'interpreter-implant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Interpreter (implant)', 'ru': 'Интерпретатор (имп.)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'comlink-v',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (V)', 'ru': 'Коммуникатор (V)'},
          ),
        ),
        StarterKitItem(
          id: 'megaphone',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Megaphone', 'ru': 'Громкоговоритель'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'luxury-outfit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Luxury outfit', 'ru': 'Роскошный наряд'},
          ),
        ),
        StarterKitItem(
          id: 'kamra-d6-doses',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Kamra (d6 doses)', 'ru': 'Камбра (d6 доз)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'lie-detector-implant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Lie detector (implant)', 'ru': 'Детектор лжи (имп.)'},
          ),
        ),
        StarterKitItem(
          id: 'auto-translator',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Auto-translator', 'ru': 'Автоматический переводчик'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'pocket-vulcan-pistol',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Pocket Vulcan pistol', 'ru': 'Карманный вулкан-пистолет'},
          ),
        ),
        StarterKitItem(
          id: 'mercury-knife',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Mercury knife', 'ru': 'Ртутный нож'},
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'pocket-vulcan-pistol',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Pocket Vulcan pistol', 'ru': 'Карманный вулкан-пистолет'},
          ),
        ),
        StarterKitItem(
          id: 'advanced-melee-weapon',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Advanced melee weapon', 'ru': 'Передовое оружие ближнего боя'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'broadband-sensor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Broadband sensor', 'ru': 'Широкополосный сенсор'},
          ),
        ),
        StarterKitItem(
          id: 'computer-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Computer (S)', 'ru': 'Компьютер (С)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'modulating-mask',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Modulating mask', 'ru': 'Модулирующая маска'},
          ),
        ),
        StarterKitItem(
          id: 'mechanical-lockpick',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Mechanical lockpick', 'ru': 'Механическая отмычка'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'recon-probe',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Recon probe', 'ru': 'Разведзонд'},
          ),
        ),
        StarterKitItem(
          id: 'fake-id-set',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Set of forged IDs', 'ru': 'Набор фальшивых удостоверений личности'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'electronic-lockpick',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Electronic lockpick', 'ru': 'Электронная отмычка'},
          ),
        ),
        StarterKitItem(
          id: 'poison-5-doses',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Poison (5 doses)', 'ru': 'Яд (5 доз)'},
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'tool-kit-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tool kit (S)', 'ru': 'Набор инструментов (С)'},
          ),
        ),
        StarterKitItem(
          id: 'piloting-talisman',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Piloting talisman', 'ru': 'Талисман пилотирования'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'vacsuit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Vacsuit', 'ru': 'Экзоскафандр'},
          ),
        ),
        StarterKitItem(
          id: 'manual-maneuvering-unit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Manual maneuvering unit', 'ru': 'Ручной маневровый двигатель'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'targeting-reticle-implant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Targeting reticle (implant)', 'ru': 'Целеуказатель (имп.)'},
          ),
        ),
        StarterKitItem(
          id: 'comlink-iv',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (IV)', 'ru': 'Коммуникатор (IV)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'rail-pistol',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Rail pistol', 'ru': 'Рельсовый пистолет'},
          ),
        ),
        StarterKitItem(
          id: 'neuroshock-stun',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Neuroshocker', 'ru': 'Нейрошокер'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'flight-suit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Flight suit', 'ru': 'Лётный комбинезон'},
          ),
        ),
        StarterKitItem(
          id: 'luxury-outfit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Luxury outfit', 'ru': 'Роскошный наряд'},
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'holy-scriptures',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Holy scriptures', 'ru': 'Священные писания'},
          ),
        ),
        StarterKitItem(
          id: 'censer',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Censer', 'ru': 'Кадило'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'talisman-any',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Talisman (any)', 'ru': 'Талисман (любой)'},
          ),
        ),
        StarterKitItem(
          id: 'ritual-robes',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Ritual robes', 'ru': 'Ритуальное облачение'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'reliquary',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Reliquary', 'ru': 'Реликварий'},
          ),
        ),
        StarterKitItem(
          id: 'prophecy-scrolls',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Prophecy scrolls', 'ru': 'Рукописи с пророчествами'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'm-stims-5',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': '5 Medi-stims', 'ru': '5 м-стимов'},
          ),
        ),
        StarterKitItem(
          id: 'blessed-herbs-10',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': '10 doses of blessed healing herbs', 'ru': '10 порций освящённых целебных трав'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'tabula',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tabula', 'ru': 'Табула'},
          ),
        ),
        StarterKitItem(
          id: 'writing-kit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Writing kit', 'ru': 'Писчие принадлежности'},
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'comlink-iii',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (III)', 'ru': 'Коммуникатор (III)'},
          ),
        ),
        StarterKitItem(
          id: 'broadband-sensor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Broadband sensor', 'ru': 'Широкополосный сенсор'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'portable-lab',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Portable lab', 'ru': 'Портативная лаборатория'},
          ),
        ),
        StarterKitItem(
          id: 'computer-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Computer (S)', 'ru': 'Компьютер (С)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'vacsuit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Vacsuit', 'ru': 'Экзоскафандр'},
          ),
        ),
        StarterKitItem(
          id: 'data-library',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Data library', 'ru': 'Электронная библиотека'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'pressure-tent',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Pressure tent', 'ru': 'Герметичный шатёр'},
          ),
        ),
        StarterKitItem(
          id: 'med-kit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Med-kit', 'ru': 'М-комплект'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'tool-kit-p',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tool kit (P)', 'ru': 'Набор инструментов (П)'},
          ),
        ),
        StarterKitItem(
          id: 'compass',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Compass', 'ru': 'Компас'},
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'tool-kit-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Tool kit (S)', 'ru': 'Набор инструментов (С)'},
          ),
        ),
        StarterKitItem(
          id: 'sealant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Sealant', 'ru': 'Герметик'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'power-knuckles',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Power knuckles', 'ru': 'Силовой кастет'},
          ),
        ),
        StarterKitItem(
          id: 'sensor-analyzer',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Sensor analyzer', 'ru': 'Сенсорный анализатор'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'arrash',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Arrash', 'ru': 'Арраш'},
          ),
        ),
        StarterKitItem(
          id: 'tobacco',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.other,
            name: {'en': 'Tobacco', 'ru': 'Табак'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'exo-loader',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Exo-loader', 'ru': 'Экзопогрузчик'},
          ),
        ),
        StarterKitItem(
          id: 'vacsuit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Vacsuit', 'ru': 'Экзоскафандр'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'hyper-cable',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Hyper-cable', 'ru': 'Гипертрос'},
          ),
        ),
        StarterKitItem(
          id: 'vibro-knife',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vibro knife', 'ru': 'Вибронож'},
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'heavy-armor',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Heavy armor', 'ru': 'Тяжёлая броня'},
          ),
        ),
        StarterKitItem(
          id: 'mercury-sword',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Mercury sword', 'ru': 'Ртутный меч'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'rail-pistol-sensor-sight-s',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Rail pistol with sensor sight (S)', 'ru': 'Рельсовый пистолет с сенсорным прицелом (С)'},
          ),
        ),
        StarterKitItem(
          id: 'vulcan-carbine',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vulcan carbine', 'ru': 'Вулкан-карабин'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'frag-grenade',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Frag grenade', 'ru': 'Осколочная граната'},
          ),
        ),
        StarterKitItem(
          id: 'reinforced-muscles-implant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Reinforced muscles (implant)', 'ru': 'Усиленные мышцы (имп.)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'officer-pad',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Officer pad', 'ru': 'Командирский планшет'},
          ),
        ),
        StarterKitItem(
          id: 'sensor-sight-p',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Sensor sight (P)', 'ru': 'Сенсорный прицел (П)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'comlink-ii',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (II)', 'ru': 'Коммуникатор (II)'},
          ),
        ),
        StarterKitItem(
          id: 'med-kit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Med-kit', 'ru': 'М-комплект'},
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
      label: {'en': 'Row 1', 'ru': 'Ряд 1'},
      options: [
        StarterKitItem(
          id: 'drone-uav',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'UAV drone', 'ru': 'БПЛА'},
          ),
        ),
        StarterKitItem(
          id: 'comlink-v',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Comlink (V)', 'ru': 'Коммуникатор (V)'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-2',
      label: {'en': 'Row 2', 'ru': 'Ряд 2'},
      options: [
        StarterKitItem(
          id: 'vibro-axe',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vibro axe', 'ru': 'Вибросекира'},
          ),
        ),
        StarterKitItem(
          id: 'vulcan-carbine',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.weapon,
            name: {'en': 'Vulcan carbine', 'ru': 'Вулкан-карабин'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-3',
      label: {'en': 'Row 3', 'ru': 'Ряд 3'},
      options: [
        StarterKitItem(
          id: 'm-stims-5',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': '5 Medi-stims', 'ru': '5 м-стимов'},
          ),
        ),
        StarterKitItem(
          id: 'data-library',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Data library', 'ru': 'Электронная библиотека'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-4',
      label: {'en': 'Row 4', 'ru': 'Ряд 4'},
      options: [
        StarterKitItem(
          id: 'optimized-metabolism-implant',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.cybernetic,
            name: {'en': 'Optimized metabolism (implant)', 'ru': 'Оптимизированный метаболизм (имп.)'},
          ),
        ),
        StarterKitItem(
          id: 'vacsuit',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.armor,
            name: {'en': 'Vacsuit', 'ru': 'Экзоскафандр'},
          ),
        ),
      ],
    ),
    StarterKitChoice(
      id: 'row-5',
      label: {'en': 'Row 5', 'ru': 'Ряд 5'},
      options: [
        StarterKitItem(
          id: 'sensor-analyzer',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Sensor analyzer', 'ru': 'Сенсорный анализатор'},
          ),
        ),
        StarterKitItem(
          id: 'compass',
          template: StarterKitItemTemplate(
            kind: StarterKitItemKind.gear,
            name: {'en': 'Compass', 'ru': 'Компас'},
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
