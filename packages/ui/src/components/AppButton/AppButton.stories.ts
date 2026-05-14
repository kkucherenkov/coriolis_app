import AppButton from './AppButton.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

// Inline placeholder SVG used in icon slot stories — no external icon dependency.
const StarSvg = `<svg width="16" height="16" viewBox="0 0 32 32" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.5">
  <rect x="6" y="6" width="20" height="20"/>
  <rect x="6" y="6" width="20" height="20" transform="rotate(45 16 16)"/>
  <circle cx="16" cy="16" r="2.2" fill="currentColor" stroke="none"/>
</svg>`;

const meta: Meta<typeof AppButton> = {
  title: 'Primitives/AppButton',
  component: AppButton,
  tags: ['autodocs'],
  args: {},
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'ghost', 'danger', 'mystic'],
    },
    size: { control: 'select', options: ['sm', 'md', 'lg'] },
    disabled: { control: 'boolean' },
    loading: { control: 'boolean' },
    type: { control: 'select', options: ['button', 'submit', 'reset'] },
  },
};

export default meta;

type Story = StoryObj<typeof AppButton>;

// ── Variant × size matrix ─────────────────────────────────────────────────────

export const PrimarySm: Story = {
  name: 'Primary / sm',
  args: { variant: 'primary', size: 'sm' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Submit</AppButton>`,
  }),
};

export const PrimaryMd: Story = {
  name: 'Primary / md',
  args: { variant: 'primary', size: 'md' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Submit</AppButton>`,
  }),
};

export const PrimaryLg: Story = {
  name: 'Primary / lg',
  args: { variant: 'primary', size: 'lg' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Submit</AppButton>`,
  }),
};

export const SecondarySm: Story = {
  name: 'Secondary / sm — Cancel / Skip',
  args: { variant: 'secondary', size: 'sm' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Cancel</AppButton>`,
  }),
};

export const SecondaryMd: Story = {
  name: 'Secondary / md — Cancel / Skip',
  args: { variant: 'secondary', size: 'md' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Cancel</AppButton>`,
  }),
};

export const SecondaryLg: Story = {
  name: 'Secondary / lg — Cancel / Skip',
  args: { variant: 'secondary', size: 'lg' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Cancel</AppButton>`,
  }),
};

export const GhostSm: Story = {
  name: 'Ghost / sm',
  args: { variant: 'ghost', size: 'sm' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Cancel</AppButton>`,
  }),
};

export const GhostMd: Story = {
  name: 'Ghost / md',
  args: { variant: 'ghost', size: 'md' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Cancel</AppButton>`,
  }),
};

export const GhostLg: Story = {
  name: 'Ghost / lg',
  args: { variant: 'ghost', size: 'lg' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Cancel</AppButton>`,
  }),
};

export const DangerSm: Story = {
  name: 'Danger / sm',
  args: { variant: 'danger', size: 'sm' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Delete</AppButton>`,
  }),
};

export const DangerMd: Story = {
  name: 'Danger / md',
  args: { variant: 'danger', size: 'md' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Delete</AppButton>`,
  }),
};

export const DangerLg: Story = {
  name: 'Danger / lg',
  args: { variant: 'danger', size: 'lg' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Delete</AppButton>`,
  }),
};

// ── Variant: mystic (ritual CTAs) ────────────────────────────────────────────

export const MysticPushTheRoll: Story = {
  name: 'Mystic — Push the Roll',
  args: { variant: 'mystic', size: 'md' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Push the Roll · 1 DP</AppButton>`,
  }),
};

export const MysticLg: Story = {
  name: 'Mystic / lg — ritual hero CTA',
  args: { variant: 'mystic', size: 'lg' },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Pray for guidance</AppButton>`,
  }),
};

// ── Reduced motion (mystic loading) ──────────────────────────────────────────

export const MysticLoadingReducedMotion: Story = {
  name: 'Mystic loading — reduced motion',
  args: { variant: 'mystic', size: 'md', loading: true },
  parameters: { pseudo: { reducedMotion: 'reduce' } },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Pushing…</AppButton>`,
  }),
};

// ── Special states ────────────────────────────────────────────────────────────

export const Disabled: Story = {
  args: { variant: 'primary', size: 'md', disabled: true },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Disabled</AppButton>`,
  }),
};

export const Loading: Story = {
  args: { variant: 'primary', size: 'md', loading: true },
  render: (args) => ({
    components: { AppButton },
    setup: () => ({ args }),
    template: `<AppButton v-bind="args">Saving…</AppButton>`,
  }),
};

// ── Icon slots ────────────────────────────────────────────────────────────────

export const WithLeadingIcon: Story = {
  name: 'With leading icon',
  render: () => ({
    components: { AppButton },
    setup: () => ({ star: StarSvg }),
    template: `
      <AppButton variant="primary" size="md">
        <template #icon-leading>
          <span v-html="star" style="display:inline-flex;align-items:center;" />
        </template>
        Confirm
      </AppButton>
    `,
  }),
};

export const WithTrailingIcon: Story = {
  name: 'With trailing icon',
  render: () => ({
    components: { AppButton },
    setup: () => ({ star: StarSvg }),
    template: `
      <AppButton variant="ghost" size="md">
        Next
        <template #icon-trailing>
          <span v-html="star" style="display:inline-flex;align-items:center;" />
        </template>
      </AppButton>
    `,
  }),
};

export const WithBothIcons: Story = {
  name: 'With both icons',
  render: () => ({
    components: { AppButton },
    setup: () => ({ star: StarSvg }),
    template: `
      <AppButton variant="primary" size="md">
        <template #icon-leading>
          <span v-html="star" style="display:inline-flex;align-items:center;" />
        </template>
        Roll Dice
        <template #icon-trailing>
          <span v-html="star" style="display:inline-flex;align-items:center;" />
        </template>
      </AppButton>
    `,
  }),
};

// ── Full matrix overview ──────────────────────────────────────────────────────

export const AllVariants: Story = {
  name: 'All variants',
  render: () => ({
    components: { AppButton },
    template: `
      <div style="display:flex; flex-direction:column; gap:var(--space-4);">
        <div style="display:flex; gap:var(--space-3); align-items:center;">
          <AppButton variant="primary" size="sm">Primary sm</AppButton>
          <AppButton variant="primary" size="md">Primary md</AppButton>
          <AppButton variant="primary" size="lg">Primary lg</AppButton>
        </div>
        <div style="display:flex; gap:var(--space-3); align-items:center;">
          <AppButton variant="secondary" size="sm">Secondary sm</AppButton>
          <AppButton variant="secondary" size="md">Secondary md</AppButton>
          <AppButton variant="secondary" size="lg">Secondary lg</AppButton>
        </div>
        <div style="display:flex; gap:var(--space-3); align-items:center;">
          <AppButton variant="ghost" size="sm">Ghost sm</AppButton>
          <AppButton variant="ghost" size="md">Ghost md</AppButton>
          <AppButton variant="ghost" size="lg">Ghost lg</AppButton>
        </div>
        <div style="display:flex; gap:var(--space-3); align-items:center;">
          <AppButton variant="danger" size="sm">Danger sm</AppButton>
          <AppButton variant="danger" size="md">Danger md</AppButton>
          <AppButton variant="danger" size="lg">Danger lg</AppButton>
        </div>
        <div style="display:flex; gap:var(--space-3); align-items:center;">
          <AppButton variant="mystic" size="sm">Mystic sm</AppButton>
          <AppButton variant="mystic" size="md">Push the Roll</AppButton>
          <AppButton variant="mystic" size="lg">Pray</AppButton>
        </div>
        <div style="display:flex; gap:var(--space-3); align-items:center;">
          <AppButton variant="primary" size="md" disabled>Disabled</AppButton>
          <AppButton variant="secondary" size="md" disabled>Disabled</AppButton>
          <AppButton variant="ghost" size="md" disabled>Disabled</AppButton>
          <AppButton variant="danger" size="md" disabled>Disabled</AppButton>
          <AppButton variant="mystic" size="md" disabled>Disabled</AppButton>
        </div>
      </div>
    `,
  }),
};
