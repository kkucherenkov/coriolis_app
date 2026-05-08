import AppDots from './AppDots.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const TONES = ['brass', 'mystic', 'crimson', 'darkness'] as const;
const SIZES = ['sm', 'md', 'lg'] as const;

const meta: Meta<typeof AppDots> = {
  title: 'Primitives/AppDots',
  component: AppDots,
  tags: ['autodocs'],
  argTypes: {
    tone: { control: 'select', options: TONES },
    size: { control: 'select', options: SIZES },
    value: { control: { type: 'number', min: 0, max: 10 } },
    max: { control: { type: 'number', min: 1, max: 10 } },
    label: { control: 'text' },
  },
  args: {
    value: 3,
    max: 5,
    size: 'md',
    tone: 'brass',
  },
};

export default meta;

type Story = StoryObj<typeof AppDots>;

// ── Core stories ─────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default (3/5 brass)',
  args: { value: 3, max: 5, tone: 'brass', size: 'md' },
};

export const Full: Story = {
  name: 'Full (5/5)',
  args: { value: 5, max: 5, tone: 'brass', size: 'md' },
};

export const Empty: Story = {
  name: 'Empty (0/5)',
  args: { value: 0, max: 5, tone: 'brass', size: 'md' },
};

export const Mystic: Story = {
  name: 'Mystic (2/5)',
  args: { value: 2, max: 5, tone: 'mystic', size: 'md' },
};

export const Crimson: Story = {
  name: 'Crimson (4/5)',
  args: { value: 4, max: 5, tone: 'crimson', size: 'md' },
};

export const Darkness: Story = {
  name: 'Darkness (1/5)',
  args: { value: 1, max: 5, tone: 'darkness', size: 'md' },
};

// ── Size variants ─────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes (sm / md / lg)',
  render: () => ({
    components: { AppDots },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-3); align-items: flex-start;">
        <div style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-family: var(--type-body-md-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary); min-width: 24px;">sm</span>
          <AppDots :value="3" :max="5" size="sm" tone="brass" />
        </div>
        <div style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-family: var(--type-body-md-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary); min-width: 24px;">md</span>
          <AppDots :value="3" :max="5" size="md" tone="brass" />
        </div>
        <div style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-family: var(--type-body-md-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary); min-width: 24px;">lg</span>
          <AppDots :value="3" :max="5" size="lg" tone="brass" />
        </div>
      </div>
    `,
  }),
};

// ── Edge cases ────────────────────────────────────────────────────────────────

export const LargerMax: Story = {
  name: 'Larger max (4/8)',
  args: { value: 4, max: 8, tone: 'brass', size: 'md' },
};

export const WithLabel: Story = {
  name: 'With label="Force"',
  args: { value: 2, max: 5, tone: 'brass', size: 'md', label: 'Force' },
};

// ── WallOfStats layout reference ──────────────────────────────────────────────

export const WallOfStats: Story = {
  name: 'Wall of Stats (Coriolis attribute panel)',
  render: () => ({
    components: { AppDots },
    template: `
      <div style="
        background: var(--surface-night);
        border: 1px solid var(--brand-brass-deep);
        border-radius: var(--radius-md);
        padding: var(--space-5);
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: var(--space-4);
        max-width: 480px;
      ">
        <div v-for="attr in attrs" :key="attr.label" style="display: flex; flex-direction: column; gap: var(--space-1);">
          <span style="
            font-family: var(--type-display-sm-font-family);
            font-size: 11px;
            color: var(--brand-brass-light);
            letter-spacing: 0.10em;
            text-transform: uppercase;
          ">{{ attr.label }}</span>
          <div style="display: flex; align-items: baseline; gap: var(--space-2);">
            <span style="
              font-family: var(--type-mono-stat-md-font-family);
              font-size: 22px;
              font-weight: 700;
              color: var(--text-primary);
              line-height: 1;
            ">{{ attr.value }}</span>
            <AppDots :value="attr.value" :max="5" size="sm" tone="brass" :label="attr.label" />
          </div>
        </div>
      </div>
    `,
    setup() {
      return {
        attrs: [
          { label: 'Strength', value: 3 },
          { label: 'Agility', value: 5 },
          { label: 'Wits', value: 4 },
          { label: 'Empathy', value: 3 },
        ],
      };
    },
  }),
};
