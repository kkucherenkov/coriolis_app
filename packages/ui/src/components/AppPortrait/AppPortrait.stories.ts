import AppPortrait from './AppPortrait.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppPortrait> = {
  title: 'Coriolis/AppPortrait',
  component: AppPortrait,
  tags: ['autodocs'],
  argTypes: {
    name: { control: { type: 'text' } },
    initials: { control: { type: 'text' } },
    size: { control: { type: 'number', min: 32, max: 160, step: 8 } },
    label: { control: { type: 'text' } },
  },
  args: {
    name: 'Aelyn Skarn',
    size: 96,
  },
  parameters: {
    docs: {
      description: {
        component:
          'Character portrait medallion — Forum initials inside a brass-rimmed indigo disc with 24 astrolabe ticks. Used as the canonical character / NPC portrait across sheet hero, combat tracker, GM crew list, member lists, and chat bubbles. Distinct from AppAvatar (generic initials/image avatar in account chrome).',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppPortrait>;

const bg = (theme: 'dark' | 'light' = 'dark'): string => {
  const surface = theme === 'dark' ? 'var(--surface-void)' : 'var(--surface-parchment)';
  return `padding:48px;background:${surface};display:inline-flex;align-items:center;gap:24px;flex-wrap:wrap;`;
};

// ── Default ─────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — Aelyn Skarn / 96',
  render: (args) => ({
    components: { AppPortrait },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg()}">
        <AppPortrait v-bind="args" />
      </div>
    `,
  }),
};

// ── Size sweep ──────────────────────────────────────────────────────────────

export const SizeSweep: Story = {
  name: 'Size sweep — 48 / 64 / 80 / 96 / 128',
  render: () => ({
    components: { AppPortrait },
    setup() {
      return { sizes: [48, 64, 80, 96, 128] as const };
    },
    template: `
      <div style="${bg()}">
        <div v-for="s in sizes" :key="s" style="display:flex;flex-direction:column;gap:6px;align-items:center;">
          <AppPortrait name="Aelyn Skarn" :size="s" />
          <span style="font-family:Inter,sans-serif;font-size:11px;color:var(--text-secondary);">size = {{ s }}px</span>
        </div>
      </div>
    `,
  }),
};

// ── Empty state (no name) ───────────────────────────────────────────────────

export const EmptyName: Story = {
  name: 'No name — falls back to "NA"',
  args: { name: undefined, initials: undefined, size: 96 },
  render: (args) => ({
    components: { AppPortrait },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg()}">
        <AppPortrait v-bind="args" />
      </div>
    `,
  }),
};

// ── Explicit initials override ──────────────────────────────────────────────

export const InitialsOverride: Story = {
  name: 'Initials override — explicit "AS"',
  args: { name: 'Some Other Name', initials: 'AS', size: 96 },
  render: (args) => ({
    components: { AppPortrait },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg()}">
        <AppPortrait v-bind="args" />
      </div>
    `,
  }),
};

// ── Cyrillic ────────────────────────────────────────────────────────────────

export const Localized: Story = {
  name: 'Localized — Cyrillic name',
  args: { name: 'Айлин Скарн', size: 96 },
  render: (args) => ({
    components: { AppPortrait },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg()}">
        <AppPortrait v-bind="args" />
      </div>
    `,
  }),
};

// ── Crew row — combat tracker / GM session use ──────────────────────────────

export const CrewRow: Story = {
  name: 'Crew row — sheet / combat / GM',
  render: () => ({
    components: { AppPortrait },
    setup() {
      return {
        crew: [
          { name: 'Aelyn Skarn', size: 80 },
          { name: 'Junad Vex', size: 80 },
          { name: 'Mira Hess', size: 80 },
          { name: 'Doctor Halun', size: 80 },
        ] as const,
      };
    },
    template: `
      <div style="${bg()}">
        <div v-for="m in crew" :key="m.name" style="display:flex;flex-direction:column;gap:10px;align-items:center;">
          <AppPortrait :name="m.name" :size="m.size" />
          <span style="font-family:Forum,serif;font-size:14px;color:var(--brand-brass-light);letter-spacing:0.04em;text-align:center;">{{ m.name }}</span>
        </div>
      </div>
    `,
  }),
};

// ── On parchment (share-viewer surface) ─────────────────────────────────────

export const OnParchment: Story = {
  name: 'On parchment — share-viewer surface',
  render: () => ({
    components: { AppPortrait },
    template: `
      <div style="${bg('light')}">
        <AppPortrait name="Aelyn Skarn" :size="96" />
      </div>
    `,
  }),
};
