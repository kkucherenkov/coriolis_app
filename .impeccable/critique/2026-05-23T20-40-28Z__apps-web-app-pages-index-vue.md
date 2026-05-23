---
target: Landing page (apps/web/app/pages/index.vue)
total_score: 31
p0_count: 0
p1_count: 2
timestamp: 2026-05-23T20-40-28Z
slug: apps-web-app-pages-index-vue
---
## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | Locale active state is clear; the auth `getSession()` redirect can flash the landing before bouncing authed users to `/app/dashboard`. |
| 2 | Match System / Real World | 4 | Domain language is excellent: "Third Horizon", "push the roll", "Darkness Points", "the Nine Icons". |
| 3 | User Control and Freedom | 3 | Locale toggle works; nothing destructive on a landing. n/a-ish. |
| 4 | Consistency and Standards | 2 | Buttons re-implemented in page SCSS instead of `AppButton`; feature cards use `--radius-lg` where the system reserves `lg` for modals; unicode glyphs stand in for the brand's commissioned Icon set. |
| 5 | Error Prevention | 3 | Little to get wrong here. |
| 6 | Recognition Rather Than Recall | 4 | Everything is visible; no recall load. |
| 7 | Flexibility and Efficiency | 3 | Two clear CTAs, fast path to sign in / sign up. |
| 8 | Aesthetic and Minimalist Design | 3 | Strong, committed identity, undercut by a templatey three-card feature fold and zero product imagery. |
| 9 | Error Recovery | 3 | Session failure silently leaves the visitor on the landing. Reasonable. |
| 10 | Help and Documentation | 3 | Tagline plus blurbs teach enough for a landing. |
| **Total** | | **31/40** | **Good — distinctive identity, generic below-the-fold execution** |

## Anti-Patterns Verdict

**Does this look AI-generated? Split decision.**

**LLM assessment**: The hero and chrome pass the brand slop test decisively. Brass-on-indigo, the twinkling starfield, four arabesque corners, an italic tagline: a visitor asks "how was this made?", not "which AI made this?" This is a committed Drenched-indigo identity, exactly what the brand register rewards.

Then the feature fold collapses into AI scaffolding. Three identical bordered cards, each `glyph → uppercase title → blurb`, centered in a `repeat(3, 1fr)` grid. That is the shared absolute ban "Identical card grids" and the brand ban "centered-stack hero with icon-title-subtitle cards reads as template" in one element. The glyphs are generic Unicode (`✦ ☍ ⚂`), not the project's own eight-pointed star ornament or Nine Icons from DESIGN §4, and `⚂` is a die showing 3 in an app whose whole ritual is rolling 6s. The most ornate design system in the docs gets represented by three same-size boxes with font-dependent symbols. Second-order slop: the identity dodged the reflex, the feature section walked into it.

**Deterministic scan**: Detector unavailable. `detect.mjs` is a stub that exits 1 with "bundled detector not found"; a real invocation was attempted and crashed, so this is a documented fallback, not a skip. No automated counts or rule names this run.

**Visual overlays**: None. No browser automation in this session, and the running Docker stack is a different project (`course-shelf-*`), so no reliable Coriolis URL to inject into. Source-based review only.

## Overall Impression

The brand identity is genuinely strong and ownable. The page is let down by its single weakest section and by showing nothing of the product it sells. The single biggest opportunity: replace the three lookalike cards with the brand's real ornamental assets and a glimpse of the actual character sheet, then break the rigid center column.

## What's Working

- **Committed atmosphere.** The starfield (two-layer radial-gradient stipple, `prefers-reduced-motion` respected) plus four arabesque corners plus indigo drench is a coherent, distinctive first impression. This is the register done right.
- **Domain voice in copy.** "Push the roll", "Darkness Points", "the wheel of the Horizon stays at your fingertips" earn trust with players instantly, in both en and ru.
- **Quiet accessibility craft.** `aria-labelledby` on the hero, `aria-current` on the active locale, `:focus-visible` brass outlines everywhere, decorative layers marked `aria-hidden`, reduced-motion handling. No token violations, no hardcoded hex.

## Priority Issues

- **[P1] The three-card feature grid is the AI-template tell, and it ignores the brand's own assets.**
  - **Why it matters**: It is the one section a designer would immediately flag as generated. Identical icon-title-blurb cards in a 3-column grid are a documented anti-pattern, and using Unicode `✦ ☍ ⚂` instead of the eight-pointed star / Nine Icon glyphs (DESIGN §4) throws away the single most distinctive thing the brand owns. The glyphs also render inconsistently across OS font stacks.
  - **Fix**: Differentiate the three blocks (vary size, alignment, or treatment per brand.md "art direction per section"). Swap Unicode for `AppStarOrnament` / commissioned Icon SVGs or real `AppDie` faces. If a die is the "Run" glyph, show a 6, the success face, not a 3.
  - **Suggested command**: `/impeccable layout` then `/impeccable delight`

- **[P1] CTAs re-implement `AppButton` in page SCSS.**
  - **Why it matters**: `page-landing__button--primary/--ghost` duplicate `AppButton`'s primary and ghost variants by hand. This is the documented ban "ad-hoc markup in pages instead of extending @app/ui" (CLAUDE.md / DESIGN §15), and it means the landing's buttons will silently drift from the system (no brass-bevel shadow, no `:active` state, no `size`/`loading` props the component already ships).
  - **Fix**: Replace the two raw `<button>`s with `<AppButton variant="primary">` / `<AppButton variant="ghost">`. Delete the duplicated SCSS.
  - **Suggested command**: `/impeccable polish`

- **[P2] No product imagery. A character-sheet app shows no character sheet.**
  - **Why it matters**: Dev-tool and app landings convert on a glimpse of the real UI. The brand register treats a product screenshot as imagery, and its absence leaves the page carried entirely by chrome and copy. A skeptical first-time visitor cannot see what they are signing up for. (DESIGN §7.1 does not mandate a screenshot, so this is an opportunity, not a spec violation.)
  - **Fix**: Add one decisive below-the-fold visual: a framed character-sheet screenshot or a rendered `CharacterSheet_Desktop` mockup, art-directed against the void.
  - **Suggested command**: `/impeccable bolder`

- **[P2] Everything is a centered stack.**
  - **Why it matters**: brand.md: "Don't default to centering everything. A centered-stack hero with icon-title-subtitle cards reads as template." Wordmark, tagline, CTAs, cards, footer all sit on one center axis with no asymmetry, no scale drama, no dominant idea beyond the wordmark. It reads as competent rather than confident.
  - **Fix**: Introduce one deliberate break: an oversized single hero word, an off-axis feature layout, or a strong asymmetric grid. Pick one fold to dominate.
  - **Suggested command**: `/impeccable layout`

- **[P3] `--radius-lg` on feature cards drifts from the card spec.**
  - **Why it matters**: DESIGN §2.3 reserves `lg` (8px) for "modals, elevated panels"; cards use `md` (4px). Small, but it is the kind of token-semantics drift the system is built to prevent.
  - **Fix**: Use `--radius-md`, or formalize a landing-card exception in DESIGN.
  - **Suggested command**: `/impeccable polish`

## Persona Red Flags

**Skeptical Evaluator (first-time visitor, never heard of the tool)**: Lands on a handsome dark page and reads three blurbs, but sees zero proof: no screenshot of the sheet, no example, no "what it actually looks like." Has to sign up to find out. High bounce risk at exactly the conversion moment. The Unicode glyphs that render as tofu or mismatched symbols on some Android/Linux stacks read as "unpolished" to the one persona judging polish.

**Returning Player / GM (knows Coriolis, evaluating for the table)**: The copy lands ("push the roll", "Darkness Points") and earns a nod, but the page never shows the dice roller or combat tracker it promises. Wants to see the wheel, gets told about it. Will likely click through on faith rather than conviction.

## Minor Observations

- Auth-redirect can flash the landing for a beat before bouncing authenticated users; a holding state would smooth it.
- The locale switcher is the entire top nav. Fine for a one-fold landing, but it leaves the top-left visually empty under the arabesque corner.
- Tagline italic in Inter is tasteful; just confirm Inter ships a true italic in the self-hosted subset rather than a synthesized oblique.

## Questions to Consider

- What would a confident version of the feature fold look like, one that used the eight-pointed star and a real sheet screenshot instead of three boxes?
- Does the landing need three equal features, or one dominant proof (the sheet) plus two supporting notes?
- If a returning GM is the highest-intent visitor, what single image would make them click "Create account" without hesitation?
