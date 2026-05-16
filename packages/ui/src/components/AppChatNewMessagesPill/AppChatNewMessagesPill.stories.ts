import AppChatNewMessagesPill from './AppChatNewMessagesPill.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppChatNewMessagesPill> = {
  title: 'Coriolis/AppChatNewMessagesPill',
  component: AppChatNewMessagesPill,
  tags: ['autodocs'],
  argTypes: {
    count: { control: { type: 'number', min: 0, max: 999 } },
  },
  args: {
    count: 3,
  },
  parameters: {
    docs: {
      description: {
        component:
          'New messages pill — floats above the chat composer to alert the user of unread messages below the scroll position. Renders nothing when count === 0. Emits "click" so the panel can scroll to bottom. Slide-in animation is skipped under prefers-reduced-motion: reduce.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppChatNewMessagesPill>;

const bg = (): string =>
  `padding:48px;background:var(--surface-void);display:inline-flex;align-items:center;gap:24px;flex-wrap:wrap;`;

// ── Count = 1 ─────────────────────────────────────────────────────────────────

export const One: Story = {
  name: '1 new message',
  args: { count: 1 },
  render: (args) => ({
    components: { AppChatNewMessagesPill },
    setup() {
      return { args };
    },
    template: `<div style="${bg()}"><AppChatNewMessagesPill v-bind="args" /></div>`,
  }),
};

// ── Count = 3 ─────────────────────────────────────────────────────────────────

export const Three: Story = {
  name: '3 new messages',
  args: { count: 3 },
  render: (args) => ({
    components: { AppChatNewMessagesPill },
    setup() {
      return { args };
    },
    template: `<div style="${bg()}"><AppChatNewMessagesPill v-bind="args" /></div>`,
  }),
};

// ── Count = 99 ────────────────────────────────────────────────────────────────

export const NinetyNine: Story = {
  name: '99 new messages',
  args: { count: 99 },
  render: (args) => ({
    components: { AppChatNewMessagesPill },
    setup() {
      return { args };
    },
    template: `<div style="${bg()}"><AppChatNewMessagesPill v-bind="args" /></div>`,
  }),
};

// ── Reduced motion ────────────────────────────────────────────────────────────

export const ReducedMotion: Story = {
  name: 'Reduced motion (no slide-in)',
  args: { count: 5 },
  parameters: {
    // Storybook reduced-motion addon: when active, the @media
    // (prefers-reduced-motion: reduce) block suppresses the animation.
    reducedMotion: 'reduce',
  },
  render: (args) => ({
    components: { AppChatNewMessagesPill },
    setup() {
      return { args };
    },
    template: `<div style="${bg()}"><AppChatNewMessagesPill v-bind="args" /></div>`,
  }),
};

// ── Hidden (count = 0) ────────────────────────────────────────────────────────

export const Hidden: Story = {
  name: 'Hidden — count 0',
  args: { count: 0 },
  render: (args) => ({
    components: { AppChatNewMessagesPill },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg()}">
        <span style="font-family:var(--font-body);font-size:12px;color:var(--text-secondary);">
          count=0 → nothing rendered
        </span>
        <AppChatNewMessagesPill v-bind="args" />
      </div>
    `,
  }),
};
