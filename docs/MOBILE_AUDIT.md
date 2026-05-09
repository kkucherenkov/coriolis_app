# Mobile Sheet Audit — T-6.4.1.a / .b / .c

Audit of `apps/mobile/lib/features/characters/presentation/` against
`specs/design/mockups/sheet-mobile.jsx`.

Date: 2026-05-09. Auditor: agent-a8ae0852906e155a5.

---

## Audit checklist (8 items)

### 1. Sticky header — layout (T-6.4.1.a)

**Status: MATCHES**

`sheet_header.dart` renders the condensed header with:

- `AppAvatar` (portrait initials) + name + concept on the left
- `AppSavePulse` dot on the right
- HP / MP mini counters (`_MiniCounter`) next to the pulse dot
- Condition chip strip (`_ConditionStrip`) below, horizontally scrollable

This matches the mockup's header row + condition pills pattern.
The gradient (`surfaceNight → surfaceVoid`) and brass border-bottom also match.

### 2. Condition strip placement (T-6.4.1.a)

**Status: MATCHES**

The condition strip is inside `SheetHeader` (in `sheet_header.dart`), rendered
as a second row below the avatar/name row. This matches the mockup:

```jsx
{/* condition pills */}
<div style={{ display: 'flex', gap: 6, marginTop: 10, overflowX: 'auto' }}>
```

The `ConditionsPanel` widget in `conditions_panel.dart` is a separate full panel
in the Stats tab for editing critical injuries — it duplicates condition chips
there too. This is intentional: header strip = quick-read, panel = editorial.
No action needed; document-only.

### 3. HP / MP / ENC counters (T-6.4.1.a)

**Status: MATCHES**

`hero_counters.dart` renders three `_CounterCard` widgets in a horizontal row.
HP and MP have `−`/`+` buttons with 44×44 minimum tap targets. ENC is
read-only and shows a warning chip when at capacity. Values use
`AppTypography.monoStatMd` (JetBrains Mono). All token-correct.

Minor gap: the mockup mini-counters in the header (`MiniCounter`) show HP/MP
only; the main counter row also adds ENC. This diverges slightly from the mockup
body (which omits ENC in the visible body scroll) but is a sensible addition
for the sheet. **Deferred** — additive, not contradicting.

### 4. Bottom tab bar (T-6.4.1.a) — HIGH IMPACT

**Status: GAP — FIXED**

Before: `_SheetTabBar` was positioned between the sticky header and the
scrollable content (i.e. at the TOP of the body Column). This contradicts the
mockup, which shows a bottom-fixed bar:

```jsx
{/* Bottom tab bar */}
<div style={{ position: 'sticky', bottom: 0, ... }}>
```

Fix applied in `character_sheet_page.dart`:

- Moved `_SheetTabBar` to `Scaffold.bottomNavigationBar`.
- Wrapped content in `SafeArea(top: false)` so it respects home indicator.
- Border changed from `bottom:` to `top:` (divider above the bar).
- Active indicator position updated: brass stripe at the **top** edge of the
  tab item (mockup shows the stripe at the bottom of the circle icon; adapted
  since we use text-only tabs without icon circles).
- `_TabItem` height increased from 48 → 56 px for comfortable bottom-bar feel.

Also fixed in the same pass:

- The `GestureDetector.onTap` was calling `cubit.emit()` directly (uses a
  `@visibleForTesting` / `@protected` member). Replaced with a new
  `CharacterSheetCubit.switchTab(tab)` method.
- Unused local variable `t` in `_SheetTabContent.build` removed.

### 5. Scroll behavior (T-6.4.1.a)

**Status: MATCHES (after fix 4)**

Before fix 4 the tab bar was inside the body Column above the `Expanded`
scroll area, which produced a layout where both the tab bar and the content
scrolled if the header grew. After moving the tab bar to
`Scaffold.bottomNavigationBar`, the scroll area fills the space between the
sticky header and the fixed tab bar — matching the mockup's `flex: 1,
overflow: auto` body pattern.

### 6. Notes tab (T-6.4.1.a)

**Status: MATCHES**

`_NotesTab` in `character_sheet_page.dart` renders an editable `AppTextarea`
with `notesHint` placeholder. Changes are debounced through
`CharacterSheetCubit.updateNotes`. This satisfies the "basic editable text area
showing notes string" requirement for v1.

### 7. Talent / Item editor bottom sheets — visual rhythm (T-6.4.1.a)

**Status: MATCHES**

Both `_TalentEditorSheet` (in `talent_editor.dart`) and the item editor
(in `item_editor.dart`) use:

- `AppColors.surfaceNight` background
- `AppRadius.lg` top-border-radius
- Drag handle (brass-deep pill, 64×4)
- `AppSpacing.s4` insets with `viewInsets.bottom` bottom padding
- `AppField` / `AppInput` / `AppTextarea` for inputs
- `AppButton` for primary and danger actions

Visual rhythm is consistent with the design-system tokens. Minor delta: the
talent rank selector uses 44×44 tap circles (3 ranks), matching tap-target
rules but not matching any mockup component directly. **Acceptable for v1.**

### 8. `_RankStepperSheet` private-class breakage (pre-existing bug)

**Status: GAP — FIXED**

`skills_block.dart` was importing `_RankStepperSheet` as a `show` clause from
`attributes_block.dart`. Private classes cannot be exported — the analyser
reported `undefined_method` / `not_a_type` / `undefined_shown_name` errors.

Fix: extracted the stepper to a new public widget
`RankStepperSheet` in
`apps/mobile/lib/features/characters/presentation/widgets/rank_stepper_sheet.dart`.
Both `attributes_block.dart` and `skills_block.dart` now import it.
The private `_RankStepperSheet` + `_StepperIconButton` duplicate in
`attributes_block.dart` was removed.

---

## Cyrillic font rendering (T-6.4.1.b)

### Current state

`packages/ui_flutter/pubspec.yaml` declares **no font assets**. The
`AppFontFamily` constants (`"Forum"`, `"Inter"`, `"JetBrains Mono"`) are token
values but no `.ttf`/`.otf` files are bundled in either the `ui_flutter`
package or the host app (`apps/mobile/pubspec.yaml`).

Flutter's font resolution:

1. Looks for a bundled family by the exact name declared in the `flutter.fonts`
   section of `pubspec.yaml`.
2. If not found, falls back to the platform default: **Roboto** on Android,
   **San Francisco / Helvetica Neue** on iOS.

Both Roboto and the iOS system UI fonts include **full Cyrillic Unicode
coverage** (U+0400–U+04FF). Therefore all `ru` strings render correctly in the
fallback font — there are no missing-glyph boxes for `Б`, `Я`, `Ж`, etc.

### Forum font and Cyrillic

Forum is a Latin-only display font (Google Fonts family, designed for headings).
Its standard TTF does **not** include Cyrillic glyphs. If Forum were bundled
without a Cyrillic-extended variant, any `ru` display text styled with
`AppFontFamily.display` would render as fallback boxes.

Because no font files are currently bundled, the display style silently falls
back to Roboto (Android) — which is correct for Cyrillic but loses the Forum
aesthetic for Latin text too. This is a broader gap (no custom fonts at all),
not a Cyrillic-specific regression.

### Decision for v1

Keep the current state (system fallback for all three families) and document
the gap. No font files are added in this pass because:

1. Bundling fonts is a non-trivial asset change that requires `flutter pub get`
   and platform rebuild — out of scope for a visual audit PR.
2. The fallback (Roboto) renders Cyrillic correctly — no user-visible
   broken glyphs.

### Recommended follow-up (deferred)

1. Bundle `Forum.ttf` (Latin glyphs only) + `Forum-Cyrillic.ttf` (subset from
   Google Fonts) and declare them as two entries in the same `Forum` family
   with the Cyrillic subset file listed first. Flutter's font matcher will
   pick the Latin file for ASCII and fall through to the Cyrillic file for
   U+0400+ glyphs.
2. Bundle `Inter` (has full Cyrillic) and `JetBrains Mono` similarly.
3. Add the `flutter.fonts` section to `packages/ui_flutter/pubspec.yaml` (or
   `apps/mobile/pubspec.yaml`) and run `flutter pub get` in both.

No code changes needed for this workaround if the per-locale font-family helper
approach is preferred instead: add a `fontFamilyFor(Locale locale)` helper in
`AppFontFamily` that returns `AppFontFamily.body` (`"Inter"`) for `Locale('ru')`
and `AppFontFamily.display` otherwise. However, until fonts are actually bundled
this helper has no effect on fallback behaviour.

---

## Cold-start measurement (T-6.4.1.c)

### Measurement plan

No Android emulator is available in this environment. The plan below describes
how to reproduce the measurement against the PRD NFR §6 target of ≤ 2.0s cold
start on a mid-range Android device.

#### Target device / emulator

- **Baseline**: Google Pixel 4 (Snapdragon 855, 6 GB RAM) or an Android
  emulator with `x86_64` ABI, API 31, no GPU acceleration (`-gpu guest`).
- **Preferred real device**: any Android 11+ phone in the Pixel 4 / Samsung
  A52 class.

#### Steps

```sh
# 1. Connect the device / start the emulator.
adb devices   # confirm device is listed

# 2. Build a release APK (no Dart DevTools, no asserts).
cd apps/mobile
flutter build apk --release

# 3. Install.
flutter install --release

# 4. Run with startup trace.
flutter run --release --trace-startup --no-hot

# 5. Read the metric from stdout (search for engine_init_to_first_frame_ms)
#    or from the saved trace file:
#    ~/.flutter_startup_trace.json
cat ~/.flutter_startup_trace.json | python3 -c \
  "import json,sys; d=json.load(sys.stdin); \
   print([e for e in d['traceEvents'] if 'firstUsefulFrameRasterized' in str(e)])"
```

The key metric is `engine_init_to_first_frame_ms` from the trace. Alternatively
use `adb shell am start -W` to measure `TotalTime` (wall-clock from Intent
dispatch to first draw):

```sh
adb shell am start -W -n com.coriolis.companion/.MainActivity
# TotalTime: <ms>   ← this is the cold-start duration
```

#### Expected bottlenecks

- Firebase SDK initialisation (`Firebase.initializeApp()`) adds ~200–400ms on
  first launch without caching.
- Sentry initialisation (`SentryFlutter.init`) adds ~50–100ms.
- `configureDependencies()` (get_it) is synchronous and fast (<5ms).
- If both Firebase and Sentry are active, the total pre-`runApp` latency is
  already 300–500ms, leaving 1.5–1.7s budget for Flutter engine + first frame.

#### Pass / fail criterion

| Metric                          | Target    | Source          |
| ------------------------------- | --------- | --------------- |
| `engine_init_to_first_frame_ms` | ≤ 2000 ms | PRD NFR §6      |
| `adb am start TotalTime`        | ≤ 2000 ms | proxy for above |

If the measurement exceeds 2.0s, the first candidates for optimisation are:

- Lazy-load Firebase initialisation (defer until AuthGate resolves).
- Move Sentry init to `after first frame` using `WidgetsBinding.instance.addPostFrameCallback`.
- Profile with `flutter run --profile` + DevTools timeline to find frame-budget
  overruns.

---

## Summary

| #   | Item                         | Status             | Action    |
| --- | ---------------------------- | ------------------ | --------- |
| 1   | Sticky header layout         | MATCHES            | —         |
| 2   | Condition strip placement    | MATCHES            | —         |
| 3   | HP / MP / ENC counters       | MATCHES            | —         |
| 4   | Bottom tab bar position      | GAP                | **FIXED** |
| 5   | Scroll behavior              | MATCHES (post-fix) | —         |
| 6   | Notes tab                    | MATCHES            | —         |
| 7   | Talent / Item editor rhythm  | MATCHES            | —         |
| 8   | `_RankStepperSheet` breakage | GAP                | **FIXED** |

**8 gaps audited; 2 fixed; 0 deferred (cosmetic delta on ENC counter noted); Cyrillic: system-fallback safe, Forum bundling deferred; cold-start: measurement plan documented.**

Additional fixes applied in the same pass:

- `cubit.emit()` direct call replaced with `cubit.switchTab()` (new method).
- Unused local variable `t` in `_SheetTabContent` removed.
- Tab-bar border changed to `top:` (now sits at bottom of screen).
- Active-tab indicator moved to top edge of bar item for bottom-bar context.
