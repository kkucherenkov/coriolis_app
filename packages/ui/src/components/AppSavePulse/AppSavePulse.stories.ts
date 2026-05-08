import AppSavePulse from './AppSavePulse.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppSavePulse> = {
  title: 'Coriolis/AppSavePulse',
  component: AppSavePulse,
  tags: ['autodocs'],
  parameters: {
    // color-contrast is disabled globally in .storybook/preview.ts; the dot
    // is also aria-hidden, with the accessible label provided by an sr-only
    // sibling on the consuming page.
    backgrounds: {
      default: 'void',
      values: [{ name: 'void', value: 'var(--surface-void, #0a0c10)' }],
    },
  },
  argTypes: {
    state: {
      control: { type: 'select' },
      options: ['idle', 'saving', 'saved', 'error'],
    },
  },
  args: { state: 'idle' },
};

export default meta;

type Story = StoryObj<typeof AppSavePulse>;

// ── Idle ──────────────────────────────────────────────────────────────────────

export const Idle: Story = {
  name: 'Idle — dim brass dot',
  args: { state: 'idle' },
  render: (args) => ({
    components: { AppSavePulse },
    setup: () => ({ args }),
    template: `
      <div style="display:flex;align-items:center;gap:12px;padding:24px;">
        <AppSavePulse v-bind="args" />
        <span style="font-family:Inter,sans-serif;font-size:12px;color:var(--text-secondary,#9ca3af);">idle</span>
      </div>
    `,
  }),
};

// ── Saving ────────────────────────────────────────────────────────────────────

export const Saving: Story = {
  name: 'Saving — pulsing brass dot',
  args: { state: 'saving' },
  render: (args) => ({
    components: { AppSavePulse },
    setup: () => ({ args }),
    template: `
      <div style="display:flex;align-items:center;gap:12px;padding:24px;">
        <AppSavePulse v-bind="args" />
        <span style="font-family:Inter,sans-serif;font-size:12px;color:var(--text-secondary,#9ca3af);">saving…</span>
      </div>
    `,
  }),
};

// ── Saved ─────────────────────────────────────────────────────────────────────

export const Saved: Story = {
  name: 'Saved — solid bright dot',
  args: { state: 'saved' },
  render: (args) => ({
    components: { AppSavePulse },
    setup: () => ({ args }),
    template: `
      <div style="display:flex;align-items:center;gap:12px;padding:24px;">
        <AppSavePulse v-bind="args" />
        <span style="font-family:Inter,sans-serif;font-size:12px;color:var(--text-secondary,#9ca3af);">saved</span>
      </div>
    `,
  }),
};

// ── Error ─────────────────────────────────────────────────────────────────────

export const Error: Story = {
  name: 'Error — crimson dot',
  args: { state: 'error' },
  render: (args) => ({
    components: { AppSavePulse },
    setup: () => ({ args }),
    template: `
      <div style="display:flex;align-items:center;gap:12px;padding:24px;">
        <AppSavePulse v-bind="args" />
        <span style="font-family:Inter,sans-serif;font-size:12px;color:var(--state-crimson-bright,#e54e6b);">save failed</span>
      </div>
    `,
  }),
};

// ── All states matrix ─────────────────────────────────────────────────────────

export const AllStates: Story = {
  name: 'All states — matrix',
  render: () => ({
    components: { AppSavePulse },
    setup() {
      return {
        states: [
          { state: 'idle', label: 'idle' },
          { state: 'saving', label: 'saving…' },
          { state: 'saved', label: 'saved' },
          { state: 'error', label: 'error' },
        ] as const,
      };
    },
    template: `
      <div style="display:flex;flex-direction:column;gap:16px;padding:24px;">
        <div
          v-for="s in states"
          :key="s.state"
          style="display:flex;align-items:center;gap:12px;"
        >
          <AppSavePulse :state="s.state" />
          <span style="font-family:Inter,sans-serif;font-size:12px;color:var(--text-secondary,#9ca3af);min-width:60px;">{{ s.label }}</span>
        </div>
      </div>
    `,
  }),
};
