import { ref } from 'vue';

import AppDotInput from './AppDotInput.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const TONES = ['brass', 'mystic', 'crimson', 'darkness'] as const;
const SIZES = ['sm', 'md', 'lg'] as const;

const meta: Meta<typeof AppDotInput> = {
  title: 'Primitives/AppDotInput',
  component: AppDotInput,
  tags: ['autodocs'],
  argTypes: {
    tone: { control: 'select', options: TONES },
    size: { control: 'select', options: SIZES },
    modelValue: { control: { type: 'number', min: 0, max: 5 } },
    min: { control: { type: 'number', min: 0, max: 5 } },
    max: { control: { type: 'number', min: 1, max: 10 } },
    disabled: { control: 'boolean' },
    label: { control: 'text' },
  },
  args: {
    modelValue: 3,
    min: 0,
    max: 5,
    size: 'md',
    tone: 'brass',
    disabled: false,
    label: 'Strength',
  },
};

export default meta;

type Story = StoryObj<typeof AppDotInput>;

// ── Interactive playground ─────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default (interactive)',
  render: (args) => ({
    components: { AppDotInput },
    setup() {
      const value = ref(args.modelValue);
      return { args, value };
    },
    template: `
      <div style="display: flex; align-items: center; gap: var(--space-4);">
        <AppDotInput v-bind="args" v-model="value" />
        <span style="font-family: var(--type-mono-stat-md-font-family); color: var(--text-secondary);">{{ value }}</span>
      </div>
    `,
  }),
};

// ── Attribute (min 1) vs skill (min 0) ──────────────────────────────────────────

export const AttributeMinOne: Story = {
  name: 'Attribute (min 1)',
  render: () => ({
    components: { AppDotInput },
    setup() {
      const value = ref(3);
      return { value };
    },
    template: `<AppDotInput v-model="value" :min="1" :max="5" tone="brass" label="Strength" />`,
  }),
};

export const SkillMinZero: Story = {
  name: 'Skill (min 0, mystic)',
  render: () => ({
    components: { AppDotInput },
    setup() {
      const value = ref(2);
      return { value };
    },
    template: `<AppDotInput v-model="value" :min="0" :max="5" tone="mystic" label="Mystic Powers" />`,
  }),
};

// ── Tones ───────────────────────────────────────────────────────────────────────

export const Tones: Story = {
  name: 'Tones (brass / mystic / crimson / darkness)',
  render: () => ({
    components: { AppDotInput },
    setup() {
      return { TONES };
    },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-3); align-items: flex-start;">
        <AppDotInput
          v-for="tone in TONES"
          :key="tone"
          :model-value="3"
          :max="5"
          :tone="tone"
          :label="tone"
        />
      </div>
    `,
  }),
};

// ── Sizes ─────────────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes (sm / md / lg)',
  render: () => ({
    components: { AppDotInput },
    setup() {
      return { SIZES };
    },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-3); align-items: flex-start;">
        <AppDotInput
          v-for="size in SIZES"
          :key="size"
          :model-value="3"
          :max="5"
          :size="size"
          tone="brass"
          :label="size"
        />
      </div>
    `,
  }),
};

// ── Disabled ────────────────────────────────────────────────────────────────────

export const Disabled: Story = {
  name: 'Disabled',
  args: { modelValue: 2, disabled: true, label: 'Locked stat' },
};
