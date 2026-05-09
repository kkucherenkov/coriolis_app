import AppInput from '../AppInput/AppInput.vue';
import AppLabel from './AppLabel.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const TONES = ['default', 'eyebrow', 'stat-block'] as const;

const meta: Meta<typeof AppLabel> = {
  title: 'Primitives/AppLabel',
  component: AppLabel,
  tags: ['autodocs'],
  argTypes: {
    for: {
      control: 'text',
      description: 'When set, renders as `<label for="">` associated with an input by id.',
    },
    tone: {
      control: 'select',
      options: TONES,
      description:
        'default — body-sm/text-primary; eyebrow — Forum uppercase brass-light (stat-block titles); stat-block — uppercase brass for labels above numeric stats.',
    },
    required: {
      control: 'boolean',
      description: 'Appends a brass `*` with aria-label="required".',
    },
    helpText: {
      control: 'text',
      description: 'Optional secondary line in muted color below the label.',
    },
  },
  args: {
    tone: 'default',
    required: false,
    helpText: undefined,
  },
};

export default meta;

type Story = StoryObj<typeof AppLabel>;

// ── Default ───────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default',
  render: (args) => ({
    components: { AppLabel },
    setup: () => ({ args }),
    template: `<AppLabel v-bind="args">Email address</AppLabel>`,
  }),
};

// ── Eyebrow ───────────────────────────────────────────────────────────────────

export const Eyebrow: Story = {
  name: 'Eyebrow',
  args: { tone: 'eyebrow' },
  render: (args) => ({
    components: { AppLabel },
    setup: () => ({ args }),
    template: `<AppLabel v-bind="args">Strength</AppLabel>`,
  }),
};

// ── Stat block ────────────────────────────────────────────────────────────────

export const StatBlock: Story = {
  name: 'Stat Block',
  args: { tone: 'stat-block' },
  render: (args) => ({
    components: { AppLabel },
    setup: () => ({ args }),
    template: `<AppLabel v-bind="args">Agility</AppLabel>`,
  }),
};

// ── Required ──────────────────────────────────────────────────────────────────

export const Required: Story = {
  name: 'Required',
  args: { required: true },
  render: (args) => ({
    components: { AppLabel },
    setup: () => ({ args }),
    template: `<AppLabel v-bind="args">Character name</AppLabel>`,
  }),
};

// ── With help text ────────────────────────────────────────────────────────────

export const WithHelp: Story = {
  name: 'With Help Text',
  args: { helpText: 'Max 64 characters' },
  render: (args) => ({
    components: { AppLabel },
    setup: () => ({ args }),
    template: `<AppLabel v-bind="args">Character name</AppLabel>`,
  }),
};

// ── Required + help text ──────────────────────────────────────────────────────

export const RequiredWithHelp: Story = {
  name: 'Required + Help Text',
  args: { required: true, helpText: 'Letters and spaces only' },
  render: (args) => ({
    components: { AppLabel },
    setup: () => ({ args }),
    template: `<AppLabel v-bind="args">Full name</AppLabel>`,
  }),
};

// ── Bound to input ────────────────────────────────────────────────────────────

export const BoundToInput: Story = {
  name: 'Bound To Input',
  render: () => ({
    components: { AppLabel, AppInput },
    setup() {
      return { value: '' };
    },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-2); max-width: 320px;">
        <AppLabel for="demo-name" :required="true" help-text="Your pilot's callsign">Pilot name</AppLabel>
        <AppInput id="demo-name" v-model="value" placeholder="e.g. Tariq al-Asari" />
      </div>
    `,
  }),
};

// ── All tones ─────────────────────────────────────────────────────────────────

export const AllTones: Story = {
  name: 'All Tones',
  render: () => ({
    components: { AppLabel },
    setup: () => ({ tones: TONES }),
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-6); padding: var(--space-4);">
        <div v-for="tone in tones" :key="tone" style="display: flex; flex-direction: column; gap: var(--space-1);">
          <span style="font-family: var(--type-body-sm-font-family); font-size: 10px; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.1em;">tone={{ tone }}</span>
          <AppLabel :tone="tone">Strength</AppLabel>
        </div>
      </div>
    `,
  }),
};

// ── Eyebrow — form field ──────────────────────────────────────────────────────

export const EyebrowWithInput: Story = {
  name: 'Eyebrow — Bound To Input',
  render: () => ({
    components: { AppLabel, AppInput },
    setup() {
      return { val: '' };
    },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-2); max-width: 240px;">
        <AppLabel for="attr-str" tone="eyebrow">Strength</AppLabel>
        <AppInput id="attr-str" v-model="val" type="number" placeholder="0–5" />
      </div>
    `,
  }),
};

// ── Stat-block — decorative span (no for) ─────────────────────────────────────

export const StatBlockDecorative: Story = {
  name: 'Stat Block — Decorative Span',
  render: () => ({
    components: { AppLabel },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-1); align-items: flex-start;">
        <AppLabel tone="stat-block">Agility</AppLabel>
        <span style="font-family: var(--type-mono-stat-xl-font-family); font-size: var(--type-mono-stat-xl-font-size); font-weight: var(--type-mono-stat-xl-font-weight); color: var(--text-primary);">5</span>
      </div>
    `,
  }),
};

// ── Attribute grid (sheet context) ────────────────────────────────────────────

export const AttributeGrid: Story = {
  name: 'Attribute Grid (Sheet Context)',
  render: () => ({
    components: { AppLabel },
    setup() {
      return {
        attrs: [
          { key: 'Strength', val: 3 },
          { key: 'Agility', val: 5 },
          { key: 'Wits', val: 4 },
          { key: 'Empathy', val: 3 },
        ],
      };
    },
    template: `
      <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: var(--space-4); padding: var(--space-4);">
        <div v-for="a in attrs" :key="a.key" style="display: flex; flex-direction: column; gap: var(--space-1);">
          <AppLabel tone="eyebrow">{{ a.key }}</AppLabel>
          <span style="font-family: var(--type-mono-stat-xl-font-family); font-size: var(--type-mono-stat-xl-font-size); font-weight: var(--type-mono-stat-xl-font-weight); color: var(--text-primary);">{{ a.val }}</span>
        </div>
      </div>
    `,
  }),
};

// ── Default — with help text and required in a form ───────────────────────────

export const FormFieldFull: Story = {
  name: 'Form Field — Full (default tone)',
  render: () => ({
    components: { AppLabel, AppInput },
    setup() {
      return { val: '' };
    },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-2); max-width: 320px;">
        <AppLabel for="demo-concept" :required="true" help-text="e.g. Veteran fringe pilot">Concept</AppLabel>
        <AppInput id="demo-concept" v-model="val" placeholder="Your character's concept" />
      </div>
    `,
  }),
};
