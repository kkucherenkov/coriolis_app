import AppBadge from './AppBadge.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const VARIANTS = ['brass', 'mystic', 'crimson', 'success', 'darkness'] as const;
const SIZES = ['sm', 'md'] as const;

const meta: Meta<typeof AppBadge> = {
  title: 'Primitives/AppBadge',
  component: AppBadge,
  tags: ['autodocs'],
  argTypes: {
    variant: { control: 'select', options: VARIANTS },
    size: { control: 'select', options: SIZES },
  },
  args: {
    variant: 'brass',
    size: 'md',
  },
};

export default meta;

type Story = StoryObj<typeof AppBadge>;

// ── Variant × Size matrix (10 stories) ───────────────────────────────────────

export const BrassMd: Story = {
  name: 'Brass / md',
  args: { variant: 'brass', size: 'md' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Brass</AppBadge>`,
  }),
};

export const BrassSm: Story = {
  name: 'Brass / sm',
  args: { variant: 'brass', size: 'sm' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Brass</AppBadge>`,
  }),
};

export const MysticMd: Story = {
  name: 'Mystic / md',
  args: { variant: 'mystic', size: 'md' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Mystic</AppBadge>`,
  }),
};

export const MysticSm: Story = {
  name: 'Mystic / sm',
  args: { variant: 'mystic', size: 'sm' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Mystic</AppBadge>`,
  }),
};

export const CrimsonMd: Story = {
  name: 'Crimson / md',
  args: { variant: 'crimson', size: 'md' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Crimson</AppBadge>`,
  }),
};

export const CrimsonSm: Story = {
  name: 'Crimson / sm',
  args: { variant: 'crimson', size: 'sm' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Crimson</AppBadge>`,
  }),
};

export const SuccessMd: Story = {
  name: 'Success / md',
  args: { variant: 'success', size: 'md' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Success</AppBadge>`,
  }),
};

export const SuccessSm: Story = {
  name: 'Success / sm',
  args: { variant: 'success', size: 'sm' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Success</AppBadge>`,
  }),
};

export const DarknessMd: Story = {
  name: 'Darkness / md',
  args: { variant: 'darkness', size: 'md' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Darkness</AppBadge>`,
  }),
};

export const DarknessSm: Story = {
  name: 'Darkness / sm',
  args: { variant: 'darkness', size: 'sm' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Darkness</AppBadge>`,
  }),
};

// ── WithIcon ──────────────────────────────────────────────────────────────────

export const WithIcon: Story = {
  name: 'With Icon',
  args: { variant: 'mystic', size: 'md' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `
      <AppBadge v-bind="args">
        <template #icon>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z"/>
          </svg>
        </template>
        Icon Power
      </AppBadge>
    `,
  }),
};

// ── LongLabel ─────────────────────────────────────────────────────────────────

export const LongLabel: Story = {
  name: 'Long Label',
  args: { variant: 'brass', size: 'md' },
  render: (args) => ({
    components: { AppBadge },
    setup: () => ({ args }),
    template: `<AppBadge v-bind="args">Darkness Point Accumulator</AppBadge>`,
  }),
};

// ── InlineWithText ────────────────────────────────────────────────────────────

export const InlineWithText: Story = {
  name: 'Inline with Text',
  render: () => ({
    components: { AppBadge },
    template: `
      <p style="font-family: var(--type-body-md-font-family); font-size: var(--type-body-md-font-size); color: var(--text-primary); line-height: var(--type-body-md-line-height);">
        Tariq al-Asari &nbsp;
        <AppBadge variant="mystic" size="sm">Mystic</AppBadge>
        &nbsp; has 4 Icon Points remaining.
      </p>
    `,
  }),
};

// ── All variants overview ─────────────────────────────────────────────────────

export const AllVariants: Story = {
  name: 'All Variants',
  render: () => ({
    components: { AppBadge },
    template: `
      <div style="display: flex; flex-wrap: wrap; gap: var(--space-3); align-items: center;">
        <AppBadge variant="brass">Brass</AppBadge>
        <AppBadge variant="mystic">Mystic</AppBadge>
        <AppBadge variant="crimson">Crimson</AppBadge>
        <AppBadge variant="success">Success</AppBadge>
        <AppBadge variant="darkness">Darkness</AppBadge>
      </div>
    `,
  }),
};
