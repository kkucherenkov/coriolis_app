import AppDiePool from './AppDiePool.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppDiePool> = {
  title: 'Coriolis/AppDiePool',
  component: AppDiePool,
  tags: ['autodocs'],
  argTypes: {
    values: { control: 'object' },
    pushedIndices: { control: 'object' },
    size: { control: { type: 'select' }, options: ['sm', 'md', 'lg'] },
    tone: { control: { type: 'select' }, options: ['brass', 'mystic'] },
    showHitCount: { control: 'boolean' },
  },
  args: {
    values: [6, 3, 1, 5, 4, 6, 2, 4],
    pushedIndices: [],
    size: 'md',
    tone: 'brass',
    showHitCount: true,
  },
};

export default meta;

type Story = StoryObj<typeof AppDiePool>;

// Wrap stories in a dark surface for contrast.
const bg = 'padding:24px;background:var(--surface-void);display:inline-block;';

// ── Empty pool ────────────────────────────────────────────────────────────────

export const Empty: Story = {
  name: 'Empty pool (0 dice)',
  args: { values: [] },
};

// ── Single hit (6) ────────────────────────────────────────────────────────────

export const Single6: Story = {
  name: 'Single die — hit (6)',
  args: { values: [6] },
};

// ── Mixed pool ────────────────────────────────────────────────────────────────

export const Mixed: Story = {
  name: 'Mixed — 4 dice, 1 hit',
  args: { values: [6, 3, 1, 4] },
};

// ── With pushed dice ──────────────────────────────────────────────────────────

export const WithPushed: Story = {
  name: 'Pushed — 3 dice, index 1 pushed',
  args: { values: [6, 4, 2], pushedIndices: [1] },
};

// ── All sixes ─────────────────────────────────────────────────────────────────

export const AllSixes: Story = {
  name: 'All sixes (5 hits)',
  args: { values: [6, 6, 6, 6, 6] },
};

// ── All ones ──────────────────────────────────────────────────────────────────

export const AllOnes: Story = {
  name: 'All ones (0 hits)',
  args: { values: [1, 1, 1, 1] },
};

// ── Large pool ────────────────────────────────────────────────────────────────

export const LargePool: Story = {
  name: 'Large pool — 10 dice',
  args: { values: [6, 3, 1, 5, 4, 6, 2, 4, 6, 1] },
};

// ── Large pool with push ──────────────────────────────────────────────────────

export const LargePoolPushed: Story = {
  name: 'Large pool — 8 dice, 3 pushed',
  render: () => ({
    components: { AppDiePool },
    setup() {
      return {
        values: [6, 3, 1, 5, 4, 6, 2, 4] as Array<1 | 2 | 3 | 4 | 5 | 6>,
        pushedIndices: [1, 2, 4],
      };
    },
    template: `<div style="${bg}"><AppDiePool :values="values" :pushed-indices="pushedIndices" size="md" /></div>`,
  }),
};

// ── No hit count badge ────────────────────────────────────────────────────────

export const HideHitCount: Story = {
  name: 'Hide hit count badge',
  args: { values: [6, 3, 1, 4], showHitCount: false },
};

// ── Sizes ─────────────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes — sm / md / lg',
  render: () => ({
    components: { AppDiePool },
    template: `
      <div style="${bg}display:flex;flex-direction:column;gap:24px;">
        <div>
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">sm</span>
          <AppDiePool :values="[6, 3, 1, 4, 6]" size="sm" />
        </div>
        <div>
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">md</span>
          <AppDiePool :values="[6, 3, 1, 4, 6]" size="md" />
        </div>
        <div>
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">lg</span>
          <AppDiePool :values="[6, 3, 1, 4, 6]" size="lg" />
        </div>
      </div>
    `,
  }),
};
