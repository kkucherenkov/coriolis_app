import AppIcon from './AppIcon.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const COLORS = ['brass', 'mystic', 'crimson', 'success', 'darkness', 'inherit'] as const;
const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

// 30+ representative Lucide icon names used in the wall-of-icons story.
const ICON_WALL = [
  'sword',
  'shield',
  'heart',
  'star',
  'flame',
  'droplet',
  'dice-3',
  'zap',
  'cog',
  'eye',
  'map',
  'compass',
  'anchor',
  'moon',
  'sun',
  'cloud',
  'crosshair',
  'activity',
  'alert-triangle',
  'bell',
  'bookmark',
  'box',
  'briefcase',
  'calendar',
  'camera',
  'check',
  'chevron-down',
  'circle',
  'clipboard',
  'clock',
  'coffee',
  'database',
  'flag',
  'globe',
  'home',
  'key',
  'lock',
  'mail',
  'message-circle',
  'music',
] as const;

const meta: Meta<typeof AppIcon> = {
  title: 'Primitives/AppIcon',
  component: AppIcon,
  tags: ['autodocs'],
  args: { name: 'sword', size: 'md', color: 'inherit', strokeWidth: 1.5 },
  argTypes: {
    name: {
      control: 'text',
      description: 'Lucide icon name in kebab-case (e.g. `sword`, `arrow-up-right`).',
    },
    size: { control: 'select', options: SIZES },
    color: { control: 'select', options: COLORS },
    strokeWidth: { control: 'number' },
    ariaLabel: {
      control: 'text',
      description: 'Accessible label. When absent the icon is decorative (aria-hidden).',
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppIcon>;

// ── Default ───────────────────────────────────────────────────────────────────

export const Default: Story = {};

// ── Color variants × a representative icon ────────────────────────────────────

export const Colors: Story = {
  name: 'Color Variants',
  render: (args) => ({
    components: { AppIcon },
    setup: () => ({ args, COLORS }),
    template: `
      <div style="display: flex; flex-wrap: wrap; gap: var(--space-8); align-items: center;">
        <div
          v-for="color in COLORS"
          :key="color"
          style="display: flex; flex-direction: column; align-items: center; gap: var(--space-2);"
        >
          <AppIcon v-bind="args" :color="color" size="lg" />
          <span style="font-size: 11px; color: var(--text-secondary); font-family: var(--type-body-sm-font-family);">{{ color }}</span>
        </div>
      </div>
    `,
  }),
};

export const BrassColor: Story = {
  name: 'Color / brass',
  args: { color: 'brass', size: 'lg' },
};

export const MysticColor: Story = {
  name: 'Color / mystic',
  args: { color: 'mystic', size: 'lg' },
};

export const CrimsonColor: Story = {
  name: 'Color / crimson',
  args: { color: 'crimson', size: 'lg' },
};

export const SuccessColor: Story = {
  name: 'Color / success',
  args: { color: 'success', size: 'lg' },
};

export const DarknessColor: Story = {
  name: 'Color / darkness',
  args: { color: 'darkness', size: 'lg', name: 'eye' },
};

export const InheritColor: Story = {
  name: 'Color / inherit',
  args: { color: 'inherit', size: 'lg' },
  render: (args) => ({
    components: { AppIcon },
    setup: () => ({ args }),
    template: `
      <div style="display: flex; gap: var(--space-8); align-items: center;">
        <span style="color: var(--brand-brass);"><AppIcon v-bind="args" /></span>
        <span style="color: var(--state-mystic-teal);"><AppIcon v-bind="args" /></span>
        <span style="color: var(--state-crimson-bright);"><AppIcon v-bind="args" /></span>
        <span style="color: var(--text-secondary);"><AppIcon v-bind="args" /></span>
      </div>
    `,
  }),
};

// ── Size variants ─────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Size Variants',
  render: (args) => ({
    components: { AppIcon },
    setup: () => ({ args, SIZES }),
    template: `
      <div style="display: flex; flex-wrap: wrap; gap: var(--space-8); align-items: flex-end;">
        <div
          v-for="size in SIZES"
          :key="size"
          style="display: flex; flex-direction: column; align-items: center; gap: var(--space-2);"
        >
          <AppIcon v-bind="args" :size="size" color="brass" />
          <span style="font-size: 11px; color: var(--text-secondary); font-family: var(--type-body-sm-font-family);">{{ size }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Wall of icons ─────────────────────────────────────────────────────────────

export const WallOfIcons: Story = {
  name: 'Wall of Icons (30+)',
  render: () => ({
    components: { AppIcon },
    setup: () => ({ ICON_WALL }),
    template: `
      <div style="display: grid; grid-template-columns: repeat(auto-fill, 80px); gap: var(--space-6);">
        <div
          v-for="name in ICON_WALL"
          :key="name"
          style="display: flex; flex-direction: column; align-items: center; gap: var(--space-1);"
        >
          <AppIcon :name="name" size="md" color="brass" />
          <span style="font-size: 10px; color: var(--text-secondary); font-family: var(--type-body-sm-font-family); text-align: center; word-break: break-all;">{{ name }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Stroke width ──────────────────────────────────────────────────────────────

export const StrokeWidths: Story = {
  name: 'Stroke Widths',
  render: (args) => ({
    components: { AppIcon },
    setup: () => ({ args }),
    template: `
      <div style="display: flex; gap: var(--space-8); align-items: center;">
        <div style="display: flex; flex-direction: column; align-items: center; gap: var(--space-2);">
          <AppIcon v-bind="args" :stroke-width="1" size="xl" color="brass" />
          <span style="font-size: 11px; color: var(--text-secondary); font-family: var(--type-body-sm-font-family);">1</span>
        </div>
        <div style="display: flex; flex-direction: column; align-items: center; gap: var(--space-2);">
          <AppIcon v-bind="args" :stroke-width="1.5" size="xl" color="brass" />
          <span style="font-size: 11px; color: var(--text-secondary); font-family: var(--type-body-sm-font-family);">1.5 (default)</span>
        </div>
        <div style="display: flex; flex-direction: column; align-items: center; gap: var(--space-2);">
          <AppIcon v-bind="args" :stroke-width="2" size="xl" color="brass" />
          <span style="font-size: 11px; color: var(--text-secondary); font-family: var(--type-body-sm-font-family);">2</span>
        </div>
      </div>
    `,
  }),
};

// ── Accessibility: decorative (no aria-label) ─────────────────────────────────

export const A11yDecorative: Story = {
  name: 'A11y / Decorative (no label)',
  args: { name: 'star', size: 'lg', color: 'brass' },
  // No ariaLabel → aria-hidden="true" on the root span.  Screen readers skip it.
};

// ── Accessibility: labeled ────────────────────────────────────────────────────

export const A11yLabeled: Story = {
  name: 'A11y / Labeled',
  args: { name: 'shield', size: 'lg', color: 'mystic', ariaLabel: 'Armour equipped' },
  // ariaLabel provided → role="img" + aria-label exposed to screen readers.
};

// ── Unknown icon fallback ─────────────────────────────────────────────────────

export const UnknownFallback: Story = {
  name: 'Unknown Icon (graceful fallback)',
  args: { name: 'not-a-real-icon-xyz', size: 'lg', color: 'brass' },
  // Renders an empty span; console.warn logged.  No crash.
};
