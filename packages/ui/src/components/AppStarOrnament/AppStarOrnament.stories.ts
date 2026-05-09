import AppStarOrnament from './AppStarOrnament.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const SIZES = ['sm', 'md', 'lg'] as const;
const COLORS = ['brass', 'brass-deep', 'brass-light'] as const;

const meta: Meta<typeof AppStarOrnament> = {
  title: 'Coriolis/AppStarOrnament',
  component: AppStarOrnament,
  tags: ['autodocs'],
  argTypes: {
    size: { control: { type: 'select' }, options: SIZES },
    color: { control: { type: 'select' }, options: COLORS },
    opacity: { control: { type: 'range', min: 0, max: 1, step: 0.05 } },
  },
  args: {
    size: 'md',
    color: 'brass',
    opacity: 1,
  },
};

export default meta;

type Story = StoryObj<typeof AppStarOrnament>;

const bg =
  'padding:24px;background:var(--surface-void);display:inline-flex;gap:16px;align-items:center;';

// ── Default ───────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — md, brass',
  args: { size: 'md', color: 'brass', opacity: 1 },
};

// ── Sizes ─────────────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes — sm / md / lg',
  render: () => ({
    components: { AppStarOrnament },
    setup() {
      return { sizes: SIZES };
    },
    template: `
      <div style="${bg}flex-direction:column;">
        <div style="display:flex;gap:24px;align-items:flex-end;">
          <div v-for="s in sizes" :key="s" style="display:flex;flex-direction:column;align-items:center;gap:8px;">
            <AppStarOrnament :size="s" color="brass" />
            <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ s }}</span>
          </div>
        </div>
      </div>
    `,
  }),
};

// ── Colors ────────────────────────────────────────────────────────────────────

export const Colors: Story = {
  name: 'Colors — brass / brass-deep / brass-light',
  render: () => ({
    components: { AppStarOrnament },
    setup() {
      return { colors: COLORS };
    },
    template: `
      <div style="${bg}">
        <div v-for="c in colors" :key="c" style="display:flex;flex-direction:column;align-items:center;gap:8px;">
          <AppStarOrnament size="lg" :color="c" />
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ c }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Opacity variations ────────────────────────────────────────────────────────

export const OpacityVariations: Story = {
  name: 'Opacity variations',
  render: () => ({
    components: { AppStarOrnament },
    setup() {
      return { opacities: [1, 0.7, 0.5, 0.25, 0.1] };
    },
    template: `
      <div style="${bg}">
        <div v-for="o in opacities" :key="o" style="display:flex;flex-direction:column;align-items:center;gap:8px;">
          <AppStarOrnament size="lg" color="brass" :opacity="o" />
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ o }}</span>
        </div>
      </div>
    `,
  }),
};

// ── As badge watermark (share-link viewer use case) ───────────────────────────

export const AsBadgeWatermark: Story = {
  name: 'As badge watermark (share-viewer background)',
  render: () => ({
    components: { AppStarOrnament },
    template: `
      <div style="position:relative;padding:48px;background:var(--surface-parchment);min-height:200px;display:flex;align-items:center;justify-content:center;overflow:hidden;">
        <!-- Watermark: large star at low opacity in the background -->
        <div style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center;pointer-events:none;">
          <AppStarOrnament size="lg" color="brass" :opacity="0.05" />
        </div>
        <span style="font-family:Inter,sans-serif;font-size:14px;color:var(--text-ink);position:relative;z-index:1;">
          Shared by Tariq al-Asari — read-only view.
        </span>
      </div>
    `,
  }),
};

// ── Divider usage ─────────────────────────────────────────────────────────────

export const DividerUsage: Story = {
  name: 'Divider row — star between lines',
  render: () => ({
    components: { AppStarOrnament },
    template: `
      <div style="${bg}flex-direction:column;gap:0;width:400px;">
        <div style="display:flex;align-items:center;gap:12px;">
          <div style="flex:1;height:1px;background:var(--brand-brass-deep);"></div>
          <AppStarOrnament size="sm" color="brass" />
          <div style="flex:1;height:1px;background:var(--brand-brass-deep);"></div>
        </div>
      </div>
    `,
  }),
};
