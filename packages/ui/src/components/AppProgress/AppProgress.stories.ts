import AppProgress from './AppProgress.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const TONES = ['brass', 'mystic', 'crimson', 'success', 'darkness'] as const;
const SIZES = ['sm', 'md', 'lg'] as const;

const meta: Meta<typeof AppProgress> = {
  title: 'Primitives/AppProgress',
  component: AppProgress,
  tags: ['autodocs'],
  argTypes: {
    tone: { control: 'select', options: TONES },
    size: { control: 'select', options: SIZES },
    variant: { control: 'select', options: ['linear'] },
    value: { control: { type: 'number', min: 0, max: 100 } },
    max: { control: { type: 'number', min: 1, max: 100 } },
    min: { control: { type: 'number', min: 0, max: 50 } },
    label: { control: 'text' },
    showLabel: { control: 'boolean' },
  },
  args: {
    value: 60,
    max: 100,
    min: 0,
    variant: 'linear',
    tone: 'brass',
    size: 'md',
    showLabel: false,
  },
};

export default meta;

type Story = StoryObj<typeof AppProgress>;

// ── Core stories ──────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default (60/100 brass)',
  args: { value: 60, max: 100, tone: 'brass', size: 'md' },
};

export const Empty: Story = {
  name: 'Empty (0/100)',
  args: { value: 0, max: 100, tone: 'brass', size: 'md' },
};

export const Full: Story = {
  name: 'Full (100/100)',
  args: { value: 100, max: 100, tone: 'brass', size: 'md' },
};

// ── Size variants ─────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes (sm / md / lg)',
  render: () => ({
    components: { AppProgress },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-4); max-width: 360px;">
        <div style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-family: var(--type-body-md-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary); min-width: 24px;">sm</span>
          <AppProgress :value="60" :max="100" size="sm" tone="brass" style="flex: 1;" />
        </div>
        <div style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-family: var(--type-body-md-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary); min-width: 24px;">md</span>
          <AppProgress :value="60" :max="100" size="md" tone="brass" style="flex: 1;" />
        </div>
        <div style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-family: var(--type-body-md-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary); min-width: 24px;">lg</span>
          <AppProgress :value="60" :max="100" size="lg" tone="brass" style="flex: 1;" />
        </div>
      </div>
    `,
  }),
};

// ── Tone variants ─────────────────────────────────────────────────────────────

export const Tones: Story = {
  name: 'Tones (all 5)',
  render: () => ({
    components: { AppProgress },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-4); max-width: 360px;">
        <div v-for="tone in tones" :key="tone" style="display: flex; align-items: center; gap: var(--space-3);">
          <span style="font-family: var(--type-body-md-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary); min-width: 64px;">{{ tone }}</span>
          <AppProgress :value="60" :max="100" size="md" :tone="tone" style="flex: 1;" />
        </div>
      </div>
    `,
    setup() {
      return { tones: ['brass', 'mystic', 'crimson', 'success', 'darkness'] };
    },
  }),
};

// ── Label variant ─────────────────────────────────────────────────────────────

export const WithLabel: Story = {
  name: 'With showLabel ("12 / 14")',
  args: { value: 12, max: 14, tone: 'brass', size: 'md', showLabel: true, label: 'HP' },
};

// ── HP/MP examples ────────────────────────────────────────────────────────────

export const HpExample: Story = {
  name: 'HP bar (8/14 crimson, with label)',
  args: {
    value: 8,
    max: 14,
    tone: 'crimson',
    size: 'md',
    showLabel: true,
    label: 'Hit Points',
  },
};

export const MpExample: Story = {
  name: 'MP bar (5/10 mystic)',
  args: {
    value: 5,
    max: 10,
    tone: 'mystic',
    size: 'md',
    showLabel: true,
    label: 'Mind Points',
  },
};

// ── Wizard steps ──────────────────────────────────────────────────────────────

export const WizardSteps: Story = {
  name: 'Wizard step progress (2/3 brass)',
  render: () => ({
    components: { AppProgress },
    template: `
      <div style="max-width: 480px; background: var(--surface-void); padding: var(--space-6);">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--space-3);">
          <span style="font-family: var(--type-body-md-font-family); font-size: var(--type-body-sm-font-size); color: var(--brand-brass); text-transform: uppercase; letter-spacing: 0.18em;">New Character</span>
          <span style="font-family: var(--type-body-md-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary);">Step 2 of 3</span>
        </div>
        <AppProgress :value="2" :max="3" tone="brass" size="sm" label="Step 2 of 3" />
      </div>
    `,
  }),
};

// ── Edge cases ────────────────────────────────────────────────────────────────

export const OverMax: Story = {
  name: 'Value over max (clamped to 100)',
  args: { value: 999, max: 100, tone: 'brass', size: 'md' },
};

export const UnderMin: Story = {
  name: 'Value under min (clamped to 0)',
  args: { value: -50, max: 100, min: 0, tone: 'brass', size: 'md' },
};

export const NonZeroMin: Story = {
  name: 'Non-zero min (range 10–20, value 15)',
  args: { value: 15, max: 20, min: 10, tone: 'success', size: 'md', showLabel: true },
};

export const AccessibleLabel: Story = {
  name: 'aria-label provided',
  args: { value: 75, max: 100, tone: 'brass', size: 'md', label: 'Loading progress' },
};

// ── Combined HP/MP panel ──────────────────────────────────────────────────────

export const HpMpPanel: Story = {
  name: 'HP + MP panel (sheet header usage)',
  render: () => ({
    components: { AppProgress },
    template: `
      <div style="
        background: var(--surface-night);
        border: 1px solid var(--brand-brass-deep);
        border-radius: var(--radius-md);
        padding: var(--space-5);
        display: flex;
        flex-direction: column;
        gap: var(--space-4);
        max-width: 200px;
      ">
        <div style="display: flex; flex-direction: column; gap: var(--space-2);">
          <span style="font-family: var(--type-body-sm-font-family); font-size: var(--type-body-sm-font-size); color: var(--state-crimson-bright); text-transform: uppercase; letter-spacing: 0.18em;">HP</span>
          <AppProgress :value="11" :max="14" tone="crimson" size="md" :show-label="true" label="Hit Points" />
        </div>
        <div style="display: flex; flex-direction: column; gap: var(--space-2);">
          <span style="font-family: var(--type-body-sm-font-family); font-size: var(--type-body-sm-font-size); color: var(--state-mystic-teal); text-transform: uppercase; letter-spacing: 0.18em;">MP</span>
          <AppProgress :value="5" :max="10" tone="mystic" size="md" :show-label="true" label="Mind Points" />
        </div>
      </div>
    `,
  }),
};
