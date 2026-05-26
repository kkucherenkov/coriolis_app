import { ref } from 'vue';

import AppStatPair from './AppStatPair.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const TONES = ['brass', 'mystic'] as const;

const meta: Meta<typeof AppStatPair> = {
  title: 'Coriolis/AppStatPair',
  component: AppStatPair,
  tags: ['autodocs'],
  argTypes: {
    tone: { control: 'select', options: TONES },
    current: { control: { type: 'number', min: 0, max: 30 } },
    max: { control: { type: 'number', min: 1, max: 30 } },
    label: { control: 'text' },
    disabled: { control: 'boolean' },
  },
  args: {
    label: 'Hull',
    current: 8,
    max: 12,
    tone: 'brass',
    disabled: false,
  },
};

export default meta;

type Story = StoryObj<typeof AppStatPair>;

// ── Default — Hull 8 / 12 ─────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — Hull 8 / 12',
  args: {
    label: 'Hull',
    current: 8,
    max: 12,
    tone: 'brass',
  },
};

// ── Full ──────────────────────────────────────────────────────────────────────

export const Full: Story = {
  name: 'Full — Energy 8 / 8',
  args: {
    label: 'Energy',
    current: 8,
    max: 8,
    tone: 'brass',
  },
};

// ── Zero current ─────────────────────────────────────────────────────────────

export const Zero: Story = {
  name: 'Zero current — Hull 0 / 12',
  args: {
    label: 'Hull',
    current: 0,
    max: 12,
    tone: 'brass',
  },
};

// ── Mystic tone ───────────────────────────────────────────────────────────────

export const Mystic: Story = {
  name: 'Mystic — Shields 3 / 6',
  args: {
    label: 'Shields',
    current: 3,
    max: 6,
    tone: 'mystic',
  },
};

// ── Disabled ──────────────────────────────────────────────────────────────────

export const Disabled: Story = {
  name: 'Disabled — read-only',
  args: {
    label: 'Cargo',
    current: 4,
    max: 10,
    disabled: true,
  },
};

// ── Interactive panel (ship stats strip) ─────────────────────────────────────

export const ShipStatsStrip: Story = {
  name: 'Ship stats strip (interactive)',
  render: () => ({
    components: { AppStatPair },
    setup() {
      const hull = ref({ current: 8, max: 12 });
      const energy = ref({ current: 6, max: 8 });
      return { hull, energy };
    },
    template: `
      <div style="
        display: flex;
        gap: var(--space-8);
        padding: var(--space-6);
        background: var(--surface-night);
        border: 1px solid var(--brand-brass-deep);
        border-radius: var(--radius-md);
      ">
        <AppStatPair
          label="Hull"
          :current="hull.current"
          :max="hull.max"
          tone="brass"
          @update:current="hull.current = $event"
        />
        <AppStatPair
          label="Energy"
          :current="energy.current"
          :max="energy.max"
          tone="brass"
          @update:current="energy.current = $event"
        />
        <AppStatPair
          label="Shields"
          :current="3"
          :max="6"
          tone="mystic"
        />
      </div>
    `,
  }),
};
