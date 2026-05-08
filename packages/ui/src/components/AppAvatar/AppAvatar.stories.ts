import AppAvatar from './AppAvatar.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;
const TONES = ['brass', 'mystic', 'crimson', 'darkness'] as const;
const SHAPES = ['circle', 'squircle'] as const;

const meta: Meta<typeof AppAvatar> = {
  title: 'Primitives/AppAvatar',
  component: AppAvatar,
  tags: ['autodocs'],
  argTypes: {
    size: { control: 'select', options: SIZES },
    tone: { control: 'select', options: TONES },
    shape: { control: 'select', options: SHAPES },
    src: { control: 'text' },
    name: { control: 'text' },
  },
  args: {
    name: 'Tariq al-Asari',
    size: 'md',
    tone: 'brass',
    shape: 'circle',
  },
};

export default meta;

type Story = StoryObj<typeof AppAvatar>;

// ── Sizes row (all initials) ─────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes (initials)',
  render: () => ({
    components: { AppAvatar },
    template: `
      <div style="display: flex; align-items: center; gap: var(--space-4);">
        <AppAvatar name="Tariq al-Asari" size="xs" />
        <AppAvatar name="Tariq al-Asari" size="sm" />
        <AppAvatar name="Tariq al-Asari" size="md" />
        <AppAvatar name="Tariq al-Asari" size="lg" />
        <AppAvatar name="Tariq al-Asari" size="xl" />
      </div>
    `,
  }),
};

// ── Tones row ────────────────────────────────────────────────────────────────

export const Tones: Story = {
  name: 'Tones',
  render: () => ({
    components: { AppAvatar },
    template: `
      <div style="display: flex; align-items: center; gap: var(--space-4);">
        <AppAvatar name="Tariq al-Asari" tone="brass" />
        <AppAvatar name="Tariq al-Asari" tone="mystic" />
        <AppAvatar name="Tariq al-Asari" tone="crimson" />
        <AppAvatar name="Tariq al-Asari" tone="darkness" />
      </div>
    `,
  }),
};

// ── Image variant ────────────────────────────────────────────────────────────

export const Image: Story = {
  name: 'Image — all sizes',
  render: () => ({
    components: { AppAvatar },
    template: `
      <div style="display: flex; align-items: center; gap: var(--space-4);">
        <AppAvatar name="Tariq al-Asari" src="https://picsum.photos/seed/tariq/96/96" size="xs" />
        <AppAvatar name="Tariq al-Asari" src="https://picsum.photos/seed/tariq/96/96" size="sm" />
        <AppAvatar name="Tariq al-Asari" src="https://picsum.photos/seed/tariq/96/96" size="md" />
        <AppAvatar name="Tariq al-Asari" src="https://picsum.photos/seed/tariq/96/96" size="lg" />
        <AppAvatar name="Tariq al-Asari" src="https://picsum.photos/seed/tariq/96/96" size="xl" />
      </div>
    `,
  }),
};

// ── Image error fallback → initials ─────────────────────────────────────────

export const ImageWithErrorFallback: Story = {
  name: 'Image error → initials fallback',
  render: () => ({
    components: { AppAvatar },
    template: `
      <div style="display: flex; align-items: center; gap: var(--space-4);">
        <AppAvatar name="Tariq al-Asari" src="https://broken.invalid/portrait.jpg" size="md" />
        <AppAvatar name="Tariq al-Asari" src="https://broken.invalid/portrait.jpg" size="lg" />
      </div>
    `,
  }),
};

// ── Cyrillic name ────────────────────────────────────────────────────────────

export const CyrillicName: Story = {
  name: 'Cyrillic name → ТА',
  render: () => ({
    components: { AppAvatar },
    template: `
      <div style="display: flex; align-items: center; gap: var(--space-4);">
        <AppAvatar name="Тарик аль-Асари" size="lg" />
        <AppAvatar name="Тарик аль-Асари" size="xl" />
      </div>
    `,
  }),
};

// ── Multi-word name ──────────────────────────────────────────────────────────

export const MultiWordName: Story = {
  name: 'Multi-word name → 2 initials max',
  render: () => ({
    components: { AppAvatar },
    template: `
      <div style="display: flex; align-items: center; gap: var(--space-4);">
        <AppAvatar name="Tariq al-Asari the Exile" size="lg" />
        <AppAvatar name="Tariq al-Asari" size="lg" />
      </div>
    `,
  }),
};

// ── Single-word name ─────────────────────────────────────────────────────────

export const SingleWordName: Story = {
  name: 'Single-word name → 1 initial',
  render: () => ({
    components: { AppAvatar },
    template: `<AppAvatar name="Nexus" size="lg" />`,
  }),
};

// ── Squircle shape ───────────────────────────────────────────────────────────

export const Squircle: Story = {
  name: 'Squircle shape',
  render: () => ({
    components: { AppAvatar },
    template: `
      <div style="display: flex; align-items: center; gap: var(--space-4);">
        <AppAvatar name="Tariq al-Asari" shape="squircle" size="md" />
        <AppAvatar name="Tariq al-Asari" shape="squircle" size="lg" />
        <AppAvatar name="Tariq al-Asari" src="https://picsum.photos/seed/tariq/96/96" shape="squircle" size="lg" />
      </div>
    `,
  }),
};

// ── Group row (overlapping) ──────────────────────────────────────────────────

export const GroupRow: Story = {
  name: 'Group row (overlapping participants)',
  render: () => ({
    components: { AppAvatar },
    template: `
      <div style="display: flex; align-items: center;">
        <div style="margin-right: -10px; z-index: 5;"><AppAvatar name="Tariq al-Asari" size="sm" tone="brass" /></div>
        <div style="margin-right: -10px; z-index: 4;"><AppAvatar name="Miriam Osei" size="sm" tone="mystic" /></div>
        <div style="margin-right: -10px; z-index: 3;"><AppAvatar name="Dawit Bekele" size="sm" tone="crimson" /></div>
        <div style="margin-right: -10px; z-index: 2;"><AppAvatar name="Yasmin Nur" size="sm" tone="darkness" /></div>
        <div style="margin-left: 16px; z-index: 1;"><AppAvatar name="5 participants" size="sm" tone="brass" /></div>
      </div>
    `,
  }),
};

// ── Default (playground) ──────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default (playground)',
  args: {
    name: 'Tariq al-Asari',
    size: 'md',
    tone: 'brass',
    shape: 'circle',
  },
  render: (args) => ({
    components: { AppAvatar },
    setup: () => ({ args }),
    template: `<AppAvatar v-bind="args" />`,
  }),
};

// ── All tones × xl ───────────────────────────────────────────────────────────

export const AllTonesXl: Story = {
  name: 'All tones XL',
  render: () => ({
    components: { AppAvatar },
    template: `
      <div style="display: flex; align-items: flex-start; gap: var(--space-6); flex-wrap: wrap;">
        <div style="display:flex; flex-direction:column; align-items:center; gap: var(--space-2);">
          <AppAvatar name="Tariq al-Asari" tone="brass" size="xl" />
          <span style="font-family: var(--type-body-sm-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary);">brass</span>
        </div>
        <div style="display:flex; flex-direction:column; align-items:center; gap: var(--space-2);">
          <AppAvatar name="Tariq al-Asari" tone="mystic" size="xl" />
          <span style="font-family: var(--type-body-sm-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary);">mystic</span>
        </div>
        <div style="display:flex; flex-direction:column; align-items:center; gap: var(--space-2);">
          <AppAvatar name="Tariq al-Asari" tone="crimson" size="xl" />
          <span style="font-family: var(--type-body-sm-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary);">crimson</span>
        </div>
        <div style="display:flex; flex-direction:column; align-items:center; gap: var(--space-2);">
          <AppAvatar name="Tariq al-Asari" tone="darkness" size="xl" />
          <span style="font-family: var(--type-body-sm-font-family); font-size: var(--type-body-sm-font-size); color: var(--text-secondary);">darkness</span>
        </div>
      </div>
    `,
  }),
};

// ── Image + squircle tones ────────────────────────────────────────────────────

export const ImageSquircleTones: Story = {
  name: 'Image + squircle',
  render: () => ({
    components: { AppAvatar },
    template: `
      <div style="display: flex; align-items: center; gap: var(--space-4);">
        <AppAvatar name="Tariq al-Asari" src="https://picsum.photos/seed/tariq/96/96" shape="squircle" tone="brass" size="lg" />
        <AppAvatar name="Tariq al-Asari" src="https://picsum.photos/seed/tariq/96/96" shape="squircle" tone="mystic" size="lg" />
      </div>
    `,
  }),
};
