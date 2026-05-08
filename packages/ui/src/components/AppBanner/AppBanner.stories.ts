import type { Meta, StoryObj } from '@storybook/vue3';

import AppBanner from './AppBanner.vue';

const TONES = ['info', 'success', 'warning', 'danger', 'parchment'] as const;

const meta: Meta<typeof AppBanner> = {
  title: 'Primitives/AppBanner',
  component: AppBanner,
  tags: ['autodocs'],
  argTypes: {
    tone: { control: 'select', options: TONES },
    title: { control: 'text' },
    icon: { control: 'text' },
    dismissible: { control: 'boolean' },
  },
  args: {
    tone: 'info',
    title: 'Notification',
    dismissible: false,
  },
};

export default meta;

type Story = StoryObj<typeof AppBanner>;

// ── Info ──────────────────────────────────────────────────────────────────────

export const Info: Story = {
  name: 'Info',
  args: {
    tone: 'info',
    title: 'System Information',
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `<AppBanner v-bind="args">New features have been added to your character sheet.</AppBanner>`,
  }),
};

// ── Success ───────────────────────────────────────────────────────────────────

export const Success: Story = {
  name: 'Success',
  args: {
    tone: 'success',
    title: 'Saved Successfully',
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `<AppBanner v-bind="args">Your character sheet has been saved.</AppBanner>`,
  }),
};

// ── Warning ───────────────────────────────────────────────────────────────────

export const Warning: Story = {
  name: 'Warning',
  args: {
    tone: 'warning',
    title: 'Unsaved Changes',
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `<AppBanner v-bind="args">You have unsaved changes. Remember to save before leaving.</AppBanner>`,
  }),
};

// ── Danger ────────────────────────────────────────────────────────────────────

export const Danger: Story = {
  name: 'Danger',
  args: {
    tone: 'danger',
    title: 'Critical Error',
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `<AppBanner v-bind="args">Failed to connect to the server. Your changes may not have been saved.</AppBanner>`,
  }),
};

// ── Parchment — share-viewer "read-only" notice ───────────────────────────────

export const Parchment: Story = {
  name: 'Parchment (Share Viewer)',
  args: {
    tone: 'parchment',
    title: 'Read-only view',
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `
      <div style="background: var(--surface-void); padding: var(--space-6); border-radius: var(--radius-md);">
        <AppBanner v-bind="args">Sign in to create your own character sheet.</AppBanner>
      </div>
    `,
  }),
};

// ── Dismissible ───────────────────────────────────────────────────────────────

export const Dismissible: Story = {
  name: 'Dismissible',
  args: {
    tone: 'info',
    title: 'Fan Project Notice',
    dismissible: true,
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `
      <AppBanner v-bind="args" @dismiss="console.log('dismissed')">
        Coriolis Companion is an unofficial fan project, not affiliated with Free League Publishing.
      </AppBanner>
    `,
  }),
};

// ── With Actions Slot ─────────────────────────────────────────────────────────

export const WithActionsSlot: Story = {
  name: 'With Actions Slot',
  args: {
    tone: 'warning',
    title: 'Session Expiring',
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `
      <AppBanner v-bind="args">
        Your session will expire in 5 minutes.
        <template #actions>
          <button style="font-size: var(--type-body-sm-font-size); color: var(--brand-brass); background: none; border: none; cursor: pointer; padding: 0;">
            Extend Session
          </button>
        </template>
      </AppBanner>
    `,
  }),
};

// ── Long Message ──────────────────────────────────────────────────────────────

export const LongMessage: Story = {
  name: 'Long Message',
  args: {
    tone: 'info',
    title: 'Fan Project Disclaimer',
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `
      <AppBanner v-bind="args">
        Coriolis Companion is an unofficial fan-made tool created for personal and community use.
        It is not affiliated with, endorsed by, or connected to Free League Publishing in any way.
        All Coriolis-related trademarks, artwork, and intellectual property belong to Free League Publishing.
        This app is free, non-commercial, and intended solely to enhance your gaming experience.
      </AppBanner>
    `,
  }),
};

// ── Icon Override ─────────────────────────────────────────────────────────────

export const IconOverride: Story = {
  name: 'Icon Override',
  args: {
    tone: 'parchment',
    title: 'Shared by Iskander Vahn',
    icon: 'share-2',
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `
      <div style="background: var(--surface-void); padding: var(--space-6); border-radius: var(--radius-md);">
        <AppBanner v-bind="args">Last updated 2 hours ago · Read-only view</AppBanner>
      </div>
    `,
  }),
};

// ── Minimal — No Title ────────────────────────────────────────────────────────

export const MinimalNoTitle: Story = {
  name: 'Minimal — No Title',
  args: {
    tone: 'success',
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `<AppBanner v-bind="args">Character saved at 14:23.</AppBanner>`,
  }),
};

// ── Dismissible Parchment ─────────────────────────────────────────────────────

export const DismissibleParchment: Story = {
  name: 'Dismissible Parchment',
  args: {
    tone: 'parchment',
    title: 'Read-only view',
    dismissible: true,
  },
  render: (args) => ({
    components: { AppBanner },
    setup: () => ({ args }),
    template: `
      <div style="background: var(--surface-void); padding: var(--space-6); border-radius: var(--radius-md);">
        <AppBanner v-bind="args" @dismiss="console.log('dismissed')">
          Sign in to create your own character sheet.
        </AppBanner>
      </div>
    `,
  }),
};

// ── All Tones Overview ────────────────────────────────────────────────────────

export const AllTones: Story = {
  name: 'All Tones',
  render: () => ({
    components: { AppBanner },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-3);">
        <AppBanner tone="info" title="Info Banner">Subtle brass-deep border, surface-night background.</AppBanner>
        <AppBanner tone="success" title="Success Banner">State-success accents for positive feedback.</AppBanner>
        <AppBanner tone="warning" title="Warning Banner">Brass-deep accents, elevated visual weight.</AppBanner>
        <AppBanner tone="danger" title="Danger Banner">Crimson border and bright icon for critical alerts.</AppBanner>
        <div style="background: var(--surface-void); padding: var(--space-4); border-radius: var(--radius-md);">
          <AppBanner tone="parchment" title="Parchment Banner">Inverted light surface — share-viewer read-only notice.</AppBanner>
        </div>
      </div>
    `,
  }),
};
