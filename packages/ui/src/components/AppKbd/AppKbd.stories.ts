import AppKbd from './AppKbd.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const SIZES = ['sm', 'md'] as const;

const meta: Meta<typeof AppKbd> = {
  title: 'Primitives/AppKbd',
  component: AppKbd,
  tags: ['autodocs'],
  argTypes: {
    keys: { control: 'object' },
    size: { control: 'select', options: SIZES },
  },
  args: {
    keys: 'N',
    size: 'md',
  },
};

export default meta;

type Story = StoryObj<typeof AppKbd>;

// ── Single key ────────────────────────────────────────────────────────────────

export const SingleKey: Story = {
  name: 'Single Key — N',
  args: { keys: 'N' },
  render: (args) => ({
    components: { AppKbd },
    setup() {
      return { args };
    },
    template: `<div style="padding: 24px;"><AppKbd v-bind="args" /></div>`,
  }),
};

// ── Combo keys: Ctrl + K ─────────────────────────────────────────────────────

export const ComboKeys: Story = {
  name: 'Combo Keys — Ctrl + K',
  args: { keys: ['Ctrl', 'K'] },
  render: (args) => ({
    components: { AppKbd },
    setup() {
      return { args };
    },
    template: `<div style="padding: 24px;"><AppKbd v-bind="args" /></div>`,
  }),
};

// ── Sizes ─────────────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes',
  render: () => ({
    components: { AppKbd },
    setup() {
      return { sizes: SIZES };
    },
    template: `
      <div style="display: flex; gap: var(--space-4); align-items: center; padding: 24px;">
        <AppKbd v-for="s in sizes" :key="s" keys="N" :size="s" />
      </div>
    `,
  }),
};

// ── Modifiers Row ─────────────────────────────────────────────────────────────

export const Modifiers: Story = {
  name: 'Modifiers Row — Cmd / Shift / Alt / Ctrl',
  render: () => ({
    components: { AppKbd },
    template: `
      <div style="display: flex; gap: var(--space-3); align-items: center; padding: 24px; flex-wrap: wrap;">
        <AppKbd keys="Cmd" />
        <AppKbd keys="Shift" />
        <AppKbd keys="Alt" />
        <AppKbd keys="Ctrl" />
      </div>
    `,
  }),
};

// ── Symbols ───────────────────────────────────────────────────────────────────

export const Symbols: Story = {
  name: 'Symbols — ⏎ / ⌘ / ⌥ / ⌫',
  render: () => ({
    components: { AppKbd },
    template: `
      <div style="display: flex; gap: var(--space-3); align-items: center; padding: 24px; flex-wrap: wrap;">
        <AppKbd keys="⏎" />
        <AppKbd keys="⌘" />
        <AppKbd keys="⌥" />
        <AppKbd keys="⌫" />
        <AppKbd keys="?" />
      </div>
    `,
  }),
};

// ── Three-key combo ───────────────────────────────────────────────────────────

export const ThreeKeyCombo: Story = {
  name: 'Three-Key Combo — Ctrl + Shift + P',
  args: { keys: ['Ctrl', 'Shift', 'P'] },
  render: (args) => ({
    components: { AppKbd },
    setup() {
      return { args };
    },
    template: `<div style="padding: 24px;"><AppKbd v-bind="args" /></div>`,
  }),
};

// ── Combat tracker shortcuts overlay (usage in context) ───────────────────────

export const CombatTrackerOverlay: Story = {
  name: 'Combat Tracker Shortcuts Overlay',
  render: () => ({
    components: { AppKbd },
    template: `
      <div style="background: var(--surface-night); border: 1px solid var(--brand-brass-deep); border-radius: 4px; padding: 20px; max-width: 360px; display: flex; flex-direction: column; gap: 12px;">
        <div style="font-family: var(--type-display-sm-font-family); font-size: 16px; color: var(--brand-brass-light); text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 4px;">Keyboard Shortcuts</div>
        <div v-for="row in shortcuts" :key="row.label" style="display: flex; align-items: center; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid rgba(166,124,40,0.2);">
          <span style="font-family: var(--type-body-sm-font-family); font-size: 13px; color: var(--text-secondary);">{{ row.label }}</span>
          <AppKbd :keys="row.keys" size="sm" />
        </div>
      </div>
    `,
    setup() {
      return {
        shortcuts: [
          { label: 'Next turn', keys: 'N' },
          { label: 'End round', keys: 'R' },
          { label: 'Damage focused', keys: 'D' },
          { label: 'Show shortcuts', keys: '?' },
          { label: 'Quick jump', keys: ['Ctrl', 'K'] },
          { label: 'Escape / close', keys: '⎋' },
        ],
      };
    },
  }),
};

// ── Sm size all single keys ───────────────────────────────────────────────────

export const SmSingleKeys: Story = {
  name: 'Sm Size — Single Keys',
  render: () => ({
    components: { AppKbd },
    template: `
      <div style="display: flex; gap: var(--space-2); align-items: center; padding: 24px; flex-wrap: wrap;">
        <AppKbd v-for="k in keys" :key="k" :keys="k" size="sm" />
      </div>
    `,
    setup() {
      return { keys: ['N', 'R', 'D', '?', '⏎', '⌘', 'Esc'] };
    },
  }),
};
