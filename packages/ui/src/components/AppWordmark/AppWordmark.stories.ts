import AppWordmark from './AppWordmark.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppWordmark> = {
  title: 'Coriolis/AppWordmark',
  component: AppWordmark,
  tags: ['autodocs'],
  argTypes: {
    size: { control: { type: 'number', min: 24, max: 160, step: 4 } },
    brand: { control: { type: 'text' } },
    eyebrow: { control: { type: 'text' } },
  },
  args: {
    size: 48,
    brand: 'Coriolis',
    eyebrow: 'Companion',
  },
  parameters: {
    docs: {
      description: {
        component:
          'Brand wordmark lockup — Forum "Coriolis" uppercase + brass swash + Inter "Companion" eyebrow. The `size` prop drives the brand font-size in CSS pixels; the eyebrow scales at `size × 0.18` and the swash at `size × 2.4`. Handoff defaults: 48 (compact), 88 (landing hero).',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppWordmark>;

const bg =
  'padding:48px;background:var(--surface-void);display:inline-flex;flex-direction:column;gap:32px;';

// ── Default ─────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — size 48',
  args: { size: 48 },
  render: (args) => ({
    components: { AppWordmark },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg}">
        <AppWordmark v-bind="args" />
      </div>
    `,
  }),
};

// ── Landing hero ────────────────────────────────────────────────────────────

export const LandingHero: Story = {
  name: 'Landing hero — size 88',
  args: { size: 88 },
  render: (args) => ({
    components: { AppWordmark },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg};padding:96px 48px;">
        <AppWordmark v-bind="args" />
      </div>
    `,
  }),
};

// ── Compact (session-join card) ─────────────────────────────────────────────

export const Compact: Story = {
  name: 'Compact — size 32',
  args: { size: 32 },
  render: (args) => ({
    components: { AppWordmark },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg}">
        <AppWordmark v-bind="args" />
      </div>
    `,
  }),
};

// ── Scale sweep ─────────────────────────────────────────────────────────────

export const ScaleSweep: Story = {
  name: 'Scale sweep — 32 / 48 / 64 / 88',
  render: () => ({
    components: { AppWordmark },
    setup() {
      return { sizes: [32, 48, 64, 88] as const };
    },
    template: `
      <div style="${bg};align-items:center;">
        <div v-for="s in sizes" :key="s" style="display:flex;flex-direction:column;gap:8px;align-items:center;">
          <AppWordmark :size="s" />
          <span style="font-family:Inter,sans-serif;font-size:11px;color:var(--text-secondary);">size = {{ s }}px</span>
        </div>
      </div>
    `,
  }),
};

// ── Localized eyebrow (i18n stress) ─────────────────────────────────────────

export const LocalizedEyebrow: Story = {
  name: 'Localized eyebrow — Cyrillic Companion',
  args: { size: 64, eyebrow: 'Спутник' },
  render: (args) => ({
    components: { AppWordmark },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg}">
        <AppWordmark v-bind="args" />
      </div>
    `,
  }),
};

// ── On parchment (share-viewer surface) ─────────────────────────────────────

export const OnParchment: Story = {
  name: 'On parchment — share-viewer surface',
  render: () => ({
    components: { AppWordmark },
    template: `
      <div style="padding:64px;background:var(--surface-parchment);">
        <AppWordmark :size="56" />
      </div>
    `,
  }),
};
