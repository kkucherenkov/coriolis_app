# Phase 8 / Stream D — Chat UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the full chat surface across web (`@app/ui` + `apps/web`) and mobile (`apps/mobile/lib/features/sessions`) so that a session member can read, post, edit, soft-delete, whisper, block, mark-read, and see system messages on top of the REST + Centrifugo contract delivered in Stream C. After this stream, the chat column on `/app/sessions/:id` (player) and the docked side-rail on `/app/game-sessions/:id` (GM) are fully functional; the Flutter `ChatTab` widget mirrors them; and four design tokens, seven system-message i18n keys, and a per-session block-UI affordance ship together.

**Architecture:**

- 11 new web components under `packages/ui/src/components/AppChat*`, each shipping the four-file shape (`*.vue + *.stories.ts + *.spec.ts + index.ts`) per `@app/ui` audit gate.
- Composition root for the web side: `AppChatPanel` (props `mode: 'primary' | 'docked'`) wraps everything; consumed by `apps/web/app/pages/app/sessions/[id].vue` and `apps/web/app/pages/app/game-sessions/[id].vue`.
- Web state: a Pinia store `useChatStore(sessionId)` owns the open conversation key, the per-conversation message list / cursor / pending-send queue, and a presence map. Subscribes Centrifugo via a new `useSessionChatRealtime` composable that wraps `Centrifuge` against the two Stream-C channel families (`session.<id>.chat` + `session.<id>.member.<myMembershipId>`).
- Mobile: parallel `ChatPanel`, `ChatTabStrip`, `ChatMessage`, `ChatComposer`, `WhisperPicker` widgets under `apps/mobile/lib/features/sessions/presentation/widgets/chat/`. Bottom tabs `Chat | Encounter | Me` on `player_session_detail_page.dart`. State via `flutter_bloc` (`ChatBloc`); realtime via the existing `dart:centrifuge` client used by encounter realtime.
- Backend: four `@EventsHandler` subscribers added under `apps/backend/src/modules/chat/events/system-message.subscriber.ts` translating `MemberJoinedEvent / MemberLeftEvent / MemberKickedEvent / RollPushedEvent` into `PostSystemMessageCommand`. Always broadcast-only.
- Design tokens: 4 new color tokens under `specs/design/tokens/color.json` → `pnpm design:build` regenerates the consumer artefacts.
- Block UI: kebab "Block in this session" + `AppConfirm` on web; mobile bottom-sheet equivalent. The per-session block REST routes (`POST/DELETE/GET /game-sessions/:id/blocks`) and the 403 enforcement already ship in Stream C — Stream D ships the affordance and the picker filter only.

**Tech stack:**

- Web: Nuxt 4 SPA + Vue 3.5 SFCs + Pinia + `@app/api-client-ts` + `centrifuge` (already a dep) + `@nuxt/ui` + Tailwind 4 + Stylelint (no hex literals) + Vitest + `@vue/test-utils` + Storybook 8 (`@storybook/vue3` + `@storybook/addon-a11y` already wired).
- Mobile: Flutter 3.41 + `flutter_bloc` + `get_it` + `dio` + `centrifuge_dart`.
- Backend: NestJS 11 CQRS + `@nestjs/cqrs` `@EventsHandler` + `vitest`.

**Spec versions:** no spec change. OpenAPI stays at `1.8.0`, AsyncAPI stays at `0.12.0`. All chat REST routes + Centrifugo channels were shipped in Stream C and the generated TS/Dart clients already cover them.

**Out of scope:** `characterIds` cleanup (Stream E); deep-link host wiring (T-2026-05-17-DEEP-LINK-SETUP, blocked on host availability); chat search (full-text on `body`); message reactions; Redis-backed rate limiter; haptics on Flutter web (Flutter mobile only).

---

## Pre-flight

- [ ] Push entry to `specs/tasks/active.md` using the Stream C template — title `T-2026-05-16-PHASE-8-STREAM-D`, status `in-progress`, link this plan. The deep-link blocker entry stays.
- [ ] Branch off `main`: `git checkout -b feat/phase-8/stream-d-chat-ui`.
- [ ] Verify clean baseline:
  ```sh
  pnpm spec:validate && pnpm spec:bundle
  pnpm --filter @app/backend test --run
  pnpm --filter @app/ui test --run
  pnpm --filter @app/web test --run
  cd apps/mobile && flutter analyze lib && cd -
  ```
  All green before any edit.
- [ ] Confirm `apps/web/app/composables/useSessionRealtime.ts` and `packages/api-client-ts/src/generated/sdk.gen.ts` are at the Stream-C-shipped versions (sanity check — `git log -1 packages/api-client-ts/src/generated/sdk.gen.ts` should show the Stream-C codegen commit `de72ce3` or later).
- [ ] Confirm tokens for the deep-link blocker do not appear in `specs/design/tokens/color.json` (we are not unblocking that — just bounding scope).

---

## Task 1 — Design tokens

**Owner agent:** `frontend-engineer`.

**Files:**

- Modify: `specs/design/tokens/color.json` — add 4 chat tokens under `color.chat.*`.
- Auto-regenerated (commit separately): `packages/design-tokens/src/generated/**` (whatever `pnpm design:build` emits — pin to actual output paths via dry-run before scripting), Tailwind `@theme` block(s) consuming the tokens.

### Step 1.1 — Add tokens

Append a new `chat` group under `color.*`:

```json
"chat": {
  "bubble-author-bg": {
    "$value": "#2C2348",
    "$type": "color",
    "$description": "Chat bubble background for messages authored by the local user. Warm-violet, ~12% lighter than surface.night so author messages register without leaving brand. Pair: text on this is parchment-default."
  },
  "bubble-other-bg": {
    "$value": "#1A1F47",
    "$type": "color",
    "$description": "Chat bubble background for messages authored by other members. Cool-indigo, sits between surface.night and surface.void. Pair: text on this is parchment-soft."
  },
  "system-fg": {
    "$value": "#7E7FA8",
    "$type": "color",
    "$description": "Foreground for kind=system messages — desaturated mauve, low-contrast on surface.void. AA contrast 4.6:1 vs surface.void; below body-text contrast on purpose so system rows don't visually dominate chat."
  },
  "whisper-accent": {
    "$value": "#C49AD4",
    "$type": "color",
    "$description": "Whisper accent — lavender highlight for whisper tab strip, bubble border, and the lock glyph. Distinct from brand brass so members can scan broadcast vs whisper at a glance."
  }
}
```

These values are placeholders that satisfy AA contrast against `surface.void` and `surface.night` per quick eyeball; the design owner may rev them post-merge — that's a token-only diff that does not re-trigger any of the component work.

### Step 1.2 — Rebuild + Tailwind

```bash
pnpm design:build
pnpm --filter @app/ui lint --fix
```

`pnpm design:build` should emit the new tokens as CSS custom properties (`--chat-bubble-author-bg`, `--chat-bubble-other-bg`, `--chat-system-fg`, `--chat-whisper-accent`) consumable from `@app/ui` SFCs and from the Tailwind `@theme` block. Verify with:

```bash
rg "chat-bubble-author-bg" packages/design-tokens/src/generated packages/ui/src
```

Both directories should show a generated artefact and zero hand-edited consumers (consumers come in Tasks 3–6).

### Step 1.3 — Stylelint allow

If Stylelint flags a missing CSS custom-property declaration, add the four new properties to whichever allow-list already covers `--surface-void` / `--brand-brass` (search `stylelint.config.{cjs,mjs,js}` for `customProperty`). Do not introduce a new ignore — extend existing entries only.

### Step 1.4 — Commit

```bash
git add specs/design/tokens/color.json packages/design-tokens/src/generated
git commit -m "feat(design): chat color tokens (bubble-author, bubble-other, system-fg, whisper-accent)"
```

**Exit criteria:** `pnpm design:build` clean; `pnpm --filter @app/ui stylelint` clean; no hex literals introduced.

---

## Task 2 — Backend system-message subscribers

**Owner agent:** `backend-engineer`.

**Files:**

- Create: `apps/backend/src/modules/chat/events/system-message.subscriber.ts`
- Create: `apps/backend/src/modules/chat/events/system-message.subscriber.spec.ts`
- Modify: `apps/backend/src/modules/chat/chat.module.ts` — register the subscriber under `providers`.
- Modify: `apps/backend/src/modules/chat/chat.module.ts` — add `MembershipsModule` import already present; add `forwardRef(() => DiceModule)` if `RollPushedEvent` lives there (verify path under `apps/backend/src/modules/dice/`).

### Step 2.1 — Event handler scaffold

`system-message.subscriber.ts` exposes a single `@EventsHandler` class per event so they can be tested in isolation. Pattern (one class per event, all in this file — mirrors `chat-realtime.publisher.ts` in Stream C):

```typescript
import { EventsHandler, IEventHandler, CommandBus } from '@nestjs/cqrs';
import { MemberJoinedEvent } from '../../memberships/events/member-joined.event.js';
import { MemberLeftEvent } from '../../memberships/events/member-left.event.js';
import { MemberKickedEvent } from '../../memberships/events/member-kicked.event.js';
import { RollPushedEvent } from '../../dice/events/roll-pushed.event.js';
import { PostSystemMessageCommand } from '../commands/post-system-message.command.js';

@EventsHandler(MemberJoinedEvent)
export class MemberJoinedSystemMessageSubscriber implements IEventHandler<MemberJoinedEvent> {
  constructor(private readonly bus: CommandBus) {}
  async handle(e: MemberJoinedEvent): Promise<void> {
    await this.bus.execute(
      new PostSystemMessageCommand({
        gameSessionId: e.gameSessionId,
        systemKey: 'chat.system.member_joined',
        systemParams: { displayName: e.displayName },
      }),
    );
  }
}
```

Mirror the same shape for `MemberLeftEvent`, `MemberKickedEvent`, `RollPushedEvent`. For `RollPushedEvent`, `systemParams` carries `{ characterName, hits, pushedCount, dpDelta }` — pull the field names off `RollPushedEvent`'s actual type (read `apps/backend/src/modules/dice/events/roll-pushed.event.ts` before authoring; if the event lacks `characterName` the handler must denormalise via `CHARACTER_REPO`).

> **Key contract:** All system messages are broadcast — `targetMembershipId` is always `null`. Confirm `PostSystemMessageCommand` (shipped in Stream C, Block 5) accepts a payload without `authorMembershipId` and writes `kind: 'system'` with `body: null`.

### Step 2.2 — Tests (TDD)

`system-message.subscriber.spec.ts` — one `describe` per subscriber. Use the standard `CqrsTestingModule` pattern from `chat-realtime.publisher.spec.ts`. Assertions per handler:

```typescript
it('dispatches PostSystemMessageCommand with the right key + params', async () => {
  const bus = { execute: vi.fn().mockResolvedValue(undefined) };
  const sut = new MemberJoinedSystemMessageSubscriber(bus as any);
  await sut.handle(
    new MemberJoinedEvent({ gameSessionId: 'gs_1', displayName: 'Aelis' /* ... */ }),
  );
  expect(bus.execute).toHaveBeenCalledWith(
    expect.objectContaining({
      input: expect.objectContaining({
        gameSessionId: 'gs_1',
        systemKey: 'chat.system.member_joined',
        systemParams: { displayName: 'Aelis' },
      }),
    }),
  );
});
```

Repeat for the other three handlers. Total **4 specs**, one per event class. No filesystem / Prisma / Centrifugo — the subscribers are pure dispatchers and the `PostSystemMessageCommand` path is already covered by its own Stream-C handler spec.

### Step 2.3 — Module wiring

Add the four classes to `ChatModule.providers`. Verify with:

```bash
pnpm --filter @app/backend test --run system-message.subscriber
```

All 4 specs green.

### Step 2.4 — Integration regression

Add a third e2e spec under `apps/backend/test/integration/chat-system-messages.e2e-spec.ts` (~80 lines):

1. GM seeds a session; player accepts invite. Assert one row in `chat_message` with `kind=system`, `systemKey='chat.system.member_joined'`, `systemParams.displayName === player.displayName`.
2. Player leaves. Assert a second row with `chat.system.member_left`.
3. Player rolls + pushes via the dice API. Assert a third row with `chat.system.roll_pushed` and `systemParams` carrying the dp delta.

Mounts the full Nest app like the other chat e2e specs.

### Step 2.5 — Commit

```bash
git add apps/backend/src/modules/chat/events/system-message.subscriber.ts \
        apps/backend/src/modules/chat/events/system-message.subscriber.spec.ts \
        apps/backend/src/modules/chat/chat.module.ts \
        apps/backend/test/integration/chat-system-messages.e2e-spec.ts
git commit -m "feat(backend): chat system-message subscribers (member join/leave/kick + roll-pushed)"
```

**Exit criteria:** `pnpm --filter @app/backend test --run` green (chat module total = Stream-C 75 + 4 subscriber + 3 e2e ≈ 82); `pnpm --filter @app/backend lint` clean; `pnpm --filter @app/backend typecheck` clean.

---

## Task 3 — `@app/ui` chat atoms (5 leaf components)

**Owner agent:** `frontend-engineer`.

Five small components, each shipping `*.vue + *.stories.ts + *.spec.ts + index.ts`. Authoring order matches dependency order (each builds on the previous one or only on existing `@app/ui` atoms).

### Step 3.1 — `AppChatAvatar`

Wraps `AppPortrait` + a presence pip overlay. Props:

```typescript
defineProps<{
  src?: string | null;
  initials?: string;
  size?: 'sm' | 'md';
  presence?: 'online' | 'idle' | 'offline';
}>();
```

BEM root: `app-chat-avatar`. Modifiers: `app-chat-avatar--size-sm|md`, `app-chat-avatar--presence-online|idle|offline`. The pip is a `<span>` with `aria-label="online" / "idle" / "offline"` and `--brand-brass` for online, `--text-muted` for idle, transparent border-only for offline.

Spec covers: BEM root class, size modifier, presence label routing through `aria-label`. Story: matrix of sizes × presences.

### Step 3.2 — `AppChatConnectionPip`

Promote the existing `ConnectionPip` (if any — search `apps/web/app/components/` for `ConnectionPip*.vue`; if none, author from scratch). Props:

```typescript
defineProps<{
  status: 'connecting' | 'subscribed' | 'unrecoverable' | 'disconnected';
}>();
```

A 6px circle with `role="status"` and `aria-live="polite"`. Colours route through `--ok`, `--warn`, `--error`, `--text-muted`. Tooltip text via `:title="t('chat.connection.<status>')"` consumed at the SFC's `<i18n>` block (Task 5 hands the keys).

Spec covers: status-to-class routing, presence of `role="status"`. Story: 4 status variants in a row.

### Step 3.3 — `AppChatPresenceDot`

Atom split out from `AppChatAvatar` so the tab strip can render presence dots without dragging the portrait into the tab. Same colour routing as the avatar's pip. Props: `presence: 'online' | 'idle' | 'offline'`.

### Step 3.4 — `AppChatDayDivider`

Horizontal `role="separator"` with brass hairline + uppercase tracked label (e.g. `TODAY`, `YESTERDAY`, `MAY 16`). Props:

```typescript
defineProps<{
  label: string;
}>();
```

BEM root: `app-chat-day-divider`. Visual: `border-top: 1px solid var(--brand-brass-deep)` on both sides of the label, label is `font-family: 'Forum, serif'; letter-spacing: 0.16em; text-transform: uppercase`. Spec covers semantics (separator role) + label rendering. Story: 3 sample labels.

### Step 3.5 — `AppChatNewMessagesPill`

A "↓ N new messages" pill that the panel reveals when the user has scrolled away from the latest message. Props:

```typescript
defineProps<{
  count: number;
}>();
defineEmits<{ (e: 'click'): void }>();
```

Renders nothing when `count === 0`. Position is the consumer's responsibility (the panel mounts it absolutely above the composer). Reduced-motion variant: skip the slide-in transition when `prefers-reduced-motion: reduce` matches.

Spec covers: `count === 0` renders nothing; click emits; reduced-motion class toggle. Story: 1 / 3 / 99 counts; one story explicitly toggles reduced-motion via the addon parameter.

### Step 3.6 — Commit

```bash
git add packages/ui/src/components/AppChatAvatar \
        packages/ui/src/components/AppChatConnectionPip \
        packages/ui/src/components/AppChatPresenceDot \
        packages/ui/src/components/AppChatDayDivider \
        packages/ui/src/components/AppChatNewMessagesPill \
        packages/ui/src/index.ts
git commit -m "feat(ui): chat atoms — avatar / connection pip / presence dot / day divider / new-messages pill"
```

**Exit criteria:** 5 components × 4 files each = 20 new files; all specs green; Storybook a11y panel green; `pnpm --filter @app/ui audit` (the `every-new-component-has-the-four-file-shape` audit) passes.

---

## Task 4 — `AppChatMessage` + `AppChatComposer`

**Owner agent:** `frontend-engineer`.

### Step 4.1 — `AppChatMessage`

The heart of the chat surface. Four visual variants:

- `broadcast-author` — own broadcast message. Right-aligned. Background `--chat-bubble-author-bg`. Shows time + edited mark.
- `broadcast-other` — someone else's broadcast. Left-aligned. Background `--chat-bubble-other-bg`. Shows avatar + author name.
- `whisper` — author or recipient. Border `--chat-whisper-accent` with a lock glyph. Same left/right alignment rule as broadcast.
- `system` — centered single line. Foreground `--chat-system-fg`. Italic. No bubble. Renders the i18n key + params (consumer feeds the resolved string).

Props:

```typescript
defineProps<{
  variant: 'broadcast-author' | 'broadcast-other' | 'whisper' | 'system';
  authorDisplayName?: string;
  authorAvatarSrc?: string | null;
  authorPresence?: 'online' | 'idle' | 'offline';
  body?: string | null; // null for system
  systemLabel?: string; // resolved system message text, only when variant=system
  createdAtIso: string;
  editedAtIso?: string | null;
  deletedAtIso?: string | null;
  ownByMe: boolean;
  ownByGm: boolean; // gates "Delete" item visibility
  canEdit: boolean; // false past the edit window
  canDelete: boolean; // false on whispers if !ownByMe
  canBlock: boolean; // visible on whisper-other only
}>();
defineEmits<{
  (e: 'edit'): void;
  (e: 'delete'): void;
  (e: 'block'): void;
}>();
```

Renders an `<article role="article">` with accessible name "<author> at <time>" so screen readers can navigate message-by-message.

Kebab menu (uses `AppPopover` + `AppButton size="sm"`): Edit / Delete / Block, each shown only when its `can*` prop is true and gated on `ownByMe` / `ownByGm` per design doc §Stream D.

Edit / delete events bubble to the consumer (panel). Block emits "open block confirm" — the consumer wires `AppConfirm`.

**Critical:** for `variant === 'system'` the bubble layout is bypassed entirely and the row renders as a single centred line — no avatar, no kebab. Reduced-motion variant: skip the bubble fade-in on first paint when `prefers-reduced-motion: reduce`.

Spec covers (`AppChatMessage.spec.ts`):

- BEM root class per variant.
- `system` variant renders `systemLabel` and skips the bubble container.
- Kebab menu shows / hides Edit / Delete / Block per props.
- Emits `edit` / `delete` / `block` when respective items clicked.
- `deletedAtIso` truthy renders the soft-deleted placeholder ("Message deleted").
- `editedAtIso` truthy shows the edited mark on `broadcast-author` and `broadcast-other`.

Story: matrix of 4 variants × 2 widths (320 / 720) × deletedAt on/off.

### Step 4.2 — `AppChatComposer`

Multi-line text input with character counter and ⌘/Ctrl+Enter submit.

Props:

```typescript
defineProps<{
  modelValue: string;
  conversationKind: 'broadcast' | 'whisper';
  partnerDisplayName?: string; // shown in placeholder when whisper
  maxLength?: number; // default 4096 (matches OpenAPI)
  disabled?: boolean; // true when realtime status === 'unrecoverable'
}>();
defineEmits<{
  (e: 'update:modelValue', v: string): void;
  (e: 'submit'): void;
}>();
```

Placeholder text routes through i18n:

- `conversationKind === 'broadcast'` → `t('chat.composer.placeholder.broadcast')` ("Message everyone in the session…")
- `conversationKind === 'whisper'` → `t('chat.composer.placeholder.whisper', { name: partnerDisplayName })` ("Whisper to {name}…")

⌘/Ctrl+Enter submit binding lives in a `keydown.enter` handler that checks `e.metaKey || e.ctrlKey`. Plain `Enter` inserts a newline.

Counter renders `<span aria-live="polite">{{ value.length }} / {{ maxLength }}</span>`, switches to `--warn` colour at `>= maxLength - 64` and `--error` at `>= maxLength`. Submit button is `AppButton variant="primary"` and disables when `value.trim().length === 0`.

Spec covers:

- ⌘+Enter and Ctrl+Enter both emit `submit`.
- Plain Enter does NOT emit `submit` (inserts newline).
- Counter aria-live attribute present.
- Counter classes flip at the two thresholds.
- Submit disabled while value is whitespace-only.

Story: 4 stories — broadcast / whisper / near-limit / at-limit.

### Step 4.3 — Commit

```bash
git add packages/ui/src/components/AppChatMessage \
        packages/ui/src/components/AppChatComposer \
        packages/ui/src/index.ts
git commit -m "feat(ui): chat message (4 variants + kebab) + composer (⌘/Ctrl+Enter, char counter)"
```

**Exit criteria:** 2 components × 4 files = 8 new files; Vitest + Storybook a11y green; ⌘/Ctrl+Enter binding manually verified on macOS + Linux.

---

## Task 5 — `AppChatTab`, `AppChatTabStrip`, `AppWhisperPicker`

**Owner agent:** `frontend-engineer`.

### Step 5.1 — `AppChatTab`

A single tab pill (broadcast or whisper). Props:

```typescript
defineProps<{
  label: string;
  kind: 'broadcast' | 'whisper';
  unreadCount?: number;
  presence?: 'online' | 'idle' | 'offline'; // only on whisper
  active: boolean;
}>();
defineEmits<{ (e: 'select'): void; (e: 'close'): void }>();
```

Layout: presence dot (whisper only) + label + unread badge (uses existing `AppBadge`) + close `×` (whisper only; opens the kebab on broadcast where there's no close). Selected state mirrors `AppTab` styling but uses `--chat-whisper-accent` for the active underline on whisper tabs and `--brand-brass` on broadcast.

Spec covers: `kind === 'broadcast'` hides the close `×` and the presence dot; click anywhere emits `select`; click on `×` emits `close` without bubbling `select`.

### Step 5.2 — `AppChatTabStrip`

Horizontal scroll container. Up to 3 whisper tabs visible; the rest collapse into a `+N more` overflow chip that opens a popover with the remaining tabs. Trailing `+` button opens `AppWhisperPicker` via `defineEmits<{ (e: 'add'): void }>()`.

Props:

```typescript
defineProps<{
  tabs: ChatTabModel[]; // type below
  activeKey: string; // 'broadcast' or a membershipId
  visibleWhisperLimit?: number; // default 3
}>();
defineEmits<{
  (e: 'select', key: string): void;
  (e: 'close', key: string): void;
  (e: 'add'): void;
}>();
```

```typescript
export interface ChatTabModel {
  key: string; // 'broadcast' | membershipId
  label: string;
  kind: 'broadcast' | 'whisper';
  unreadCount: number;
  presence?: 'online' | 'idle' | 'offline';
}
```

Type lives in `packages/ui/src/components/AppChatTabStrip/types.ts` and is re-exported from `index.ts`.

Spec covers: 5 whisper tabs render → 3 visible + 1 `+2 more` chip; the chip's popover renders the remaining 2; the `+` button emits `add`. Reduced-motion variant disables the slide-in animation on tab activation.

### Step 5.3 — `AppWhisperPicker`

Modal listing other members (those NOT already in the open whisper tabs and NOT blocked-by-me — filter is client-side; the server has no read of my block list filtered against pickable members).

Props:

```typescript
defineProps<{
  open: boolean;
  members: WhisperPickerMember[];
}>();
defineEmits<{
  (e: 'close'): void;
  (e: 'pick', membershipId: string): void;
}>();
```

```typescript
export interface WhisperPickerMember {
  membershipId: string;
  displayName: string;
  characterName?: string | null;
  presence: 'online' | 'idle' | 'offline';
  blockedByMe: boolean; // hidden if true
}
```

Renders an `AppModal` (existing) with a `role="listbox"` + arrow-key navigation + Enter to pick. Filters `blockedByMe === true` out of the rendered list (still in the props for testability).

Spec covers: blocked members do not render; arrow keys move focus across items; Enter on a focused item emits `pick`.

### Step 5.4 — Commit

```bash
git add packages/ui/src/components/AppChatTab \
        packages/ui/src/components/AppChatTabStrip \
        packages/ui/src/components/AppWhisperPicker \
        packages/ui/src/index.ts
git commit -m "feat(ui): chat tab + tab strip (3 visible + overflow) + whisper picker"
```

**Exit criteria:** 3 components × 4 files = 12 new files; specs green; a11y green; overflow + arrow-key navigation behaviours manually verified in Storybook.

---

## Task 6 — `AppChatPanel`

**Owner agent:** `frontend-engineer`.

The composition root. Owns layout (tab strip → message list → composer), the auto-scroll behaviour, the new-messages pill, and the connection pip slot. **Does not own state** — it's a pure presentational composite whose props come from the store consumer (Task 7).

Files: `packages/ui/src/components/AppChatPanel/{AppChatPanel.vue,AppChatPanel.stories.ts,AppChatPanel.spec.ts,index.ts,types.ts}`.

### Step 6.1 — Props + emits

```typescript
defineProps<{
  mode: 'primary' | 'docked';
  connectionStatus: 'connecting' | 'subscribed' | 'unrecoverable' | 'disconnected';
  tabs: ChatTabModel[];
  activeKey: string;
  messages: AppChatPanelMessage[]; // see types.ts
  composerValue: string;
  composerDisabled: boolean;
  newMessagesCount: number;
}>();
defineEmits<{
  (e: 'select-tab', key: string): void;
  (e: 'close-tab', key: string): void;
  (e: 'add-whisper'): void;
  (e: 'update:composer-value', v: string): void;
  (e: 'submit'): void;
  (e: 'edit-message', id: string): void;
  (e: 'delete-message', id: string): void;
  (e: 'block-author', id: string): void;
  (e: 'jump-to-newest'): void;
}>();
```

```typescript
// AppChatPanel/types.ts
export type AppChatPanelMessageVariant =
  | 'broadcast-author'
  | 'broadcast-other'
  | 'whisper'
  | 'system'
  | 'day-divider';
export interface AppChatPanelMessage {
  id: string;
  variant: AppChatPanelMessageVariant;
  payload: AppChatMessageProps | AppChatDayDividerProps;
  // Discriminated union narrowed by `variant`. AppChatMessageProps is the
  // exact prop shape of AppChatMessage; day-divider carries { label: string }.
}
```

### Step 6.2 — Layout

```pug
.app-chat-panel(:class="modeClass")
  header.app-chat-panel__head
    app-chat-tab-strip(...)
    app-chat-connection-pip(:status="connectionStatus")
  main.app-chat-panel__list(ref="listEl")
    template(v-for="m in messages" :key="m.id")
      app-chat-day-divider(v-if="m.variant === 'day-divider'" :label="m.payload.label")
      app-chat-message(v-else v-bind="m.payload" @edit="$emit('edit-message', m.id)" ... )
  app-chat-new-messages-pill(:count="newMessagesCount" @click="$emit('jump-to-newest')")
  footer.app-chat-panel__composer
    app-chat-composer(...)
```

Modifier class:

- `app-chat-panel--mode-primary` — fills the parent column. Header is full-width, list flex-1, composer sticky bottom.
- `app-chat-panel--mode-docked` — narrower (340px), collapsible. Tab strip becomes vertical-overflow scroll. Used in the GM Overview right-rail.

### Step 6.3 — Auto-scroll

`listEl`'s scroll behaviour:

1. On `messages` change (watcher), if the user was within 80px of the bottom before the change, scroll to bottom on next tick (`scrollTop = scrollHeight`).
2. If the user was further away, do not auto-scroll. The consumer's `newMessagesCount` prop becomes > 0 and the pill is rendered. Click on the pill emits `jump-to-newest` which the consumer responds to by zeroing `newMessagesCount` and the panel scrolls to bottom on the next `messages` watcher tick.
3. The 80px threshold is `--chat-autoscroll-threshold: 80px` (CSS custom property) so it can be tuned at the consumer level without prop drilling.

`prefers-reduced-motion: reduce` swaps `scroll-behavior: smooth` to `auto`.

### Step 6.4 — Spec

`AppChatPanel.spec.ts` covers:

- `mode` modifier class routing.
- Auto-scroll fires after `messages` updates when starting near bottom (assert `scrollTop` after `await nextTick()`).
- Auto-scroll suppressed when starting far from bottom.
- Pill renders only when `newMessagesCount > 0`.
- Tab strip events bubble (`select`, `close`, `add` → `select-tab`, `close-tab`, `add-whisper`).
- Composer events bubble (`update:modelValue` → `update:composer-value`, `submit` → `submit`).
- Message events bubble (`edit` → `edit-message`, `delete` → `delete-message`, `block` → `block-author`).
- Connection pip renders.

Story: 3 stories — `primary-broadcast` (50 broadcast messages + 2 whisper tabs), `primary-whisper` (active = a whisper tab), `docked-empty` (GM Overview right-rail, no messages yet).

### Step 6.5 — Commit

```bash
git add packages/ui/src/components/AppChatPanel \
        packages/ui/src/index.ts
git commit -m "feat(ui): chat panel composition root (primary + docked modes, auto-scroll, pill)"
```

**Exit criteria:** 1 component × 5 files = 5 new files (the types.ts is the +1); specs green; Storybook a11y green on all 3 panel stories; manual jump-to-newest behaviour verified across both modes.

---

## Task 7 — Web Pinia store + chat realtime composable

**Owner agent:** `frontend-engineer`.

### Step 7.1 — `useSessionChatRealtime` composable

`apps/web/app/composables/useSessionChatRealtime.ts` mirrors `useSessionRealtime.ts` but subscribes the two chat channel families. Imports:

```typescript
import { Centrifuge, type PublicationContext } from 'centrifuge';
import { issueRealtimeToken } from '@app/api-client-ts';
import type { ChatMessage } from '@app/api-client-ts';
```

Inputs:

```typescript
export function useSessionChatRealtime(opts: {
  gameSessionId: Ref<string>;
  myMembershipId: Ref<string>;
}): {
  status: Ref<'connecting' | 'subscribed' | 'unrecoverable' | 'disconnected'>;
  lastPosted: Ref<ChatMessage | null>;
  lastEdited: Ref<ChatMessage | null>;
  lastDeleted: Ref<{ id: string; targetMembershipId: string | null } | null>;
  start: () => Promise<void>;
  stop: () => Promise<void>;
};
```

Pattern: one `Centrifuge` client instance, two `subscribe(channelName)` calls — the broadcast channel and the per-member whisper channel. The `getToken` callback re-mints via `issueRealtimeToken`. Each `publication` handler dispatches by `payload.type` (Stream-C AsyncAPI uses `chat.message.posted` / `chat.message.edited` / `chat.message.deleted` per `packages/api-client-ts/src/realtime/channels.ts`).

Same lifecycle contract as `useSessionRealtime`: `start()` returns once subscribed; `stop()` unsubscribes both channels and closes the socket.

### Step 7.2 — `useChatStore` Pinia store

`apps/web/app/stores/chat.ts` — Pinia store factory keyed by sessionId (use `defineStore(\`chat:${sessionId}\`, ...)`pattern or, per repo convention, a single store keyed by`gameSessionId` field).

State:

```typescript
interface ChatState {
  gameSessionId: string | null;
  activeConversationKey: string; // 'broadcast' | membershipId
  conversations: Record<string, ConversationState>;
  conversationsList: ChatConversationSummary[]; // from GET /chat/conversations
  openWhisperKeys: string[]; // active whisper tab membershipIds
  myMembershipId: string | null;
  blockedByMe: Set<string>; // membershipIds I've blocked
}

interface ConversationState {
  messages: ChatMessage[]; // newest at the end
  nextCursor: string | null; // null = no more older history
  hasLoadedInitial: boolean;
  pendingSendIds: Set<string>; // client-side optimistic
  composerValue: string;
}
```

Actions:

- `async hydrate({ gameSessionId, myMembershipId })` — calls `listChatConversations`, `listBlocks` in parallel, seeds `conversationsList` + `blockedByMe`. Then for the active conversation key (default `'broadcast'`), calls `listChatMessages({ gameSessionId, query: { conversation: activeConversationKey }})` and seeds `conversations[active].messages` + `nextCursor`.
- `async loadOlder(conversationKey)` — appends `nextCursor` to the request; merges results to the front of the list.
- `async send(conversationKey, body)` — POST via `postChatMessage`. Optimistic: pushes a synthetic message with a `pending_` id into `messages` and into `pendingSendIds`. On 200, replaces the synthetic with the server message (matched by content + author + `createdAt` proximity, or simply by deleting the pending entry and waiting for the realtime echo). On error, rolls back and surfaces via a `useToast()` call.
- `async edit(messageId, body)` — `editChatMessage`. On success, the realtime echo updates the row.
- `async delete(messageId)` — `deleteChatMessage`. On 204, the realtime echo flips `deletedAt`.
- `async markRead(conversationKey, lastReadAt)` — `markChatConversationRead`. Debounced to fire at most every 2s (`lodash-es` `debounce` is already in the deps tree).
- `async block(targetMembershipId)` — `postBlock`. On success, add to `blockedByMe` + drop the conversation row from `conversationsList` + close the whisper tab if open.
- `async unblock(targetMembershipId)` — `deleteBlock`. On success, remove from `blockedByMe`.
- `openWhisper(membershipId)` — adds the key to `openWhisperKeys`, sets `activeConversationKey`, hydrates if no initial load yet.
- `closeWhisper(membershipId)` — removes from `openWhisperKeys`, falls back `activeConversationKey` to `'broadcast'` if it was the active one.
- `applyRealtime(event)` — branch on `event.type`:
  - `chat.message.posted` → push to the right conversation; if the user is not at the bottom of the active conversation, increment `newMessagesCount` (a derived getter).
  - `chat.message.edited` → patch the message in place.
  - `chat.message.deleted` → set `deletedAt` on the message.

Getters:

- `activeMessages` — `conversations[activeConversationKey]?.messages ?? []` with day-divider rows interleaved (client-side: group by `createdAt.toLocaleDateString()`).
- `activeNewMessagesCount` — count of messages added since the user last scrolled to bottom (the panel calls a `markAsAtBottom()` action when its watcher detects the user is near the bottom, which zeroes the counter).
- `panelTabs` — derived `ChatTabModel[]` for the tab strip (broadcast + each open whisper).

### Step 7.3 — Spec

`apps/web/app/stores/chat.spec.ts` — covers store actions in isolation against a mocked SDK (vitest's `vi.mock('@app/api-client-ts', ...)`). Minimum 12 specs:

1. `hydrate` seeds conversations + blockedByMe.
2. `send` pushes an optimistic message + replaces on 200.
3. `send` rolls back on error.
4. `delete` triggers SDK call.
5. `applyRealtime` of `chat.message.posted` appends to the right conversation.
6. `applyRealtime` of `chat.message.edited` updates in place.
7. `applyRealtime` of `chat.message.deleted` flips `deletedAt`.
8. `block` removes the whisper from the open tabs.
9. `markRead` debounces (`vi.useFakeTimers`).
10. `openWhisper` switches the active key.
11. `closeWhisper` falls back to broadcast if closing the active whisper.
12. `applyRealtime` of `posted` increments `newMessagesCount` when the user is not at bottom.

### Step 7.4 — Commit

```bash
git add apps/web/app/composables/useSessionChatRealtime.ts \
        apps/web/app/stores/chat.ts \
        apps/web/app/stores/chat.spec.ts
git commit -m "feat(web): chat Pinia store + Centrifugo subscription composable"
```

**Exit criteria:** Vitest green on the 12 store specs; lint + typecheck clean.

---

## Task 8 — Web mount points + i18n

**Owner agent:** `frontend-engineer`.

### Step 8.1 — Player route mount

Modify `apps/web/app/pages/app/sessions/[id].vue`:

1. Replace the `<div class="session-player__chat-placeholder">` (around line 134 per Stream B's plan) with `<AppChatPanel mode="primary" v-bind="chatPanelBindings" @select-tab="…" … />`.
2. Import the store + composable inside `<script setup>`:
   ```ts
   import { useChatStore } from '~/app/stores/chat';
   import { useSessionChatRealtime } from '~/app/composables/useSessionChatRealtime';
   const chatStore = useChatStore();
   const chatRealtime = useSessionChatRealtime({ gameSessionId, myMembershipId });
   onMounted(async () => {
     await chatStore.hydrate({ gameSessionId, myMembershipId });
     await chatRealtime.start();
   });
   onUnmounted(() => {
     chatRealtime.stop();
   });
   watch(
     chatRealtime.lastPosted,
     (m) => m && chatStore.applyRealtime({ type: 'chat.message.posted', message: m }),
   );
   // … same for edited / deleted
   ```
3. `chatPanelBindings` is a `computed` that maps the store getters to `AppChatPanel` props (tabs / activeKey / messages / connectionStatus / composerValue / newMessagesCount).
4. Wire `@submit` to `chatStore.send(activeKey, composerValue)`; `@select-tab` to `chatStore.activeConversationKey = key`; `@close-tab` to `chatStore.closeWhisper(key)`; `@add-whisper` to opening the `AppWhisperPicker`; `@edit-message` to opening an inline edit (composer pre-filled); `@delete-message` to opening `AppConfirm` then calling `chatStore.delete(id)`; `@block-author` to opening `AppConfirm` then `chatStore.block(authorMembershipId)`.

### Step 8.2 — GM route mount

Modify `apps/web/app/pages/app/game-sessions/[id].vue`:

1. Add a right-rail `<AppChatPanel mode="docked" />` inside the Overview tab, collapsible behind an `AppButton variant="ghost"` toggle.
2. Persist the collapsed state via `PATCH /me/settings` (the `chatDockedCollapsed` key already exists per Stream B's settings schema — verify before re-adding). The toggle calls `useUserSettingsStore().patch({ chatDockedCollapsed: !current })`.
3. Same realtime + store wiring as Step 8.1, parameterised by the GM's membershipId.

### Step 8.3 — i18n keys

`chat.*` namespace in the SFC `<i18n lang="json">` blocks of `[id].vue` (player) and `[id].vue` (GM). Keys (both `en` and `ru`):

```
chat.connection.connecting          "Connecting…"           / "Подключение…"
chat.connection.subscribed          "Live"                  / "Онлайн"
chat.connection.unrecoverable       "Reconnecting"          / "Переподключение"
chat.connection.disconnected        "Offline"               / "Не в сети"
chat.composer.placeholder.broadcast "Message everyone…"     / "Написать всем…"
chat.composer.placeholder.whisper   "Whisper to {name}…"    / "Шёпотом к {name}…"
chat.composer.counter               "{count} / {max}"       / "{count} / {max}"
chat.new_messages.pill              "{count, plural, one {# new message} other {# new messages}} ↓"
                                                            "{count, plural, one {# новое сообщение} few {# новых сообщения} many {# новых сообщений} other {# новых сообщений}} ↓"
chat.tabs.broadcast                 "Everyone"              / "Все"
chat.tabs.add_whisper               "Whisper"               / "Шёпот"
chat.tabs.overflow                  "+{count} more"         / "+{count} ещё"
chat.message.edited                 "edited"                / "изм."
chat.message.deleted                "Message deleted"       / "Сообщение удалено"
chat.message.menu.edit              "Edit"                  / "Изменить"
chat.message.menu.delete            "Delete"                / "Удалить"
chat.message.menu.block             "Block in this session" / "Заблокировать в этой сессии"
chat.block.confirm.title            "Block {name}?"         / "Заблокировать {name}?"
chat.block.confirm.body             "{name} won't be able to whisper you in this session. Existing history stays."
                                                            "{name} не сможет писать вам шёпотом в этой сессии. Существующая история останется видимой."
chat.block.confirm.confirm          "Block"                 / "Заблокировать"
chat.whisper_picker.title           "Whisper to…"           / "Кому шепнуть"
chat.whisper_picker.empty           "No one available."     / "Нет доступных участников."
chat.system.member_joined           "{displayName} joined the session." / "{displayName} вошёл в сессию."
chat.system.member_left             "{displayName} left the session."   / "{displayName} вышел из сессии."
chat.system.member_kicked           "{displayName} was removed."        / "{displayName} удалён из сессии."
chat.system.roll_pushed             "{characterName} pushed the roll ({pushedCount} dice, +{dpDelta} DP)."
                                                                         "{characterName} перебросил ({pushedCount} кубов, +{dpDelta} DP)."
chat.system.encounter_started       "Encounter started."                / "Столкновение началось."
chat.system.round_advanced          "Round {round}."                    / "Раунд {round}."
chat.system.encounter_ended         "Encounter ended."                  / "Столкновение завершено."
```

`pnpm check:i18n` parity must pass.

### Step 8.4 — Commit

```bash
git add apps/web/app/pages/app/sessions/[id].vue \
        apps/web/app/pages/app/game-sessions/[id].vue
git commit -m "feat(web): mount chat panel on player + GM routes; chat.* i18n keys (EN + RU)"
```

**Exit criteria:** `pnpm check:i18n` green; manual smoke — open two browsers, GM + player, exchange broadcast + whisper, verify realtime delivery + new-messages pill.

---

## Task 9 — Mobile chat widgets + i18n + bottom-tab integration

**Owner agent:** `flutter-engineer`.

### Step 9.1 — Widget tree

Create `apps/mobile/lib/features/sessions/presentation/widgets/chat/`:

- `chat_panel.dart` — `class ChatPanel extends StatefulWidget`. Owns the scroll controller + auto-scroll behaviour. Reads state from `BlocBuilder<ChatBloc, ChatState>`.
- `chat_tab_strip.dart` — horizontal scroll, 3 visible whisper tabs + overflow chip, `+` button opens `WhisperPickerSheet`.
- `chat_message.dart` — same four variants as web. Centered system variant skips the bubble. Renders `Container` with `BoxDecoration` colours from a `ChatTokens` Dart class generated from `specs/design/tokens/color.json` (already wired by `pnpm design:build` for the existing tokens — extend the generator's allow-list if it filters by group).
- `chat_composer.dart` — `TextField` with a `TextEditingController`; submit on `LogicalKeyboardKey.enter` + `RawKeyEvent.isMetaPressed || isControlPressed`. Submit button calls `HapticFeedback.lightImpact()` on tap.
- `whisper_picker_sheet.dart` — modal bottom sheet (`showModalBottomSheet`); `ListView` of pickable members; filters `blockedByMe`.

### Step 9.2 — Mobile `ChatBloc`

`apps/mobile/lib/features/sessions/presentation/blocs/chat/chat_bloc.dart` + `chat_event.dart` + `chat_state.dart`.

States: `ChatInitial`, `ChatLoading`, `ChatReady({ activeKey, conversations, conversationsList, blockedByMe, openWhisperKeys, newMessagesCount, connectionStatus, composerValue, myMembershipId })`, `ChatError`.

Events (mirror the Pinia store actions): `ChatHydrated`, `ChatRealtimeReceived(ChatMessage | { id, deletedAt })`, `ChatMessageSent`, `ChatMessageEdited`, `ChatMessageDeleted`, `ChatConversationSelected`, `ChatWhisperOpened`, `ChatWhisperClosed`, `ChatMemberBlocked`, `ChatMemberUnblocked`, `ChatMarkRead`.

The bloc uses `get_it`-registered `ChatRepository` (calls the generated Dart client) and `ChatRealtimeService` (Centrifugo Dart subscription mirroring `useSessionChatRealtime`).

### Step 9.3 — Bottom-tab integration

Modify `apps/mobile/lib/features/sessions/presentation/pages/player_session_detail_page.dart`:

1. Replace the body with a `Scaffold` whose `bottomNavigationBar` is `BottomNavigationBar(items: [Chat | Encounter | Me])`. Chat is index 0 (leftmost = most-touched, per `PHASE_8_DESIGN_NOTES.md` §4 referenced in the design doc).
2. `HapticFeedback.selectionClick()` on tab change.
3. Replace the "content will be wired up in Stream D" + the "Encounter coming in Stream D" placeholder lines.
4. The Chat tab body is `ChatPanel(gameSessionId: …)`; the Encounter tab body keeps the existing placeholder (Encounter UI is not Stream D scope); the Me tab links to the character sheet — reuse the existing route.

### Step 9.4 — Widget tests

`apps/mobile/test/features/sessions/presentation/widgets/chat/`:

- `chat_message_test.dart` — 4 variant golden tests + a "system variant has no bubble" semantic check.
- `chat_composer_test.dart` — ⌘/Ctrl+Enter submit; counter aria.
- `chat_tab_strip_test.dart` — overflow chip appears at 4+ whispers.
- `whisper_picker_sheet_test.dart` — blocked members filtered out.

`apps/mobile/test/features/sessions/presentation/blocs/chat/chat_bloc_test.dart` — at least 6 specs mirroring the Pinia store specs (hydrate, send, realtime apply, block, open / close whisper, mark-read debounce).

### Step 9.5 — i18n

Create `apps/mobile/lib/i18n/chat_en.i18n.json`, `chat_ru.i18n.json`, `chat_uk.i18n.json` mirroring the keys in Task 8.3. Register with the existing `slang` / `easy_localization` setup (look at how `auth_en.i18n.json` is registered — same pattern).

### Step 9.6 — Commit

```bash
git add apps/mobile/lib/features/sessions/presentation/widgets/chat \
        apps/mobile/lib/features/sessions/presentation/blocs/chat \
        apps/mobile/lib/features/sessions/presentation/pages/player_session_detail_page.dart \
        apps/mobile/lib/i18n/chat_en.i18n.json \
        apps/mobile/lib/i18n/chat_ru.i18n.json \
        apps/mobile/lib/i18n/chat_uk.i18n.json \
        apps/mobile/test
git commit -m "feat(mobile): chat panel widgets + bloc + bottom-nav integration + i18n"
```

**Exit criteria:** `flutter analyze lib` clean; `flutter test` green (existing + new); `pnpm check:i18n` green (parity across web + mobile locales); golden files committed.

---

## Task 10 — Block-UI affordance (web + mobile)

**Owner agent:** `frontend-engineer` for web; `flutter-engineer` for mobile.

The per-session block REST routes and the 403 enforcement on `PostChatMessageCommand` ship in Stream C. Stream D adds:

### Step 10.1 — Web

1. In `AppChatMessage`'s kebab, add "Block in this session" → opens `AppConfirm` (existing modal). On confirm, `chatStore.block(authorMembershipId)`.
2. `AppWhisperPicker` filters `blockedByMe`, already done in Task 5.3 by passing the prop — wire `chatStore.blockedByMe` into the picker open.
3. When blocking succeeds and a whisper conversation is open with the blocked member, close that whisper tab (already handled in Task 7.2's `block` action).
4. Existing whisper history with a blocked member must remain readable per design doc — the action only filters future + picker visibility, not historical messages.

### Step 10.2 — Mobile

Same three behaviours via `WhisperPickerSheet` + a `showModalBottomSheet` confirm. The "Block in this session" affordance lives in a long-press menu on a `ChatMessage` widget (long-press is the mobile-idiomatic equivalent of the web kebab).

### Step 10.3 — Commit

```bash
git add packages/ui/src/components/AppChatMessage \
        apps/web/app/pages/app/sessions/[id].vue \
        apps/web/app/pages/app/game-sessions/[id].vue \
        apps/mobile/lib/features/sessions/presentation/widgets/chat
git commit -m "feat(web,mobile): block-in-session affordance + confirm + picker filter"
```

**Exit criteria:** Vitest green for the updated `AppChatMessage.spec.ts` (Block menu item visibility); `flutter test` green; manual smoke — block a whisper partner, verify (a) future POST returns 403 from backend, (b) picker hides them, (c) existing history remains readable.

---

## Task 11 — a11y + reduced-motion sweep

**Owner agent:** `frontend-engineer`.

Storybook `addon-a11y` panel should already be green per Tasks 3–6. This task is an audit pass + capturing any gaps:

- Run `pnpm --filter @app/ui storybook` and walk every chat story; the a11y panel must report 0 violations on all 11 components.
- Reduced-motion variants verified on `AppChatNewMessagesPill` (slide-in disabled), `AppChatTab` activation (slide disabled), `AppChatMessage` (fade-in disabled), `AppChatPanel` auto-scroll (`smooth` → `auto`).
- ⌘/Ctrl+Enter submit confirmed in both `AppChatComposer.spec.ts` and via a manual smoke in the Storybook story.
- Mobile haptics fire on tab change (`HapticFeedback.selectionClick`) and on send (`HapticFeedback.lightImpact`) — verified on the iOS simulator at least once.

Outputs:

- Update `docs/superpowers/decisions.md` (if it exists; otherwise skip) with a single entry: "Chat reduced-motion: respects `prefers-reduced-motion: reduce` across pill, tab activation, message fade, and scroll-behaviour."
- Optionally extend `apps/web/test/e2e/chat-a11y.e2e-spec.ts` (Playwright, if Playwright is wired — verify) with a single `axe.run()` against the mounted player chat panel.

### Step 11.1 — Commit (if anything changed)

```bash
git add packages/ui/src apps/web docs
git commit -m "chore(ui): chat a11y + reduced-motion sweep — Storybook a11y panel green on 11 components"
```

If no diff, skip this commit.

**Exit criteria:** a11y panel green on all chat Storybook stories; reduced-motion variants visually verified.

---

## Task 12 — Integration / smoke regressions

**Owner agent:** main agent (test orchestration).

### Step 12.1 — Web integration test

Add `apps/web/test/integration/chat.spec.ts` (Vitest + happy-dom, no Playwright dependency):

1. Stubs `@app/api-client-ts` SDK + Centrifuge client.
2. Mounts `apps/web/app/pages/app/sessions/[id].vue` via `@nuxt/test-utils` (`mountSuspended` or similar).
3. Asserts:
   - Initial hydrate populates the broadcast tab.
   - Sending via the composer triggers `postChatMessage` once + appends an optimistic row.
   - Realtime `chat.message.posted` for the broadcast channel appends the server message.
   - Receiving a whisper for a non-open membershipId auto-opens a whisper tab.
   - GM mount uses `mode="docked"` (assert the BEM modifier class).

### Step 12.2 — Mobile integration test

`apps/mobile/integration_test/chat_integration_test.dart` — boots the app with a faked `ChatRepository` + `ChatRealtimeService`, navigates to `player_session_detail_page`, sends a broadcast, verifies the message renders + haptic fired (`HapticFeedback.lightImpact` tracked via `IntegrationTestWidgetsFlutterBinding`).

### Step 12.3 — Manual smoke recipe

Document in PR description:

```sh
# 1. GM seeds invite + accepts as Player.
# 2. Player opens /app/sessions/<id> in browser, GM opens /app/game-sessions/<id>.
# 3. Player + GM each see "Live" connection pip.
# 4. Player posts broadcast — appears on both clients < 500ms.
# 5. Player opens whisper to GM — chat tab strip shows two tabs on each side.
# 6. Player whispers GM — both sides see it on the whisper channel; bystander client (open a 3rd browser as Player B if seeding allows) sees nothing on the broadcast tab.
# 7. GM tries Delete on a player's whisper — kebab Delete item not present (canDelete=false). Confirmed.
# 8. Player blocks GM via kebab on a whisper. Player attempts another whisper to GM — backend returns 403; web surfaces "this member is not accepting messages" toast.
# 9. Player rolls + pushes a die via the dice roller → broadcast tab gets a `chat.system.roll_pushed` row on both clients.
# 10. Mobile: same flow on the iOS simulator. Haptic on tab change + send.
```

### Step 12.4 — Commit

```bash
git add apps/web/test/integration/chat.spec.ts \
        apps/mobile/integration_test/chat_integration_test.dart
git commit -m "test(web,mobile): chat integration regressions + smoke recipe"
```

**Exit criteria:** Full test sweep green across `pnpm --filter @app/backend test`, `pnpm --filter @app/ui test`, `pnpm --filter @app/web test`, `flutter test`. Typecheck + lint clean.

---

## Task 13 — Archive + PR

**Owner agent:** main agent (no subagent).

- [ ] Move `T-2026-05-16-PHASE-8-STREAM-D` entry from `specs/tasks/active.md` to top of `specs/tasks/done.md` with PR link, commit list, test counts, and any open follow-ups (e.g. chat search; reactions; Redis-backed rate limiter — same list Stream C left).
- [ ] `git push -u origin feat/phase-8/stream-d-chat-ui`.
- [ ] Open Forgejo PR via `gh pr create` (per CLAUDE.md — `gh` is available; Forgejo at `code.homelab.local`).
- [ ] Final commit: `chore(tasks): archive Stream D`.

---

## Self-review checklist (run before dispatching to subagents)

1. **Spec coverage** — every bullet in `docs/IMPLEMENTATION_PLAN_PHASE_8.md` §11.5, §11.6.2.d, §11.6.3, §11.7 has a task above. ✅
2. **Component-shape audit ready** — every new `@app/ui` component has the four-file shape declared (`*.vue + *.stories.ts + *.spec.ts + index.ts`); `AppChatTabStrip` and `AppChatPanel` additionally ship `types.ts`. ✅
3. **No spec change** — OpenAPI + AsyncAPI stay at the Stream-C versions. ✅
4. **No hex literals in components** — all colour comes from `--chat-*` / `--brand-*` / `--surface-*` / `--text-*` custom properties. ✅
5. **Deferred to Stream E** — `characterIds` array removal, Crew tab empty-state. Explicitly NOT in this plan. ✅
6. **Deferred outside Phase 8** — chat search, reactions, Redis-backed rate limiter, deep-link host. Explicitly NOT in this plan. ✅
7. **Block workflow** — each Task lands on its own commit on `feat/phase-8/stream-d-chat-ui`. Final PR opened in Task 13. ✅
