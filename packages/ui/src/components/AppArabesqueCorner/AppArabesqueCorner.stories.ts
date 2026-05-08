import AppArabesqueCorner from './AppArabesqueCorner.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const ORIENTATIONS = ['tl', 'tr', 'bl', 'br'] as const;
const SIZES = ['sm', 'md', 'lg'] as const;
const COLORS = ['brass', 'brass-deep'] as const;

const meta: Meta<typeof AppArabesqueCorner> = {
  title: 'Coriolis/AppArabesqueCorner',
  component: AppArabesqueCorner,
  tags: ['autodocs'],
  argTypes: {
    orientation: { control: { type: 'select' }, options: ORIENTATIONS },
    size: { control: { type: 'select' }, options: SIZES },
    color: { control: { type: 'select' }, options: COLORS },
  },
  args: {
    orientation: 'tl',
    size: 'md',
    color: 'brass',
  },
};

export default meta;

type Story = StoryObj<typeof AppArabesqueCorner>;

// ── Default ───────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — tl, md, brass',
  args: { orientation: 'tl', size: 'md', color: 'brass' },
};

// ── All Four Corners ──────────────────────────────────────────────────────────

export const AllFourCorners: Story = {
  name: 'All four corners — tl / tr / bl / br',
  render: () => ({
    components: { AppArabesqueCorner },
    setup() {
      return { orientations: ORIENTATIONS };
    },
    template: `
      <div style="padding:32px;background:var(--surface-void);">
        <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:16px;max-width:320px;">
          <div v-for="o in orientations" :key="o" style="display:flex;flex-direction:column;align-items:center;gap:8px;">
            <AppArabesqueCorner :orientation="o" size="md" color="brass" />
            <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ o }}</span>
          </div>
        </div>
      </div>
    `,
  }),
};

// ── Sizes ─────────────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes — sm / md / lg (orientation=tl)',
  render: () => ({
    components: { AppArabesqueCorner },
    setup() {
      return { sizes: SIZES };
    },
    template: `
      <div style="padding:24px;background:var(--surface-void);display:flex;gap:32px;align-items:flex-end;">
        <div v-for="s in sizes" :key="s" style="display:flex;flex-direction:column;align-items:center;gap:8px;">
          <AppArabesqueCorner orientation="tl" :size="s" color="brass" />
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ s }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Colors ────────────────────────────────────────────────────────────────────

export const Colors: Story = {
  name: 'Colors — brass / brass-deep',
  render: () => ({
    components: { AppArabesqueCorner },
    setup() {
      return { colors: COLORS };
    },
    template: `
      <div style="padding:24px;background:var(--surface-void);display:flex;gap:32px;align-items:center;">
        <div v-for="c in colors" :key="c" style="display:flex;flex-direction:column;align-items:center;gap:8px;">
          <AppArabesqueCorner orientation="tl" size="lg" :color="c" />
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ c }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Frame demo (AppCard with all 4 corners overlaid) ─────────────────────────

export const FrameDemo: Story = {
  name: 'Frame demo — four corners framing a panel',
  render: () => ({
    components: { AppArabesqueCorner },
    template: `
      <div style="padding:64px;background:var(--surface-void);">
        <div style="position:relative;padding:40px;border:1px solid var(--brand-brass-deep);border-radius:4px;background:var(--surface-night);max-width:480px;">
          <!-- Corners absolutely positioned -->
          <div style="position:absolute;top:6px;left:6px;">
            <AppArabesqueCorner orientation="tl" size="md" color="brass" />
          </div>
          <div style="position:absolute;top:6px;right:6px;">
            <AppArabesqueCorner orientation="tr" size="md" color="brass" />
          </div>
          <div style="position:absolute;bottom:6px;left:6px;">
            <AppArabesqueCorner orientation="bl" size="md" color="brass" />
          </div>
          <div style="position:absolute;bottom:6px;right:6px;">
            <AppArabesqueCorner orientation="br" size="md" color="brass" />
          </div>

          <!-- Panel content -->
          <div style="text-align:center;">
            <div style="font-family:Forum,serif;font-size:24px;color:var(--brand-brass-light);margin-bottom:8px;">
              Pilot · Evade
            </div>
            <div style="font-family:Inter,sans-serif;font-size:13px;color:var(--text-secondary);">
              Agility 5 + Pilot 5 − Broken arm 2 = 8 dice
            </div>
          </div>
        </div>
      </div>
    `,
  }),
};

// ── Large corner ornaments ────────────────────────────────────────────────────

export const LargeCorners: Story = {
  name: 'Large corners — landing page scale',
  render: () => ({
    components: { AppArabesqueCorner },
    template: `
      <div style="position:relative;padding:80px;background:var(--surface-void);min-height:300px;">
        <div style="position:absolute;top:16px;left:16px;">
          <AppArabesqueCorner orientation="tl" size="lg" color="brass" />
        </div>
        <div style="position:absolute;top:16px;right:16px;">
          <AppArabesqueCorner orientation="tr" size="lg" color="brass" />
        </div>
        <div style="position:absolute;bottom:16px;left:16px;">
          <AppArabesqueCorner orientation="bl" size="lg" color="brass" />
        </div>
        <div style="position:absolute;bottom:16px;right:16px;">
          <AppArabesqueCorner orientation="br" size="lg" color="brass" />
        </div>
        <div style="display:flex;align-items:center;justify-content:center;height:100%;">
          <span style="font-family:Forum,serif;font-size:32px;color:var(--brand-brass-light);">Coriolis · Companion</span>
        </div>
      </div>
    `,
  }),
};
