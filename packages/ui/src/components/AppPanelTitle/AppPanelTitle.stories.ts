import AppPanelTitle from './AppPanelTitle.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const SIZES = ['sm', 'md', 'lg'] as const;
const LEVELS = ['h2', 'h3', 'h4'] as const;

const meta: Meta<typeof AppPanelTitle> = {
  title: 'Coriolis/AppPanelTitle',
  component: AppPanelTitle,
  tags: ['autodocs'],
  argTypes: {
    size: { control: { type: 'select' }, options: SIZES },
    level: { control: { type: 'select' }, options: LEVELS },
  },
  args: {
    size: 'md',
    level: 'h3',
  },
  parameters: {
    docs: {
      description: {
        component:
          'Forum heading + paired swash. Single source of truth for panel headers. Sizes: `sm` (16px) · `md` (22px) · `lg` (28px). `level` selects the semantic heading tag (defaults to `h3`).',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppPanelTitle>;

const bg =
  'padding:32px;background:var(--surface-void);display:inline-flex;flex-direction:column;gap:24px;';

// ── Default ─────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — md, h3',
  args: { size: 'md', level: 'h3' },
  render: (args) => ({
    components: { AppPanelTitle },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg}">
        <AppPanelTitle v-bind="args">Crew Status</AppPanelTitle>
      </div>
    `,
  }),
};

// ── All sizes ───────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes — sm / md / lg',
  render: () => ({
    components: { AppPanelTitle },
    setup() {
      return { sizes: SIZES };
    },
    template: `
      <div style="${bg}">
        <div v-for="s in sizes" :key="s" style="display:flex;flex-direction:column;gap:6px;">
          <AppPanelTitle :size="s">{{ s === 'sm' ? 'Talents' : s === 'md' ? 'Crew Status' : 'Library' }}</AppPanelTitle>
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">size = {{ s }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Semantic levels ─────────────────────────────────────────────────────────

export const SemanticLevels: Story = {
  name: 'Semantic levels — h2 / h3 / h4',
  render: () => ({
    components: { AppPanelTitle },
    setup() {
      return { levels: LEVELS };
    },
    template: `
      <div style="${bg}">
        <div v-for="lvl in levels" :key="lvl" style="display:flex;flex-direction:column;gap:6px;">
          <AppPanelTitle :level="lvl">Crew Status</AppPanelTitle>
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">level = {{ lvl }} (same visual)</span>
        </div>
      </div>
    `,
  }),
};

// ── In a card (intended consumer pattern) ───────────────────────────────────

export const InsideCard: Story = {
  name: 'Inside a panel card',
  render: () => ({
    components: { AppPanelTitle },
    template: `
      <div style="${bg}">
        <div style="background:var(--surface-night);border:1px solid var(--brand-brass-deep);border-radius:var(--radius-md);padding:24px;min-width:360px;">
          <AppPanelTitle size="md">Skills</AppPanelTitle>
          <p style="margin-top:16px;font-family:Inter,sans-serif;font-size:14px;color:var(--text-secondary);line-height:1.5;">
            Survival 3 · Pilot 2 · Force 1 — the canonical body copy that lives below
            the title swash. Forum never appears inside this block.
          </p>
        </div>
      </div>
    `,
  }),
};

// ── On parchment ────────────────────────────────────────────────────────────

export const OnParchment: Story = {
  name: 'On parchment surface (share-viewer)',
  render: () => ({
    components: { AppPanelTitle },
    template: `
      <div style="padding:32px;background:var(--surface-parchment);">
        <AppPanelTitle size="lg">Tariq al-Asari</AppPanelTitle>
      </div>
    `,
  }),
};
