---
target: Landing page (apps/web/app/pages/index.vue)
total_score: 34
p0_count: 0
p1_count: 0
timestamp: 2026-05-23T21-06-42Z
slug: apps-web-app-pages-index-vue
---
## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | Locale active state is clear; the blocking `getSession()` await still has no holding state, so anonymous visitors wait on a session round-trip before first paint. |
| 2 | Match System / Real World | 4 | Domain language stays excellent: "Third Horizon", "push the roll", "Darkness Points", "operative". |
| 3 | User Control and Freedom | 3 | Locale toggle works; nothing destructive on a landing. |
| 4 | Consistency and Standards | 4 | Resolved. CTAs are `AppButton`, the framed surface uses `--radius-md`, glyphs are real brand assets, the tagline carries a proper `h1`. |
| 5 | Error Prevention | 3 | Little to get wrong. |
| 6 | Recognition Rather Than Recall | 4 | Everything visible; no recall load. |
| 7 | Flexibility and Efficiency | 3 | Two clear CTAs, fast path to sign in / sign up. |
| 8 | Aesthetic and Minimalist Design | 4 | Strong identity, now backed by a real product capture and an asymmetric feature fold. The template tell is gone. |
| 9 | Error Recovery | 3 | Session failure silently leaves the visitor on the landing. Reasonable. |
| 10 | Help and Documentation | 3 | Tagline, proof image, and blurbs teach enough for a landing. |
| **Total** | | **34/40** | **Good, climbing. Identity is strong; remaining drags are compositional and minor.** |

## Anti-Patterns Verdict

**Does this look AI-generated? No longer.**

**LLM assessment**: The two tells from the first pass are gone. The feature fold is no longer three identical icon-title-blurb cards; it is one framed lead block plus two frameless rows, each carrying a real commissioned brand asset (the eight-pointed star, The Messenger Icon, a glowing success die) rather than font-dependent Unicode. The page now shows the product: a real character-sheet capture, framed against the void with an inset brass bevel. A designer reads this as a crafted product landing, not a generated one. Both the first-order (category palette) and second-order (templatey scaffolding) reflexes are clear.

**Deterministic scan**: Detector unavailable. `detect.mjs` is a stub that exits 1 with "bundled detector not found"; a real invocation was attempted and crashed, so this is a documented fallback, not a skip.

**Visual overlays**: None. No browser automation, and the running Docker stack is a different project (`course-shelf-*`, confirmed by mount path); the Coriolis stack is down. Source-based review only. No run in this chain has been visually confirmed in a browser.

## Overall Impression

A clear lift from the first pass (31 to 34). The identity was always strong; it is now matched by proof (the screenshot) and by a feature fold that earns its place. The one remaining design-level opportunity is macro composition: every fold still centers on a single vertical axis. The axis break so far is internal text alignment, not true layout asymmetry.

## What's Working

- **The proof fold.** A real character-sheet capture, framed with an inset brass bevel (not a drop shadow, honoring DESIGN §5.4), with a `<picture>` that swaps the phone capture in under 720px. This is exactly the imagery a product landing needs, and it is the single biggest gain.
- **Design-system alignment.** CTAs are `AppButton`, so they inherit the brass-bevel, active state, and focus ring for free. No hand-rolled button drift remains. Heading structure now starts at a real `h1`.
- **The feature fold reads as intentional.** Asymmetric 1.15fr / 1fr split, a dominant framed lead, two frameless divided rows, brand assets that are also semantically apt (Messenger for Share, a 6 for Run).

## Priority Issues

- **[P2] Macro composition is still a centered vertical stack.**
  - **Why it matters**: `&__main` centers every section on one axis; the left-alignment lives only inside the showcase and feature text. brand.md asks for asymmetric compositions, and the page reads as competent-centered rather than confident-asymmetric. It is no longer a template, but it is not yet a layout with tension.
  - **Fix**: Push one fold off-axis. Options: let the showcase image bleed wider and sit left while the heading column sits right; or stagger the hero so the wordmark is not dead-center. Pick one fold to break, not all.
  - **Suggested command**: `/impeccable layout` or `/impeccable bolder`

- **[P3] Locale switch buttons fall under the 44px touch target.**
  - **Why it matters**: `padding: var(--space-1) var(--space-3)` with body-sm yields roughly a 28px tall control. On a phone at the table, the language toggle is a small tap target.
  - **Fix**: Add vertical padding or a `min-height` on touch viewports, or enlarge the pill under 540px where it already re-centers.
  - **Suggested command**: `/impeccable adapt`

- **[P3] Showcase image can shift layout on mobile (CLS).**
  - **Why it matters**: The `<img>` carries `width="1280" height="800"` (desktop ratio), but the `<source>` swaps in the 828x1792 phone capture under 720px. The reserved aspect-ratio is wrong for the mobile source until it loads. Impact is low (below fold, lazy) but real.
  - **Fix**: Drop the fixed attrs and set an explicit `aspect-ratio` per breakpoint, or accept the minor below-fold shift knowingly.
  - **Suggested command**: `/impeccable optimize`

## Persona Red Flags

**Skeptical Evaluator (first-time visitor)**: The earlier dealbreaker is fixed. They now see the actual sheet before signing up, framed and legible. Residual friction: the blocking session check can leave them on a blank beat before the landing paints on a slow network.

**Returning Player / GM (knows Coriolis)**: The promise is now backed by a picture of the thing. The capture shows attributes, skills, conditions, talents at a glance, which is exactly what they wanted to see. Low remaining friction.

## Minor Observations

- The showcase shows the whole sheet, and the "Sheet" lead feature also describes it. Slight conceptual overlap; the showcase proves, the feature explains, so it holds, but watch for redundancy if copy grows.
- The blocking `getSession()` await is deliberate (it prevents an authed flash) but trades that for an anonymous-visitor wait. A non-blocking variant with a holding state is a harden/optimize call, not polish.
- The "Sheet" lead glyph is the generic eight-pointed star (the app mark), not a sheet-specific Icon. Loose but acceptable.

## Questions to Consider

- Which single fold deserves to break the center axis? The showcase is the natural candidate.
- Does the hero need to stay perfectly centered, or would an off-axis wordmark add the confidence the composition still lacks?
- Is the "Sheet" feature pulling its weight now that the screenshot shows the sheet, or should that slot describe something the image cannot?
