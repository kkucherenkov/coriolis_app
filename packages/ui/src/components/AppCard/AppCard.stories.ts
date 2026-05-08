import AppCard from './AppCard.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppCard> = {
  title: 'Primitives/AppCard',
  component: AppCard,
  tags: ['autodocs'],
  argTypes: {
    variant: { control: 'select', options: ['default', 'featured'] },
    as: { control: 'text' },
  },
  args: {
    variant: 'default',
    as: 'div',
  },
};

export default meta;

type Story = StoryObj<typeof AppCard>;

// ── Default ───────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default',
  args: { variant: 'default' },
  render: (args) => ({
    components: { AppCard },
    setup: () => ({ args }),
    template: `
      <AppCard v-bind="args">
        <p style="color: var(--text-primary); margin: 0;">Card body content.</p>
      </AppCard>
    `,
  }),
};

// ── Featured ──────────────────────────────────────────────────────────────────

export const Featured: Story = {
  name: 'Featured',
  args: { variant: 'featured' },
  render: (args) => ({
    components: { AppCard },
    setup: () => ({ args }),
    template: `
      <AppCard v-bind="args">
        <p style="color: var(--text-primary); margin: 0;">Featured card with beveled brass plate effect.</p>
      </AppCard>
    `,
  }),
};

// ── With header ───────────────────────────────────────────────────────────────

export const WithHeader: Story = {
  name: 'With Header',
  args: { variant: 'default' },
  render: (args) => ({
    components: { AppCard },
    setup: () => ({ args }),
    template: `
      <AppCard v-bind="args">
        <template #header>
          <h3 style="margin: 0; font-family: var(--type-display-md-font-family); font-size: var(--type-display-md-font-size);">Characters</h3>
        </template>
        <p style="color: var(--text-primary); margin: 0;">List of characters would appear here.</p>
      </AppCard>
    `,
  }),
};

// ── With footer ───────────────────────────────────────────────────────────────

export const WithFooter: Story = {
  name: 'With Footer',
  args: { variant: 'default' },
  render: (args) => ({
    components: { AppCard },
    setup: () => ({ args }),
    template: `
      <AppCard v-bind="args">
        <p style="color: var(--text-primary); margin: 0;">Card body content.</p>
        <template #footer>
          <span style="color: var(--text-secondary); font-size: var(--type-body-sm-font-size);">Last updated 2d ago</span>
        </template>
      </AppCard>
    `,
  }),
};

// ── With header and footer ────────────────────────────────────────────────────

export const WithHeaderAndFooter: Story = {
  name: 'With Header and Footer',
  args: { variant: 'default' },
  render: (args) => ({
    components: { AppCard },
    setup: () => ({ args }),
    template: `
      <AppCard v-bind="args">
        <template #header>
          <h3 style="margin: 0; font-family: var(--type-display-md-font-family); font-size: var(--type-display-md-font-size);">Active Session</h3>
        </template>
        <p style="color: var(--text-primary); margin: 0;">The Mercy of Kua — Session 12</p>
        <template #footer>
          <span style="color: var(--text-secondary); font-size: var(--type-body-sm-font-size);">Tonight</span>
        </template>
      </AppCard>
    `,
  }),
};

// ── Body with long text ───────────────────────────────────────────────────────

export const BodyWithLongText: Story = {
  name: 'Body with Long Text',
  args: { variant: 'default' },
  render: (args) => ({
    components: { AppCard },
    setup: () => ({ args }),
    template: `
      <AppCard v-bind="args" style="max-width: 480px;">
        <template #header>
          <h3 style="margin: 0; font-family: var(--type-display-md-font-family); font-size: var(--type-display-md-font-size);">Session Notes</h3>
        </template>
        <p style="color: var(--text-primary); margin: 0 0 var(--space-3);">
          The crew of the Madara received a distress call from the outer station Dabaran-7.
          Upon arrival they found the station's comms array offline and the docking bay sealed
          from the inside. Tariq managed to bypass the emergency lock after a tense negotiation
          with the onboard AI while Yara sensed a deep unease from the direction of the cargo hold.
        </p>
        <p style="color: var(--text-secondary); margin: 0;">
          Session ended on a cliffhanger — next session starts at the cargo bay doors.
        </p>
      </AppCard>
    `,
  }),
};

// ── Polymorphic ───────────────────────────────────────────────────────────────

export const Polymorphic: Story = {
  name: 'Polymorphic (as="article")',
  args: { variant: 'default', as: 'article' },
  render: (args) => ({
    components: { AppCard },
    setup: () => ({ args }),
    template: `
      <AppCard v-bind="args">
        <template #header>
          <h3 style="margin: 0; font-family: var(--type-display-md-font-family); font-size: var(--type-display-md-font-size);">Tariq al-Asari</h3>
        </template>
        <p style="color: var(--text-primary); margin: 0;">Pilot · Free League · Crew of the Madara</p>
      </AppCard>
    `,
  }),
};

// ── All variants overview ─────────────────────────────────────────────────────

export const AllVariants: Story = {
  name: 'All Variants',
  render: () => ({
    components: { AppCard },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-6);">
        <AppCard variant="default">
          <template #header>
            <span style="font-family: var(--type-display-md-font-family);">Default</span>
          </template>
          <p style="color: var(--text-primary); margin: 0;">surface-night background, brass-shadow border.</p>
        </AppCard>
        <AppCard variant="featured">
          <template #header>
            <span style="font-family: var(--type-display-md-font-family);">Featured</span>
          </template>
          <p style="color: var(--text-primary); margin: 0;">Beveled brass plate — brass-deep border + inset bevel shadow.</p>
        </AppCard>
      </div>
    `,
  }),
};
