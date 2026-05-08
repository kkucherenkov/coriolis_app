import AppDie from './AppDie.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const VALUES = [1, 2, 3, 4, 5, 6] as const;
const STATES = ['normal', 'hit', 'pushed', 'failed'] as const;
const SIZES = ['sm', 'md', 'lg'] as const;

const meta: Meta<typeof AppDie> = {
  title: 'Coriolis/AppDie',
  component: AppDie,
  tags: ['autodocs'],
  argTypes: {
    value: { control: { type: 'select' }, options: VALUES },
    state: { control: { type: 'select' }, options: STATES },
    size: { control: { type: 'select' }, options: SIZES },
    ariaLabel: { control: 'text' },
  },
  args: {
    value: 6,
    state: 'normal',
    size: 'md',
  },
};

export default meta;

type Story = StoryObj<typeof AppDie>;

// ── Default (single die) ─────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — value=6, normal',
  args: { value: 6, state: 'normal', size: 'md' },
};

// ── Values 1–6 (all faces) ────────────────────────────────────────────────────

export const Values1Through6: Story = {
  name: 'Values 1–6 (all faces)',
  render: () => ({
    components: { AppDie },
    setup() {
      return { values: VALUES };
    },
    template: `
      <div style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;padding:24px;background:var(--surface-void);">
        <AppDie v-for="v in values" :key="v" :value="v" state="normal" size="lg" />
      </div>
    `,
  }),
};

// ── Hit state (value=6, teal glow) ───────────────────────────────────────────

export const HitState: Story = {
  name: 'Hit — value=6 (teal glow)',
  args: { value: 6, state: 'hit', size: 'lg' },
};

// ── Pushed state ──────────────────────────────────────────────────────────────

export const PushedState: Story = {
  name: 'Pushed — value=3 (crimson halo)',
  args: { value: 3, state: 'pushed', size: 'lg' },
};

// ── Failed state ──────────────────────────────────────────────────────────────

export const FailedState: Story = {
  name: 'Failed — value=1 (crimson pips)',
  args: { value: 1, state: 'failed', size: 'lg' },
};

// ── Sizes row ─────────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes — sm / md / lg (value=4)',
  render: () => ({
    components: { AppDie },
    setup() {
      return { sizes: SIZES };
    },
    template: `
      <div style="display:flex;gap:16px;align-items:center;padding:24px;background:var(--surface-void);">
        <AppDie v-for="s in sizes" :key="s" :value="4" state="normal" :size="s" />
      </div>
    `,
  }),
};

// ── All states grid ───────────────────────────────────────────────────────────

export const AllStatesGrid: Story = {
  name: 'All States Grid (value=6)',
  render: () => ({
    components: { AppDie },
    setup() {
      return { states: STATES };
    },
    template: `
      <div style="display:flex;gap:16px;flex-direction:column;padding:24px;background:var(--surface-void);">
        <div v-for="s in states" :key="s" style="display:flex;gap:12px;align-items:center;">
          <span style="width:64px;font-size:12px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ s }}</span>
          <AppDie :value="6" :state="s" size="lg" />
        </div>
      </div>
    `,
  }),
};

// ── All values, hit state ─────────────────────────────────────────────────────

export const AllValuesHit: Story = {
  name: 'All Values — Hit State',
  render: () => ({
    components: { AppDie },
    setup() {
      return { values: VALUES };
    },
    template: `
      <div style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;padding:24px;background:var(--surface-void);">
        <AppDie v-for="v in values" :key="v" :value="v" state="hit" size="md" />
      </div>
    `,
  }),
};

// ── All values, pushed state ──────────────────────────────────────────────────

export const AllValuesPushed: Story = {
  name: 'All Values — Pushed State',
  render: () => ({
    components: { AppDie },
    setup() {
      return { values: VALUES };
    },
    template: `
      <div style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;padding:24px;background:var(--surface-void);">
        <AppDie v-for="v in values" :key="v" :value="v" state="pushed" size="md" />
      </div>
    `,
  }),
};

// ── All values, failed state ──────────────────────────────────────────────────

export const AllValuesFailed: Story = {
  name: 'All Values — Failed State',
  render: () => ({
    components: { AppDie },
    setup() {
      return { values: VALUES };
    },
    template: `
      <div style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;padding:24px;background:var(--surface-void);">
        <AppDie v-for="v in values" :key="v" :value="v" state="failed" size="md" />
      </div>
    `,
  }),
};

// ── Custom aria-label ─────────────────────────────────────────────────────────

export const CustomAriaLabel: Story = {
  name: 'Custom aria-label',
  args: {
    value: 6,
    state: 'hit',
    size: 'md',
    ariaLabel: 'Success — die showing 6',
  },
};

// ── Large pool (dice-roller layout) ──────────────────────────────────────────

export const LargePool: Story = {
  name: 'Pool of 8 dice (dice-roller layout)',
  render: () => ({
    components: { AppDie },
    setup() {
      const pool = [6, 3, 1, 5, 4, 6, 2, 4] as const;
      return { pool };
    },
    template: `
      <div style="padding:18px;background:var(--surface-void);border:1px solid var(--brand-brass-shadow);border-radius:4px;display:inline-flex;gap:8px;flex-wrap:wrap;">
        <AppDie
          v-for="(v, i) in pool"
          :key="i"
          :value="v"
          :state="v === 6 ? 'hit' : 'normal'"
          size="lg"
        />
      </div>
    `,
  }),
};
