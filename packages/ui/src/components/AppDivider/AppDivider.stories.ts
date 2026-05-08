import AppCard from '../AppCard/AppCard.vue';
import AppDivider from './AppDivider.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const ORIENTATIONS = ['horizontal', 'vertical'] as const;
const TONES = ['brass-deep', 'brass-shadow', 'brass'] as const;
const WEIGHTS = ['hairline', 'thin', 'medium'] as const;

const meta: Meta<typeof AppDivider> = {
  title: 'Primitives/AppDivider',
  component: AppDivider,
  tags: ['autodocs'],
  argTypes: {
    orientation: { control: 'select', options: ORIENTATIONS },
    tone: { control: 'select', options: TONES },
    weight: { control: 'select', options: WEIGHTS },
    inset: { control: 'boolean' },
  },
  args: {
    orientation: 'horizontal',
    tone: 'brass-deep',
    weight: 'hairline',
    inset: false,
  },
};

export default meta;

type Story = StoryObj<typeof AppDivider>;

// ── Orientation stories ───────────────────────────────────────────────────────

export const Horizontal: Story = {
  name: 'Horizontal',
  args: { orientation: 'horizontal' },
  render: (args) => ({
    components: { AppDivider },
    setup: () => ({ args }),
    template: `
      <div style="width: 320px; padding: var(--space-4, 16px);">
        <AppDivider v-bind="args" />
      </div>
    `,
  }),
};

export const Vertical: Story = {
  name: 'Vertical',
  args: { orientation: 'vertical' },
  render: (args) => ({
    components: { AppDivider },
    setup: () => ({ args }),
    template: `
      <div style="display: flex; height: 64px; padding: var(--space-4, 16px); align-items: center; gap: var(--space-3, 12px);">
        <span style="color: var(--text-primary, #F2E8D0);">Left</span>
        <AppDivider v-bind="args" />
        <span style="color: var(--text-primary, #F2E8D0);">Right</span>
      </div>
    `,
  }),
};

// ── Tone stories ──────────────────────────────────────────────────────────────

export const BrassDeep: Story = {
  name: 'Tone / brass-deep',
  args: { tone: 'brass-deep' },
  render: (args) => ({
    components: { AppDivider },
    setup: () => ({ args }),
    template: `<div style="padding: var(--space-4, 16px);"><AppDivider v-bind="args" /></div>`,
  }),
};

export const BrassShadow: Story = {
  name: 'Tone / brass-shadow',
  args: { tone: 'brass-shadow' },
  render: (args) => ({
    components: { AppDivider },
    setup: () => ({ args }),
    template: `<div style="padding: var(--space-4, 16px);"><AppDivider v-bind="args" /></div>`,
  }),
};

export const Brass: Story = {
  name: 'Tone / brass',
  args: { tone: 'brass' },
  render: (args) => ({
    components: { AppDivider },
    setup: () => ({ args }),
    template: `<div style="padding: var(--space-4, 16px);"><AppDivider v-bind="args" /></div>`,
  }),
};

// ── Weight stories ────────────────────────────────────────────────────────────

export const Hairline: Story = {
  name: 'Weight / hairline (1px)',
  args: { weight: 'hairline' },
  render: (args) => ({
    components: { AppDivider },
    setup: () => ({ args }),
    template: `<div style="padding: var(--space-4, 16px);"><AppDivider v-bind="args" /></div>`,
  }),
};

export const Thin: Story = {
  name: 'Weight / thin (1px)',
  args: { weight: 'thin' },
  render: (args) => ({
    components: { AppDivider },
    setup: () => ({ args }),
    template: `<div style="padding: var(--space-4, 16px);"><AppDivider v-bind="args" /></div>`,
  }),
};

export const Medium: Story = {
  name: 'Weight / medium (2px)',
  args: { weight: 'medium' },
  render: (args) => ({
    components: { AppDivider },
    setup: () => ({ args }),
    template: `<div style="padding: var(--space-4, 16px);"><AppDivider v-bind="args" /></div>`,
  }),
};

// ── Inset story ───────────────────────────────────────────────────────────────

export const Inset: Story = {
  name: 'Inset (space-4 margin)',
  args: { inset: true },
  render: (args) => ({
    components: { AppDivider },
    setup: () => ({ args }),
    template: `
      <div style="width: 320px; padding: var(--space-4, 16px); border: 1px dashed var(--brand-brass-shadow, #555);">
        <AppDivider v-bind="args" />
      </div>
    `,
  }),
};

// ── Composition: BetweenCards ─────────────────────────────────────────────────

export const BetweenCards: Story = {
  name: 'Between Cards',
  render: () => ({
    components: { AppDivider, AppCard },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-2, 8px); width: 320px;">
        <AppCard>
          <template #header>Attributes</template>
          <span style="color: var(--text-primary, #F2E8D0);">Strength 4 · Agility 3</span>
        </AppCard>
        <AppDivider tone="brass-deep" weight="hairline" />
        <AppCard>
          <template #header>Skills</template>
          <span style="color: var(--text-primary, #F2E8D0);">Combat 2 · Dexterity 3</span>
        </AppCard>
        <AppDivider tone="brass-shadow" weight="hairline" />
        <AppCard>
          <template #header>Talents</template>
          <span style="color: var(--text-primary, #F2E8D0);">Quick Draw · Iron Fist</span>
        </AppCard>
      </div>
    `,
  }),
};

// ── Composition: InsidePanel ──────────────────────────────────────────────────

export const InsidePanel: Story = {
  name: 'Inside Panel',
  render: () => ({
    components: { AppDivider, AppCard },
    template: `
      <AppCard style="width: 320px;">
        <template #header>Character Sheet</template>
        <div style="display: flex; flex-direction: column; gap: var(--space-3, 12px);">
          <div style="color: var(--text-primary, #F2E8D0);">Name: Tariq al-Asari</div>
          <AppDivider tone="brass-deep" weight="hairline" />
          <div style="color: var(--text-primary, #F2E8D0);">Concept: Deckhand</div>
          <AppDivider tone="brass-shadow" weight="hairline" inset />
          <div style="color: var(--text-secondary, #A89870);">Reputation: 3</div>
        </div>
      </AppCard>
    `,
  }),
};
