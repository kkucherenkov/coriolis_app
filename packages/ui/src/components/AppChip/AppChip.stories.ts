import { ref } from 'vue';

import AppChip from './AppChip.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const VARIANTS = ['brass', 'mystic', 'crimson', 'success', 'darkness'] as const;
const SIZES = ['sm', 'md'] as const;

const meta: Meta<typeof AppChip> = {
  title: 'Primitives/AppChip',
  component: AppChip,
  tags: ['autodocs'],
  argTypes: {
    variant: { control: 'select', options: VARIANTS },
    size: { control: 'select', options: SIZES },
    modelValue: { control: 'boolean' },
    disabled: { control: 'boolean' },
    removable: { control: 'boolean' },
  },
  args: {
    modelValue: false,
    variant: 'brass',
    size: 'md',
    disabled: false,
    removable: false,
  },
};

export default meta;

type Story = StoryObj<typeof AppChip>;

// ── Toggleable (inactive) ────────────────────────────────────────────────────

export const Toggleable: Story = {
  name: 'Toggleable — Inactive',
  args: { modelValue: false, variant: 'brass' },
  render: (args) => ({
    components: { AppChip },
    setup() {
      const active = ref(args.modelValue);
      return { args, active };
    },
    template: `<AppChip v-bind="args" v-model="active">Condition</AppChip>`,
  }),
};

// ── Toggleable (active) ──────────────────────────────────────────────────────

export const ToggleableActive: Story = {
  name: 'Toggleable — Active',
  args: { modelValue: true, variant: 'brass' },
  render: (args) => ({
    components: { AppChip },
    setup() {
      const active = ref(args.modelValue);
      return { args, active };
    },
    template: `<AppChip v-bind="args" v-model="active">Condition</AppChip>`,
  }),
};

// ── All variants inactive ────────────────────────────────────────────────────

export const AllVariantsInactive: Story = {
  name: 'All Variants — Inactive',
  render: () => ({
    components: { AppChip },
    setup() {
      return { variants: VARIANTS };
    },
    template: `
      <div style="display: flex; flex-wrap: wrap; gap: var(--space-3); align-items: center;">
        <AppChip
          v-for="v in variants"
          :key="v"
          :variant="v"
          :model-value="false"
        >{{ v }}</AppChip>
      </div>
    `,
  }),
};

// ── All variants active ──────────────────────────────────────────────────────

export const AllVariantsActive: Story = {
  name: 'All Variants — Active',
  render: () => ({
    components: { AppChip },
    setup() {
      return { variants: VARIANTS };
    },
    template: `
      <div style="display: flex; flex-wrap: wrap; gap: var(--space-3); align-items: center;">
        <AppChip
          v-for="v in variants"
          :key="v"
          :variant="v"
          :model-value="true"
        >{{ v }}</AppChip>
      </div>
    `,
  }),
};

// ── Sizes ────────────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes',
  render: () => ({
    components: { AppChip },
    setup() {
      return { sizes: SIZES };
    },
    template: `
      <div style="display: flex; gap: var(--space-4); align-items: center;">
        <AppChip v-for="s in sizes" :key="s" :size="s" :model-value="false">{{ s }}</AppChip>
      </div>
    `,
  }),
};

// ── Disabled ─────────────────────────────────────────────────────────────────

export const Disabled: Story = {
  name: 'Disabled',
  render: () => ({
    components: { AppChip },
    template: `
      <div style="display: flex; gap: var(--space-3); align-items: center;">
        <AppChip variant="brass" :model-value="false" :disabled="true">Inactive</AppChip>
        <AppChip variant="brass" :model-value="true" :disabled="true">Active</AppChip>
      </div>
    `,
  }),
};

// ── Removable inactive ───────────────────────────────────────────────────────

export const RemovableInactive: Story = {
  name: 'Removable — Inactive',
  args: { modelValue: false, variant: 'brass', removable: true },
  render: (args) => ({
    components: { AppChip },
    setup() {
      const active = ref(args.modelValue);
      return { args, active };
    },
    template: `<AppChip v-bind="args" v-model="active">Filter</AppChip>`,
  }),
};

// ── Removable active ─────────────────────────────────────────────────────────

export const RemovableActive: Story = {
  name: 'Removable — Active',
  args: { modelValue: true, variant: 'mystic', removable: true },
  render: (args) => ({
    components: { AppChip },
    setup() {
      const active = ref(args.modelValue);
      return { args, active };
    },
    template: `<AppChip v-bind="args" v-model="active">Filter</AppChip>`,
  }),
};

// ── Mystic variant (toggled) ──────────────────────────────────────────────────

export const MysticToggled: Story = {
  name: 'Mystic Variant — Toggled',
  args: { modelValue: true, variant: 'mystic' },
  render: (args) => ({
    components: { AppChip },
    setup() {
      const active = ref(args.modelValue);
      return { args, active };
    },
    template: `<AppChip v-bind="args" v-model="active">Icon Power</AppChip>`,
  }),
};

// ── Brass / sm ───────────────────────────────────────────────────────────────

export const BrassSm: Story = {
  name: 'Brass / sm',
  args: { variant: 'brass', size: 'sm', modelValue: false },
  render: (args) => ({
    components: { AppChip },
    setup() {
      const active = ref(args.modelValue);
      return { args, active };
    },
    template: `<AppChip v-bind="args" v-model="active">Brass sm</AppChip>`,
  }),
};

// ── Crimson active ────────────────────────────────────────────────────────────

export const CrimsonActive: Story = {
  name: 'Crimson — Active',
  args: { variant: 'crimson', modelValue: true },
  render: (args) => ({
    components: { AppChip },
    setup() {
      const active = ref(args.modelValue);
      return { args, active };
    },
    template: `<AppChip v-bind="args" v-model="active">Critical Hit</AppChip>`,
  }),
};

// ── Success active ────────────────────────────────────────────────────────────

export const SuccessActive: Story = {
  name: 'Success — Active',
  args: { variant: 'success', modelValue: true },
  render: (args) => ({
    components: { AppChip },
    setup() {
      const active = ref(args.modelValue);
      return { args, active };
    },
    template: `<AppChip v-bind="args" v-model="active">Recovered</AppChip>`,
  }),
};

// ── Darkness active ───────────────────────────────────────────────────────────

export const DarknessActive: Story = {
  name: 'Darkness — Active',
  args: { variant: 'darkness', modelValue: true },
  render: (args) => ({
    components: { AppChip },
    setup() {
      const active = ref(args.modelValue);
      return { args, active };
    },
    template: `<AppChip v-bind="args" v-model="active">Dark Point</AppChip>`,
  }),
};

// ── Condition Panel (PRD §5 — Exhausted / Sleepless / Thirsty / Hungry) ──────

export const ConditionPanel: Story = {
  name: 'Condition Panel (PRD §5)',
  render: () => ({
    components: { AppChip },
    setup() {
      const conditions = ref([
        { label: 'Exhausted', active: false },
        { label: 'Sleepless', active: true },
        { label: 'Thirsty', active: false },
        { label: 'Hungry', active: true },
      ]);
      return { conditions };
    },
    template: `
      <div style="display: flex; flex-wrap: wrap; gap: var(--space-3); align-items: center;">
        <AppChip
          v-for="(c, i) in conditions"
          :key="c.label"
          variant="mystic"
          :model-value="c.active"
          @update:model-value="(v) => conditions[i].active = v"
        >{{ c.label }}</AppChip>
      </div>
    `,
  }),
};
