import AppIconMedallion from './AppIconMedallion.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

/**
 * The Nine Icons of the Third Horizon (handoff `primitives.jsx:L244-L254`).
 * Mirrored here so stories can sweep across the full set without pulling a
 * runtime constant out of the brand package.
 */
const NINE_ICONS = [
  { letter: 'L', name: 'The Lady of Tears' },
  { letter: 'T', name: 'The Traveler' },
  { letter: 'M', name: 'The Messenger' },
  { letter: 'C', name: 'The Merchant' },
  { letter: 'D', name: 'The Dancer' },
  { letter: 'G', name: 'The Gambler' },
  { letter: 'J', name: 'The Judge' },
  { letter: 'F', name: 'The Faceless One' },
  { letter: 'H', name: 'The Deckhand' },
] as const;

const meta: Meta<typeof AppIconMedallion> = {
  title: 'Coriolis/AppIconMedallion',
  component: AppIconMedallion,
  tags: ['autodocs'],
  argTypes: {
    letter: { control: { type: 'text' } },
    size: { control: { type: 'number', min: 24, max: 160, step: 4 } },
    glow: { control: { type: 'boolean' } },
    label: { control: { type: 'text' } },
  },
  args: {
    letter: 'T',
    size: 64,
    glow: false,
    label: 'The Traveler',
  },
  parameters: {
    docs: {
      description: {
        component:
          'Coriolis Icon medallion — radial-gradient brass disc + 16 astrolabe ticks + Forum monogram letter, used by the wizard Icon-pick step and any "chosen Icon" hero treatment. Set `glow` to mark the selected Icon in the picker grid.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppIconMedallion>;

const bg = (theme: 'dark' | 'light' = 'dark'): string => {
  const surface = theme === 'dark' ? 'var(--surface-void)' : 'var(--surface-parchment)';
  return `padding:48px;background:${surface};display:inline-flex;align-items:center;gap:24px;flex-wrap:wrap;`;
};

// ── Default ─────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — Traveler / 64',
  render: (args) => ({
    components: { AppIconMedallion },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg()}">
        <AppIconMedallion v-bind="args" />
      </div>
    `,
  }),
};

// ── Glow (selected in wizard) ───────────────────────────────────────────────

export const Glow: Story = {
  name: 'Glow — selected in the wizard picker',
  args: { letter: 'F', size: 60, glow: true, label: 'The Faceless One' },
  render: (args) => ({
    components: { AppIconMedallion },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg()}">
        <AppIconMedallion v-bind="args" />
      </div>
    `,
  }),
};

// ── Size sweep ──────────────────────────────────────────────────────────────

export const SizeSweep: Story = {
  name: 'Size sweep — 48 / 56 / 60 / 64',
  render: () => ({
    components: { AppIconMedallion },
    setup() {
      return { sizes: [48, 56, 60, 64] as const };
    },
    template: `
      <div style="${bg()}">
        <div v-for="s in sizes" :key="s" style="display:flex;flex-direction:column;gap:6px;align-items:center;">
          <AppIconMedallion letter="T" :size="s" label="The Traveler" />
          <span style="font-family:Inter,sans-serif;font-size:11px;color:var(--text-secondary);">size = {{ s }}px</span>
        </div>
      </div>
    `,
  }),
};

// ── The Nine — wizard picker grid ───────────────────────────────────────────

export const TheNine: Story = {
  name: 'The Nine — full picker grid',
  render: () => ({
    components: { AppIconMedallion },
    setup() {
      return { icons: NINE_ICONS };
    },
    template: `
      <div style="padding:48px;background:var(--surface-void);display:grid;grid-template-columns:repeat(3,auto);gap:32px;justify-items:center;">
        <div v-for="icon in icons" :key="icon.letter" style="display:flex;flex-direction:column;gap:10px;align-items:center;">
          <AppIconMedallion :letter="icon.letter" :size="60" :label="icon.name" />
          <span style="font-family:Forum,serif;font-size:14px;color:var(--brand-brass-light);letter-spacing:0.04em;text-align:center;">{{ icon.name }}</span>
        </div>
      </div>
    `,
  }),
};

// ── The Nine — picker grid with one selected ────────────────────────────────

export const TheNineSelected: Story = {
  name: 'The Nine — one selected (glow)',
  render: () => ({
    components: { AppIconMedallion },
    setup() {
      return { icons: NINE_ICONS, selected: 'T' };
    },
    template: `
      <div style="padding:48px;background:var(--surface-void);display:grid;grid-template-columns:repeat(3,auto);gap:32px;justify-items:center;">
        <div v-for="icon in icons" :key="icon.letter" style="display:flex;flex-direction:column;gap:10px;align-items:center;">
          <AppIconMedallion :letter="icon.letter" :size="60" :glow="icon.letter === selected" :label="icon.name" />
          <span style="font-family:Forum,serif;font-size:14px;color:var(--brand-brass-light);letter-spacing:0.04em;text-align:center;">{{ icon.name }}</span>
        </div>
      </div>
    `,
  }),
};

// ── On parchment (share-viewer surface) ─────────────────────────────────────

export const OnParchment: Story = {
  name: 'On parchment — share-viewer surface',
  render: () => ({
    components: { AppIconMedallion },
    template: `
      <div style="${bg('light')}">
        <AppIconMedallion letter="J" :size="64" label="The Judge" />
      </div>
    `,
  }),
};

// ── Reduced motion ──────────────────────────────────────────────────────────

export const ReducedMotion: Story = {
  name: 'Reduced motion — halo stays static',
  args: { letter: 'F', size: 64, glow: true, label: 'The Faceless One' },
  parameters: { pseudo: { reducedMotion: 'reduce' } },
  render: (args) => ({
    components: { AppIconMedallion },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg()}">
        <AppIconMedallion v-bind="args" />
      </div>
    `,
  }),
};
