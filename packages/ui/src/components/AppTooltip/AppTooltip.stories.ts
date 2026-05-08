import AppTooltip from './AppTooltip.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const PLACEMENTS = ['top', 'right', 'bottom', 'left'] as const;

const meta: Meta<typeof AppTooltip> = {
  title: 'Primitives/AppTooltip',
  component: AppTooltip,
  tags: ['autodocs'],
  argTypes: {
    placement: { control: 'select', options: PLACEMENTS },
    delay: { control: 'number' },
    disabled: { control: 'boolean' },
    content: { control: 'text' },
  },
  args: {
    content: 'Tooltip content',
    placement: 'top',
    delay: 300,
    disabled: false,
  },
};

export default meta;

type Story = StoryObj<typeof AppTooltip>;

// ── Top (default) ─────────────────────────────────────────────────────────────

export const Top: Story = {
  name: 'Placement — Top',
  args: { content: 'Shown above', placement: 'top' },
  render: (args) => ({
    components: { AppTooltip },
    setup() {
      return { args };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px;">
        <AppTooltip v-bind="args" v-slot="{ ariaDescribedby }">
          <button :aria-describedby="ariaDescribedby" style="padding: 8px 16px; border: 1px solid var(--brand-brass-deep); background: transparent; color: var(--brand-brass-light); border-radius: 4px; cursor: pointer;">
            Hover me (top)
          </button>
        </AppTooltip>
      </div>
    `,
  }),
};

// ── Right ────────────────────────────────────────────────────────────────────

export const Right: Story = {
  name: 'Placement — Right',
  args: { content: 'Shown to the right', placement: 'right' },
  render: (args) => ({
    components: { AppTooltip },
    setup() {
      return { args };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px;">
        <AppTooltip v-bind="args" v-slot="{ ariaDescribedby }">
          <button :aria-describedby="ariaDescribedby" style="padding: 8px 16px; border: 1px solid var(--brand-brass-deep); background: transparent; color: var(--brand-brass-light); border-radius: 4px; cursor: pointer;">
            Hover me (right)
          </button>
        </AppTooltip>
      </div>
    `,
  }),
};

// ── Bottom ────────────────────────────────────────────────────────────────────

export const Bottom: Story = {
  name: 'Placement — Bottom',
  args: { content: 'Shown below', placement: 'bottom' },
  render: (args) => ({
    components: { AppTooltip },
    setup() {
      return { args };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px;">
        <AppTooltip v-bind="args" v-slot="{ ariaDescribedby }">
          <button :aria-describedby="ariaDescribedby" style="padding: 8px 16px; border: 1px solid var(--brand-brass-deep); background: transparent; color: var(--brand-brass-light); border-radius: 4px; cursor: pointer;">
            Hover me (bottom)
          </button>
        </AppTooltip>
      </div>
    `,
  }),
};

// ── Left ──────────────────────────────────────────────────────────────────────

export const Left: Story = {
  name: 'Placement — Left',
  args: { content: 'Shown to the left', placement: 'left' },
  render: (args) => ({
    components: { AppTooltip },
    setup() {
      return { args };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px;">
        <AppTooltip v-bind="args" v-slot="{ ariaDescribedby }">
          <button :aria-describedby="ariaDescribedby" style="padding: 8px 16px; border: 1px solid var(--brand-brass-deep); background: transparent; color: var(--brand-brass-light); border-radius: 4px; cursor: pointer;">
            Hover me (left)
          </button>
        </AppTooltip>
      </div>
    `,
  }),
};

// ── With Delay ────────────────────────────────────────────────────────────────

export const WithDelay: Story = {
  name: 'With Delay — 800ms',
  args: { content: 'Appears after 800ms', delay: 800 },
  render: (args) => ({
    components: { AppTooltip },
    setup() {
      return { args };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px;">
        <AppTooltip v-bind="args" v-slot="{ ariaDescribedby }">
          <button :aria-describedby="ariaDescribedby" style="padding: 8px 16px; border: 1px solid var(--brand-brass-deep); background: transparent; color: var(--brand-brass-light); border-radius: 4px; cursor: pointer;">
            Hover — 800ms delay
          </button>
        </AppTooltip>
      </div>
    `,
  }),
};

// ── Disabled ─────────────────────────────────────────────────────────────────

export const Disabled: Story = {
  name: 'Disabled',
  args: { content: 'Never shown', disabled: true },
  render: (args) => ({
    components: { AppTooltip },
    setup() {
      return { args };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px;">
        <AppTooltip v-bind="args" v-slot="{ ariaDescribedby }">
          <button :aria-describedby="ariaDescribedby" style="padding: 8px 16px; border: 1px solid var(--brand-brass-deep); background: transparent; color: var(--brand-brass-light); border-radius: 4px; cursor: pointer; opacity: 0.4;">
            Hover — tooltip disabled
          </button>
        </AppTooltip>
      </div>
    `,
  }),
};

// ── Button with Tooltip ───────────────────────────────────────────────────────

export const ButtonWithTooltip: Story = {
  name: 'Button with Tooltip',
  args: { content: 'Next turn (N)', placement: 'top' },
  render: (args) => ({
    components: { AppTooltip },
    setup() {
      return { args };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px;">
        <AppTooltip v-bind="args" v-slot="{ ariaDescribedby }">
          <button
            :aria-describedby="ariaDescribedby"
            style="padding: 10px 20px; background: var(--brand-brass); color: var(--text-on-brass); border: none; border-radius: 4px; cursor: pointer; font-family: var(--type-body-md-font-family);"
          >
            Next turn →
          </button>
        </AppTooltip>
      </div>
    `,
  }),
};

// ── Icon with Tooltip ─────────────────────────────────────────────────────────

export const IconWithTooltip: Story = {
  name: 'Icon with Tooltip',
  args: { content: 'Show keyboard shortcuts', placement: 'bottom' },
  render: (args) => ({
    components: { AppTooltip },
    setup() {
      return { args };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px;">
        <AppTooltip v-bind="args" v-slot="{ ariaDescribedby }">
          <button
            :aria-describedby="ariaDescribedby"
            aria-label="Show keyboard shortcuts"
            style="width: 36px; height: 36px; border: 1px solid var(--brand-brass-deep); background: transparent; color: var(--brand-brass); border-radius: 4px; cursor: pointer; font-size: 16px;"
          >
            ?
          </button>
        </AppTooltip>
      </div>
    `,
  }),
};

// ── All Placements ─────────────────────────────────────────────────────────────

export const AllPlacements: Story = {
  name: 'All Placements',
  render: () => ({
    components: { AppTooltip },
    setup() {
      return { placements: PLACEMENTS };
    },
    template: `
      <div style="display: flex; justify-content: center; gap: 32px; padding: 80px; flex-wrap: wrap;">
        <AppTooltip
          v-for="p in placements"
          :key="p"
          :content="'Placement: ' + p"
          :placement="p"
          :delay="0"
          v-slot="{ ariaDescribedby }"
        >
          <button
            :aria-describedby="ariaDescribedby"
            style="padding: 8px 16px; border: 1px solid var(--brand-brass-deep); background: transparent; color: var(--brand-brass-light); border-radius: 4px; cursor: pointer;"
          >
            {{ p }}
          </button>
        </AppTooltip>
      </div>
    `,
  }),
};
