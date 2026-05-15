import AppSwash from './AppSwash.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const COLORS = ['brass', 'brass-deep', 'brass-light'] as const;
const WIDTHS = [40, 80, 120, 200] as const;

const meta: Meta<typeof AppSwash> = {
  title: 'Coriolis/AppSwash',
  component: AppSwash,
  tags: ['autodocs'],
  argTypes: {
    width: { control: { type: 'range', min: 24, max: 280, step: 8 } },
    color: { control: { type: 'select' }, options: COLORS },
  },
  args: {
    width: 80,
    color: 'brass',
  },
  parameters: {
    docs: {
      description: {
        component:
          'Calligraphic underline swash. Pairs with `AppPanelTitle` and every Forum display heading ≥ 20px. Decorative — `aria-hidden`.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppSwash>;

const bg =
  'padding:24px;background:var(--surface-void);display:inline-flex;gap:24px;align-items:center;';

// ── Default ─────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — width 80, brass',
  args: { width: 80, color: 'brass' },
};

// ── Widths ──────────────────────────────────────────────────────────────────

export const Widths: Story = {
  name: 'Widths — 40 / 80 / 120 / 200',
  render: () => ({
    components: { AppSwash },
    setup() {
      return { widths: WIDTHS };
    },
    template: `
      <div style="${bg}flex-direction:column;align-items:flex-start;">
        <div v-for="w in widths" :key="w" style="display:flex;align-items:center;gap:16px;">
          <AppSwash :width="w" color="brass" />
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ w }}px</span>
        </div>
      </div>
    `,
  }),
};

// ── Colors ──────────────────────────────────────────────────────────────────

export const Colors: Story = {
  name: 'Colors — brass / brass-deep / brass-light',
  render: () => ({
    components: { AppSwash },
    setup() {
      return { colors: COLORS };
    },
    template: `
      <div style="${bg}flex-direction:column;align-items:flex-start;">
        <div v-for="c in colors" :key="c" style="display:flex;align-items:center;gap:16px;">
          <AppSwash :width="120" :color="c" />
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ c }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Paired with a Forum heading (intended consumer pattern) ─────────────────

export const UnderForumHeading: Story = {
  name: 'Beneath a Forum heading',
  render: () => ({
    components: { AppSwash },
    template: `
      <div style="${bg}flex-direction:column;align-items:flex-start;">
        <h3 style="margin:0;font-family:var(--type-display-md-font-family);font-size:var(--type-display-md-font-size);line-height:var(--type-display-md-line-height);letter-spacing:var(--type-display-md-letter-spacing);font-weight:var(--type-display-md-font-weight);color:var(--brand-brass-light);text-transform:uppercase;">
          Crew Status
        </h3>
        <AppSwash :width="110" color="brass" />
      </div>
    `,
  }),
};

// ── Light surface (parchment / share-viewer) ────────────────────────────────

export const OnParchment: Story = {
  name: 'On parchment surface',
  render: () => ({
    components: { AppSwash },
    template: `
      <div style="padding:24px;background:var(--surface-parchment);display:inline-flex;flex-direction:column;align-items:flex-start;gap:8px;">
        <h3 style="margin:0;font-family:var(--type-display-md-font-family);font-size:var(--type-display-md-font-size);line-height:var(--type-display-md-line-height);letter-spacing:var(--type-display-md-letter-spacing);color:var(--text-ink);text-transform:uppercase;">
          Library
        </h3>
        <AppSwash :width="110" color="brass-deep" />
      </div>
    `,
  }),
};
