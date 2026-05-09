import AppIconCoriolis from './AppIconCoriolis.vue';

import type { Meta, StoryObj } from '@storybook/vue3';
import type { IconCoriolisName } from './AppIconCoriolis.vue';

const ALL_NAMES: IconCoriolisName[] = [
  'lady-of-tears',
  'traveler',
  'messenger',
  'merchant',
  'dancer',
  'gambler',
  'judge',
  'faceless-one',
  'deckhand',
];

const SIZES = ['sm', 'md', 'lg'] as const;
const COLORS = ['brass', 'mystic'] as const;

const meta: Meta<typeof AppIconCoriolis> = {
  title: 'Coriolis/AppIconCoriolis',
  component: AppIconCoriolis,
  tags: ['autodocs'],
  argTypes: {
    name: { control: { type: 'select' }, options: ALL_NAMES },
    size: { control: { type: 'select' }, options: SIZES },
    color: { control: { type: 'select' }, options: COLORS },
    ariaLabel: { control: 'text' },
  },
  args: {
    name: 'traveler',
    size: 'md',
    color: 'brass',
    ariaLabel: 'The Traveler',
  },
};

export default meta;

type Story = StoryObj<typeof AppIconCoriolis>;

// ── Default ───────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — Traveler, md, brass',
  args: { name: 'traveler', size: 'md', color: 'brass', ariaLabel: 'The Traveler' },
};

// ── All Nine Icons ────────────────────────────────────────────────────────────

export const AllNineIcons: Story = {
  name: 'All Nine Icons',
  render: () => ({
    components: { AppIconCoriolis },
    setup() {
      const icons: { name: IconCoriolisName; label: string }[] = [
        { name: 'lady-of-tears', label: 'The Lady of Tears' },
        { name: 'traveler', label: 'The Traveler' },
        { name: 'messenger', label: 'The Messenger' },
        { name: 'merchant', label: 'The Merchant' },
        { name: 'dancer', label: 'The Dancer' },
        { name: 'gambler', label: 'The Gambler' },
        { name: 'judge', label: 'The Judge' },
        { name: 'faceless-one', label: 'The Faceless One' },
        { name: 'deckhand', label: 'The Deckhand' },
      ];
      return { icons };
    },
    template: `
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:24px;padding:32px;background:var(--surface-void);max-width:600px;">
        <div v-for="icon in icons" :key="icon.name" style="display:flex;flex-direction:column;align-items:center;gap:10px;">
          <AppIconCoriolis :name="icon.name" size="lg" color="brass" :aria-label="icon.label" />
          <span style="font-size:11px;color:var(--text-secondary);text-align:center;font-family:Inter,sans-serif;">{{ icon.label }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Sizes ─────────────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes — sm / md / lg (Traveler)',
  render: () => ({
    components: { AppIconCoriolis },
    setup() {
      return { sizes: SIZES };
    },
    template: `
      <div style="display:flex;gap:24px;align-items:center;padding:24px;background:var(--surface-void);">
        <div v-for="s in sizes" :key="s" style="display:flex;flex-direction:column;align-items:center;gap:8px;">
          <AppIconCoriolis name="traveler" :size="s" color="brass" aria-label="The Traveler" />
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ s }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Colors ────────────────────────────────────────────────────────────────────

export const Colors: Story = {
  name: 'Colors — brass / mystic',
  render: () => ({
    components: { AppIconCoriolis },
    setup() {
      return { colors: COLORS };
    },
    template: `
      <div style="display:flex;gap:32px;align-items:center;padding:24px;background:var(--surface-void);">
        <div v-for="c in colors" :key="c" style="display:flex;flex-direction:column;align-items:center;gap:8px;">
          <AppIconCoriolis name="messenger" size="lg" :color="c" aria-label="The Messenger" />
          <span style="font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ c }}</span>
        </div>
      </div>
    `,
  }),
};

// ── A11y Label ────────────────────────────────────────────────────────────────

export const A11yLabel: Story = {
  name: 'A11y — aria-label rendered on SVG',
  args: {
    name: 'judge',
    size: 'md',
    color: 'brass',
    ariaLabel: 'The Judge — icon of justice and order',
  },
};

// ── Brass row ─────────────────────────────────────────────────────────────────

export const BrassRow: Story = {
  name: 'Brass row — all nine at md',
  render: () => ({
    components: { AppIconCoriolis },
    setup() {
      const icons: { name: IconCoriolisName; label: string }[] = [
        { name: 'lady-of-tears', label: 'Lady of Tears' },
        { name: 'traveler', label: 'Traveler' },
        { name: 'messenger', label: 'Messenger' },
        { name: 'merchant', label: 'Merchant' },
        { name: 'dancer', label: 'Dancer' },
        { name: 'gambler', label: 'Gambler' },
        { name: 'judge', label: 'Judge' },
        { name: 'faceless-one', label: 'Faceless One' },
        { name: 'deckhand', label: 'Deckhand' },
      ];
      return { icons };
    },
    template: `
      <div style="display:flex;flex-wrap:wrap;gap:16px;padding:24px;background:var(--surface-void);">
        <AppIconCoriolis
          v-for="icon in icons"
          :key="icon.name"
          :name="icon.name"
          size="md"
          color="brass"
          :aria-label="icon.label"
        />
      </div>
    `,
  }),
};

// ── Mystic row ────────────────────────────────────────────────────────────────

export const MysticRow: Story = {
  name: 'Mystic color — all nine at md',
  render: () => ({
    components: { AppIconCoriolis },
    setup() {
      const icons: { name: IconCoriolisName; label: string }[] = [
        { name: 'lady-of-tears', label: 'Lady of Tears' },
        { name: 'traveler', label: 'Traveler' },
        { name: 'messenger', label: 'Messenger' },
        { name: 'merchant', label: 'Merchant' },
        { name: 'dancer', label: 'Dancer' },
        { name: 'gambler', label: 'Gambler' },
        { name: 'judge', label: 'Judge' },
        { name: 'faceless-one', label: 'Faceless One' },
        { name: 'deckhand', label: 'Deckhand' },
      ];
      return { icons };
    },
    template: `
      <div style="display:flex;flex-wrap:wrap;gap:16px;padding:24px;background:var(--surface-void);">
        <AppIconCoriolis
          v-for="icon in icons"
          :key="icon.name"
          :name="icon.name"
          size="md"
          color="mystic"
          :aria-label="icon.label"
        />
      </div>
    `,
  }),
};

// ── Wizard grid (selection card layout) ──────────────────────────────────────

export const WizardGrid: Story = {
  name: 'Wizard grid — Icon selection cards',
  render: () => ({
    components: { AppIconCoriolis },
    setup() {
      const icons: { name: IconCoriolisName; label: string; domain: string; selected: boolean }[] =
        [
          {
            name: 'lady-of-tears',
            label: 'The Lady of Tears',
            domain: 'Patron of the sorrowful and the lost',
            selected: false,
          },
          {
            name: 'traveler',
            label: 'The Traveler',
            domain: 'Patron of explorers and pilots',
            selected: true,
          },
          {
            name: 'messenger',
            label: 'The Messenger',
            domain: 'Patron of diplomats and spies',
            selected: false,
          },
          {
            name: 'merchant',
            label: 'The Merchant',
            domain: 'Patron of trade and negotiation',
            selected: false,
          },
          {
            name: 'dancer',
            label: 'The Dancer',
            domain: 'Patron of artists and performers',
            selected: false,
          },
          {
            name: 'gambler',
            label: 'The Gambler',
            domain: 'Patron of risk and opportunity',
            selected: false,
          },
          {
            name: 'judge',
            label: 'The Judge',
            domain: 'Patron of justice and order',
            selected: false,
          },
          {
            name: 'faceless-one',
            label: 'The Faceless One',
            domain: 'Patron of mystics and the void',
            selected: false,
          },
          {
            name: 'deckhand',
            label: 'The Deckhand',
            domain: 'Patron of sailors and labourers',
            selected: false,
          },
        ];
      return { icons };
    },
    template: `
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:14px;max-width:680px;padding:24px;background:var(--surface-void);">
        <div
          v-for="icon in icons"
          :key="icon.name"
          :style="{
            padding: '20px',
            border: icon.selected ? '1px solid var(--brand-brass)' : '1px solid var(--brand-brass-deep)',
            borderRadius: '4px',
            background: icon.selected ? 'var(--surface-dawn)' : 'var(--surface-night)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: '10px',
            cursor: 'pointer',
          }"
        >
          <AppIconCoriolis :name="icon.name" size="lg" :color="icon.selected ? 'mystic' : 'brass'" :aria-label="icon.label" />
          <span style="font-size:13px;color:var(--brand-brass-light);font-family:Forum,serif;text-align:center;">{{ icon.label }}</span>
          <span style="font-size:11px;color:var(--text-secondary);text-align:center;font-family:Inter,sans-serif;line-height:1.4;">{{ icon.domain }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Large (lg) with labels ────────────────────────────────────────────────────

export const LargeSizeLabeled: Story = {
  name: 'Large size with labels',
  render: () => ({
    components: { AppIconCoriolis },
    setup() {
      const icons: { name: IconCoriolisName; label: string }[] = [
        { name: 'lady-of-tears', label: 'Lady of Tears' },
        { name: 'faceless-one', label: 'Faceless One' },
        { name: 'dancer', label: 'Dancer' },
      ];
      return { icons };
    },
    template: `
      <div style="display:flex;gap:32px;padding:24px;background:var(--surface-void);">
        <div v-for="icon in icons" :key="icon.name" style="display:flex;flex-direction:column;align-items:center;gap:12px;">
          <AppIconCoriolis :name="icon.name" size="lg" color="brass" :aria-label="icon.label" />
          <span style="font-size:12px;color:var(--brand-brass-light);font-family:Forum,serif;letter-spacing:0.04em;">{{ icon.label }}</span>
        </div>
      </div>
    `,
  }),
};
