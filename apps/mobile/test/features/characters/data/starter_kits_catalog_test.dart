import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/features/characters/data/starter_kits_catalog.dart';

void main() {
  group('kStarterKitCatalog', () {
    test('contains exactly 33 entries (11 amplua × 3 roles)', () {
      expect(kStarterKitCatalog.length, 33);
    });

    test('has no duplicate (concept, role) pairs', () {
      final pairs =
          kStarterKitCatalog.map((k) => '${k.concept}/${k.role}').toList();
      final unique = pairs.toSet();
      expect(unique.length, pairs.length,
          reason: 'Duplicate (concept, role) pair detected');
    });

    test('every kit has fixed=[] and exactly 5 choices with 2 options each',
        () {
      for (final kit in kStarterKitCatalog) {
        expect(kit.fixed, isEmpty,
            reason:
                '${kit.concept}/${kit.role}: expected fixed to be empty');
        expect(kit.choices.length, 5,
            reason:
                '${kit.concept}/${kit.role}: expected 5 choices, got ${kit.choices.length}');
        for (final choice in kit.choices) {
          expect(choice.options.length, 2,
              reason:
                  '${kit.concept}/${kit.role}/${choice.id}: expected 2 options, '
                  'got ${choice.options.length}');
        }
      }
    });

    // ── Deep-equality spot-checks (drift guards) ─────────────────────────────

    test('pilot/ace — row 4 option 0 is rail-pistol (WEAPON)', () {
      final kit = findStarterKit('pilot', 'ace');
      expect(kit, isNotNull, reason: 'findStarterKit("pilot", "ace") is null');
      final row4 = kit!.choices[3];
      expect(row4.id, 'row-4');
      expect(row4.options[0].id, 'rail-pistol');
      expect(row4.options[0].template.name['en'], 'Rail pistol');
      expect(row4.options[0].template.kind, StarterKitItemKind.weapon);
    });

    test('soldier/mercenary — row 1 option 0 is heavy-armor (ARMOR)', () {
      final kit = findStarterKit('soldier', 'mercenary');
      expect(kit, isNotNull);
      final row1 = kit!.choices[0];
      expect(row1.options[0].id, 'heavy-armor');
      expect(row1.options[0].template.name['en'], 'Heavy armor');
      expect(row1.options[0].template.name['ru'], 'Тяжёлая броня');
      expect(row1.options[0].template.kind, StarterKitItemKind.armor);
    });

    test('artist/companion — row 4 option 0 is beautiful-appearance-biomod (CYBERNETIC)', () {
      final kit = findStarterKit('artist', 'companion');
      expect(kit, isNotNull);
      final row4 = kit!.choices[3];
      expect(row4.options[0].id, 'beautiful-appearance-biomod');
      expect(row4.options[0].template.name['en'],
          'Beautiful appearance (biomod)');
      expect(row4.options[0].template.kind, StarterKitItemKind.cybernetic);
    });

    test('pioneer/scout — row 4 option 0 is optimized-metabolism-implant (CYBERNETIC)', () {
      final kit = findStarterKit('pioneer', 'scout');
      expect(kit, isNotNull);
      final row4 = kit!.choices[3];
      expect(row4.options[0].id, 'optimized-metabolism-implant');
      expect(row4.options[0].template.kind, StarterKitItemKind.cybernetic);
    });

    test('sailor/loader — row 5 option 1 is vibro-knife (WEAPON)', () {
      final kit = findStarterKit('sailor', 'loader');
      expect(kit, isNotNull);
      final row5 = kit!.choices[4];
      expect(row5.options[1].id, 'vibro-knife');
      expect(row5.options[1].template.kind, StarterKitItemKind.weapon);
    });
  });

  group('findStarterKit', () {
    test('returns null for unknown combination', () {
      expect(findStarterKit('unknown', 'role'), isNull);
    });

    test('all roles within an amplua share the same choices', () {
      // All three pilot roles should yield identical choices (same ids).
      final ace = findStarterKit('pilot', 'ace');
      final driver = findStarterKit('pilot', 'driver');
      final trucker = findStarterKit('pilot', 'trucker');
      expect(ace, isNotNull);
      expect(driver, isNotNull);
      expect(trucker, isNotNull);
      final aceIds = ace!.choices.map((c) => c.id).toList();
      expect(driver!.choices.map((c) => c.id).toList(), aceIds);
      expect(trucker!.choices.map((c) => c.id).toList(), aceIds);
    });
  });

  group('pickStarterKitItemName', () {
    test('returns EN when locale is unknown', () {
      final item = kStarterKitCatalog.first.choices.first.options.first;
      expect(pickStarterKitItemName(item, 'xx'), item.template.name['en']);
    });

    test('returns RU for ru locale', () {
      final kit = findStarterKit('pilot', 'ace')!;
      final railPistol = kit.choices[3].options[0];
      expect(pickStarterKitItemName(railPistol, 'ru'), 'Рельсовый пистолет');
    });

    test('uk placeholder contains [uk-todo]', () {
      final kit = findStarterKit('pilot', 'ace')!;
      final item = kit.choices[0].options[0];
      expect(pickStarterKitItemName(item, 'uk'), contains('[uk-todo]'));
    });
  });
}
