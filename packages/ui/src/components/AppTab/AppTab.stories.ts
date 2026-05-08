import { ref } from 'vue';

import AppIcon from '../AppIcon/AppIcon.vue';
import AppTab from './AppTab.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const SIZES = ['sm', 'md'] as const;
const TONES = ['brass', 'mystic'] as const;

const meta: Meta<typeof AppTab> = {
  title: 'Primitives/AppTab',
  component: AppTab,
  tags: ['autodocs'],
  argTypes: {
    active: { control: 'boolean' },
    disabled: { control: 'boolean' },
    size: { control: 'select', options: SIZES },
    tone: { control: 'select', options: TONES },
  },
  args: {
    active: false,
    disabled: false,
    size: 'md',
    tone: 'brass',
  },
};

export default meta;

type Story = StoryObj<typeof AppTab>;

// ── Inactive ─────────────────────────────────────────────────────────────────

export const Inactive: Story = {
  name: 'Inactive',
  args: { active: false, tone: 'brass' },
  render: (args) => ({
    components: { AppTab },
    setup() {
      return { args };
    },
    template: `<AppTab v-bind="args">Stats</AppTab>`,
  }),
};

// ── Active ────────────────────────────────────────────────────────────────────

export const Active: Story = {
  name: 'Active',
  args: { active: true, tone: 'brass' },
  render: (args) => ({
    components: { AppTab },
    setup() {
      return { args };
    },
    template: `<AppTab v-bind="args">Stats</AppTab>`,
  }),
};

// ── Hover (visual demonstration — :hover cannot be forced by Storybook) ───────

export const HoverVisualDemo: Story = {
  name: 'Hover (visual demo only — :hover not faked)',
  render: () => ({
    components: { AppTab },
    template: `
      <div style="display: flex; gap: var(--space-1); align-items: flex-end; padding-bottom: var(--space-2);">
        <AppTab :active="false" tone="brass">Hover me</AppTab>
        <AppTab :active="true" tone="brass">Active</AppTab>
      </div>
    `,
  }),
};

// ── Disabled ──────────────────────────────────────────────────────────────────

export const Disabled: Story = {
  name: 'Disabled',
  render: () => ({
    components: { AppTab },
    template: `
      <div style="display: flex; gap: var(--space-1); align-items: flex-end;">
        <AppTab :active="false" :disabled="true">Locked</AppTab>
        <AppTab :active="true" :disabled="true">Active + Disabled</AppTab>
      </div>
    `,
  }),
};

// ── Sizes ─────────────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes (sm / md)',
  render: () => ({
    components: { AppTab },
    template: `
      <div style="display: flex; gap: var(--space-4); align-items: flex-end;">
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: var(--space-2);">sm</div>
          <AppTab size="sm" :active="true">Stats</AppTab>
        </div>
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: var(--space-2);">md</div>
          <AppTab size="md" :active="true">Stats</AppTab>
        </div>
      </div>
    `,
  }),
};

// ── Tones ─────────────────────────────────────────────────────────────────────

export const Tones: Story = {
  name: 'Tones (brass / mystic)',
  render: () => ({
    components: { AppTab },
    template: `
      <div style="display: flex; gap: var(--space-6); align-items: flex-end;">
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: var(--space-2);">brass</div>
          <AppTab tone="brass" :active="true">Current Roll</AppTab>
        </div>
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: var(--space-2);">mystic</div>
          <AppTab tone="mystic" :active="true">Push History</AppTab>
        </div>
      </div>
    `,
  }),
};

// ── With icon-leading slot ────────────────────────────────────────────────────

export const WithIcon: Story = {
  name: 'With Icon (icon-leading slot)',
  render: () => ({
    components: { AppTab, AppIcon },
    template: `
      <div style="display: flex; gap: var(--space-1); align-items: flex-end;">
        <AppTab :active="true" tone="brass">
          <template #icon-leading>
            <AppIcon name="user" size="sm" />
          </template>
          Stats
        </AppTab>
        <AppTab :active="false" tone="brass">
          <template #icon-leading>
            <AppIcon name="sword" size="sm" />
          </template>
          Gear
        </AppTab>
        <AppTab :active="false" tone="brass">
          <template #icon-leading>
            <AppIcon name="sparkles" size="sm" />
          </template>
          Talents
        </AppTab>
      </div>
    `,
  }),
};

// ── TabList — canonical consumer composition ──────────────────────────────────

export const TabList: Story = {
  name: 'TabList (consumer composition — sheet sub-sections)',
  render: () => ({
    components: { AppTab },
    setup() {
      const tabs = ['Stats', 'Gear', 'Talents', 'Notes', 'Share'];
      const active = ref('Stats');
      return { tabs, active };
    },
    template: `
      <nav role="tablist" style="display: flex; border-bottom: 1px solid var(--brand-brass-deep); padding: 0 var(--space-6);">
        <AppTab
          v-for="tab in tabs"
          :key="tab"
          :active="active === tab"
          tone="brass"
          @click="active = tab"
        >{{ tab }}</AppTab>
      </nav>
    `,
  }),
};

// ── TabList (mystic tone) — dice-roller push history ─────────────────────────

export const TabListMystic: Story = {
  name: 'TabList (mystic — dice-roller push history)',
  render: () => ({
    components: { AppTab },
    setup() {
      const tabs = ['Current Roll', 'Push History'];
      const active = ref('Current Roll');
      return { tabs, active };
    },
    template: `
      <nav role="tablist" style="display: flex; border-bottom: 1px solid var(--brand-brass-deep);">
        <AppTab
          v-for="tab in tabs"
          :key="tab"
          :active="active === tab"
          tone="mystic"
          @click="active = tab"
        >{{ tab }}</AppTab>
      </nav>
    `,
  }),
};

// ── TabList (sm) — compact variant ───────────────────────────────────────────

export const TabListSmall: Story = {
  name: 'TabList — sm size',
  render: () => ({
    components: { AppTab },
    setup() {
      const tabs = ['Overview', 'Crew', 'Cargo'];
      const active = ref('Overview');
      return { tabs, active };
    },
    template: `
      <nav role="tablist" style="display: flex; border-bottom: 1px solid var(--brand-brass-deep);">
        <AppTab
          v-for="tab in tabs"
          :key="tab"
          size="sm"
          :active="active === tab"
          tone="brass"
          @click="active = tab"
        >{{ tab }}</AppTab>
      </nav>
    `,
  }),
};

// ── GM session participant tabs ───────────────────────────────────────────────

export const GMSessionTabs: Story = {
  name: 'GM Session — participant tabs',
  render: () => ({
    components: { AppTab, AppIcon },
    setup() {
      const players = [
        { name: 'Tariq al-Asari', icon: 'user' },
        { name: 'Sina Makuu', icon: 'user' },
        { name: 'Adisa Eze', icon: 'user' },
        { name: 'Leila Nkosi', icon: 'user' },
      ];
      const active = ref('Tariq al-Asari');
      return { players, active };
    },
    template: `
      <nav role="tablist" style="display: flex; flex-wrap: wrap; border-bottom: 1px solid var(--brand-brass-deep); padding: 0 var(--space-4);">
        <AppTab
          v-for="p in players"
          :key="p.name"
          :active="active === p.name"
          tone="brass"
          size="sm"
          @click="active = p.name"
        >
          <template #icon-leading>
            <AppIcon :name="p.icon" size="xs" />
          </template>
          {{ p.name }}
        </AppTab>
      </nav>
    `,
  }),
};
