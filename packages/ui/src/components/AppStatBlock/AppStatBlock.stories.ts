import { ref } from 'vue';

import AppStatBlock from './AppStatBlock.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const TONES = ['brass', 'mystic'] as const;
const SIZES = ['sm', 'md'] as const;

const meta: Meta<typeof AppStatBlock> = {
  title: 'Coriolis/AppStatBlock',
  component: AppStatBlock,
  tags: ['autodocs'],
  argTypes: {
    tone: { control: 'select', options: TONES },
    size: { control: 'select', options: SIZES },
    value: { control: { type: 'number', min: 0, max: 5 } },
    max: { control: { type: 'number', min: 1, max: 10 } },
    label: { control: 'text' },
    hideDots: { control: 'boolean' },
    disabled: { control: 'boolean' },
  },
  args: {
    label: 'Strength',
    value: 3,
    max: 5,
    tone: 'brass',
    size: 'md',
    hideDots: false,
    disabled: false,
  },
};

export default meta;

type Story = StoryObj<typeof AppStatBlock>;

// ── Default: brass, STR · 3 · max 5 ──────────────────────────────────────────

export const Default: Story = {
  name: 'Default — Brass (STR · 3 · max 5)',
  args: {
    label: 'STR',
    value: 3,
    max: 5,
    tone: 'brass',
    size: 'md',
  },
};

// ── Mystic tone ───────────────────────────────────────────────────────────────

export const Mystic: Story = {
  name: 'Mystic tone (Pilot · 5 · max 5)',
  args: {
    label: 'Pilot',
    value: 5,
    max: 5,
    tone: 'mystic',
    size: 'md',
  },
};

// ── HideDots variant ──────────────────────────────────────────────────────────

export const HideDots: Story = {
  name: 'HideDots (HP counter, no dots row)',
  args: {
    label: 'HP',
    value: 4,
    max: 5,
    tone: 'brass',
    size: 'md',
    hideDots: true,
  },
};

// ── Sm size ───────────────────────────────────────────────────────────────────

export const Small: Story = {
  name: 'Sm size (HP 11 / 12 hero counter)',
  args: {
    label: 'HP',
    value: 11,
    max: 12,
    tone: 'brass',
    size: 'sm',
    hideDots: true,
  },
};

// ── Disabled (read-only) ──────────────────────────────────────────────────────

export const Disabled: Story = {
  name: 'Disabled — read-only render',
  args: {
    label: 'AGI',
    value: 4,
    max: 5,
    tone: 'brass',
    size: 'md',
    disabled: true,
  },
};

// ── Four-attributes panel (layout reference) ──────────────────────────────────

export const AttributesPanel: Story = {
  name: 'Attributes panel (four attrs grid)',
  render: () => ({
    components: { AppStatBlock },
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
        <AppStatBlock
          v-for="attr in attrs"
          :key="attr.label"
          :label="attr.label"
          :value="attr.value"
          :max="5"
          tone="brass"
          size="md"
          @select="onSelect(attr.label)"
        />
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
        onSelect: (_label: string) => undefined,
      };
    },
  }),
};

// ── Editable (inline AppDotInput) ───────────────────────────────────────────────

export const Editable: Story = {
  name: 'Editable (click-the-dot, attribute min 1)',
  render: () => ({
    components: { AppStatBlock },
    setup() {
      const attrs = ref([
        { label: 'STR', value: 3 },
        { label: 'AGI', value: 5 },
        { label: 'WIT', value: 2 },
        { label: 'EMP', value: 4 },
      ]);
      return { attrs };
    },
    template: `
      <div style="display: flex; gap: var(--space-4); background: var(--surface-night); border: 1px solid var(--brand-brass-deep); border-radius: var(--radius-md); padding: var(--space-5);">
        <AppStatBlock
          v-for="attr in attrs"
          :key="attr.label"
          editable
          :label="attr.label"
          :value="attr.value"
          :min="1"
          :max="5"
          tone="brass"
          size="md"
          @update:value="attr.value = $event"
        />
      </div>
    `,
  }),
};
