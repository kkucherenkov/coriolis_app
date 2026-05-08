import { ref } from 'vue';

import AppSegControl from './AppSegControl.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const SIZES = ['sm', 'md', 'lg'] as const;

const meta: Meta<typeof AppSegControl> = {
  title: 'Primitives/AppSegControl',
  component: AppSegControl,
  tags: ['autodocs'],
  argTypes: {
    size: { control: 'select', options: SIZES },
    disabled: { control: 'boolean' },
    modelValue: { control: 'text' },
  },
  args: {
    size: 'md',
    disabled: false,
    modelValue: 'yes',
    options: [
      { value: 'yes', label: 'Yes' },
      { value: 'no', label: 'No' },
    ],
  },
};

export default meta;

type Story = StoryObj<typeof AppSegControl>;

// ── Binary (Yes / No) ─────────────────────────────────────────────────────────

export const Binary: Story = {
  name: 'Binary — Yes / No',
  render: (args) => ({
    components: { AppSegControl },
    setup() {
      const value = ref(args.modelValue);
      return { args, value };
    },
    template: `
      <div style="padding: 24px; display: flex; flex-direction: column; gap: 12px;">
        <AppSegControl
          v-bind="args"
          v-model="value"
        />
        <div style="font-size: 12px; color: var(--text-secondary);">Selected: {{ value }}</div>
      </div>
    `,
  }),
};

// ── Ternary (Combat / Diplomacy / Survival) ───────────────────────────────────

export const Ternary: Story = {
  name: 'Ternary — Concept',
  render: () => ({
    components: { AppSegControl },
    setup() {
      const value = ref('combat');
      return {
        value,
        options: [
          { value: 'combat', label: 'Combat' },
          { value: 'diplomacy', label: 'Diplomacy' },
          { value: 'survival', label: 'Survival' },
        ],
      };
    },
    template: `
      <div style="padding: 24px; display: flex; flex-direction: column; gap: 12px;">
        <AppSegControl :options="options" v-model="value" />
        <div style="font-size: 12px; color: var(--text-secondary);">Selected: {{ value }}</div>
      </div>
    `,
  }),
};

// ── Five Options ──────────────────────────────────────────────────────────────

export const FiveOptions: Story = {
  name: 'Five Options',
  render: () => ({
    components: { AppSegControl },
    setup() {
      const value = ref('3');
      return {
        value,
        options: [
          { value: '1', label: '1' },
          { value: '2', label: '2' },
          { value: '3', label: '3' },
          { value: '4', label: '4' },
          { value: '5', label: '5' },
        ],
      };
    },
    template: `
      <div style="padding: 24px; display: flex; flex-direction: column; gap: 12px;">
        <AppSegControl :options="options" v-model="value" />
        <div style="font-size: 12px; color: var(--text-secondary);">Selected: {{ value }}</div>
      </div>
    `,
  }),
};

// ── Disabled (whole group) ────────────────────────────────────────────────────

export const Disabled: Story = {
  name: 'Disabled — Whole Group',
  render: () => ({
    components: { AppSegControl },
    setup() {
      return {
        value: ref('yes'),
        options: [
          { value: 'yes', label: 'Yes' },
          { value: 'no', label: 'No' },
        ],
      };
    },
    template: `
      <div style="padding: 24px;">
        <AppSegControl :options="options" v-model="value" :disabled="true" />
      </div>
    `,
  }),
};

// ── Sizes (sm / md / lg) ──────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes — sm / md / lg',
  render: () => ({
    components: { AppSegControl },
    setup() {
      const values = { sm: ref('yes'), md: ref('yes'), lg: ref('yes') };
      const options = [
        { value: 'yes', label: 'Yes' },
        { value: 'no', label: 'No' },
      ];
      return { values, options, sizes: SIZES };
    },
    template: `
      <div style="padding: 24px; display: flex; flex-direction: column; gap: 16px;">
        <div v-for="s in sizes" :key="s" style="display: flex; align-items: center; gap: 16px;">
          <span style="font-size: 11px; color: var(--text-secondary); min-width: 28px;">{{ s }}</span>
          <AppSegControl :options="options" :size="s" v-model="values[s].value" />
        </div>
      </div>
    `,
  }),
};

// ── One Option Disabled ───────────────────────────────────────────────────────

export const DisabledOption: Story = {
  name: 'Disabled Option — One in List',
  render: () => ({
    components: { AppSegControl },
    setup() {
      return {
        value: ref('combat'),
        options: [
          { value: 'combat', label: 'Combat' },
          { value: 'diplomacy', label: 'Diplomacy', disabled: true },
          { value: 'survival', label: 'Survival' },
        ],
      };
    },
    template: `
      <div style="padding: 24px; display: flex; flex-direction: column; gap: 12px;">
        <AppSegControl :options="options" v-model="value" />
        <div style="font-size: 12px; color: var(--text-secondary);">"Diplomacy" option is individually disabled.</div>
      </div>
    `,
  }),
};

// ── Wizard — Mystic? Yes / No ─────────────────────────────────────────────────

export const WizardMystic: Story = {
  name: 'Wizard — Mystic? Yes / No',
  render: () => ({
    components: { AppSegControl },
    setup() {
      const isMystic = ref('no');
      return {
        isMystic,
        options: [
          { value: 'yes', label: 'Yes' },
          { value: 'no', label: 'No' },
        ],
      };
    },
    template: `
      <div style="background: var(--surface-night); border: 1px solid var(--brand-brass-deep); border-radius: 4px; padding: 20px; max-width: 400px;">
        <div style="font-family: var(--type-display-sm-font-family); font-size: 13px; color: var(--brand-brass-light); text-transform: uppercase; letter-spacing: 0.12em; margin-bottom: 12px;">Mystic powers?</div>
        <AppSegControl :options="options" v-model="isMystic" />
        <div style="margin-top: 10px; font-size: 12px; color: var(--text-secondary); font-style: italic;">
          {{ isMystic === 'yes' ? 'Mystic Powers skill is unlocked.' : 'Mystic Powers remain dormant.' }}
        </div>
      </div>
    `,
  }),
};

// ── Null selection (unselected) ───────────────────────────────────────────────

export const Unselected: Story = {
  name: 'Unselected — null modelValue',
  render: () => ({
    components: { AppSegControl },
    setup() {
      return {
        value: ref(null),
        options: [
          { value: 'a', label: 'Option A' },
          { value: 'b', label: 'Option B' },
          { value: 'c', label: 'Option C' },
        ],
      };
    },
    template: `
      <div style="padding: 24px; display: flex; flex-direction: column; gap: 12px;">
        <AppSegControl :options="options" v-model="value" />
        <div style="font-size: 12px; color: var(--text-secondary);">No option checked — first receives roving focus.</div>
      </div>
    `,
  }),
};

// ── All Sizes — Ternary ───────────────────────────────────────────────────────

export const AllSizesTernary: Story = {
  name: 'All Sizes — Ternary',
  render: () => ({
    components: { AppSegControl },
    setup() {
      const vals = { sm: ref('b'), md: ref('b'), lg: ref('b') };
      const options = [
        { value: 'a', label: 'Alpha' },
        { value: 'b', label: 'Beta' },
        { value: 'c', label: 'Gamma' },
      ];
      return { vals, options, sizes: SIZES };
    },
    template: `
      <div style="padding: 24px; display: flex; flex-direction: column; gap: 16px;">
        <div v-for="s in sizes" :key="s" style="display: flex; align-items: center; gap: 16px;">
          <span style="font-size: 11px; color: var(--text-secondary); min-width: 28px;">{{ s }}</span>
          <AppSegControl :options="options" :size="s" v-model="vals[s].value" />
        </div>
      </div>
    `,
  }),
};

// ── Wizard — Origin type ──────────────────────────────────────────────────────

export const WizardOriginType: Story = {
  name: 'Wizard — Origin quick-filter',
  render: () => ({
    components: { AppSegControl },
    setup() {
      return {
        value: ref('all'),
        options: [
          { value: 'all', label: 'All' },
          { value: 'station', label: 'Station' },
          { value: 'nomad', label: 'Nomad' },
          { value: 'firstcome', label: 'Firstcome' },
        ],
      };
    },
    template: `
      <div style="padding: 24px; display: flex; flex-direction: column; gap: 12px;">
        <AppSegControl :options="options" v-model="value" size="sm" />
        <div style="font-size: 12px; color: var(--text-secondary);">Filter: {{ value }}</div>
      </div>
    `,
  }),
};
