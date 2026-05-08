import AppTextarea from './AppTextarea.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppTextarea> = {
  title: 'Primitives/AppTextarea',
  component: AppTextarea,
  tags: ['autodocs'],
  argTypes: {
    size: { control: 'select', options: ['sm', 'md', 'lg'] },
    rows: { control: 'number' },
    autosize: { control: 'boolean' },
    disabled: { control: 'boolean' },
    readonly: { control: 'boolean' },
    invalid: { control: 'boolean' },
    maxlength: { control: 'number' },
  },
  args: {
    modelValue: '',
    size: 'md',
    rows: 4,
    disabled: false,
    readonly: false,
    invalid: false,
    autosize: false,
  },
  // Default render provides aria-label so the autodocs story satisfies the
  // label rule without wiring up a visible <label> element.
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `<AppTextarea v-bind="args" aria-label="Textarea field" style="max-width:360px;" />`,
  }),
};

export default meta;

type Story = StoryObj<typeof AppTextarea>;

// ── Default × size matrix ──────────────────────────────────────────────────

export const DefaultSm: Story = {
  name: 'Default / sm',
  args: { size: 'sm', placeholder: 'Small textarea' },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `<AppTextarea v-bind="args" aria-label="Small textarea" style="max-width:360px;" />`,
  }),
};

export const DefaultMd: Story = {
  name: 'Default / md',
  args: { size: 'md', placeholder: 'Medium textarea' },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `<AppTextarea v-bind="args" aria-label="Medium textarea" style="max-width:360px;" />`,
  }),
};

export const DefaultLg: Story = {
  name: 'Default / lg',
  args: { size: 'lg', placeholder: 'Large textarea' },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `<AppTextarea v-bind="args" aria-label="Large textarea" style="max-width:360px;" />`,
  }),
};

// ── Invalid × size matrix ──────────────────────────────────────────────────

export const InvalidSm: Story = {
  name: 'Invalid / sm',
  args: { size: 'sm', invalid: true, modelValue: 'Too short.' },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `
      <div style="max-width:360px; display:flex; flex-direction:column; gap:var(--space-2);">
        <AppTextarea v-bind="args" aria-label="Small invalid textarea" />
        <p style="color:var(--state-crimson); font-size:var(--type-body-sm-font-size); margin:0;">Notes must be at least 20 characters.</p>
      </div>
    `,
  }),
};

export const InvalidMd: Story = {
  name: 'Invalid / md',
  args: { size: 'md', invalid: true, modelValue: 'Too short.' },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `
      <div style="max-width:360px; display:flex; flex-direction:column; gap:var(--space-2);">
        <AppTextarea v-bind="args" aria-label="Medium invalid textarea" />
        <p style="color:var(--state-crimson); font-size:var(--type-body-sm-font-size); margin:0;">Please provide a longer description.</p>
      </div>
    `,
  }),
};

export const InvalidLg: Story = {
  name: 'Invalid / lg',
  args: { size: 'lg', invalid: true, modelValue: 'Too short.' },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `
      <div style="max-width:360px; display:flex; flex-direction:column; gap:var(--space-2);">
        <AppTextarea v-bind="args" aria-label="Large invalid textarea" />
        <p style="color:var(--state-crimson); font-size:var(--type-body-sm-font-size); margin:0;">This value is too short.</p>
      </div>
    `,
  }),
};

// ── Special states ─────────────────────────────────────────────────────────

export const Disabled: Story = {
  args: { disabled: true, modelValue: 'Disabled content — not editable.' },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `<AppTextarea v-bind="args" aria-label="Disabled textarea" style="max-width:360px;" />`,
  }),
};

export const Readonly: Story = {
  args: {
    readonly: true,
    modelValue: 'The crew found the derelict station drifting near the Third Horizon gate.',
  },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `<AppTextarea v-bind="args" aria-label="Read-only textarea" style="max-width:360px;" />`,
  }),
};

export const WithPlaceholder: Story = {
  name: 'With placeholder',
  args: { placeholder: 'Describe your character background…' },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `<AppTextarea v-bind="args" aria-label="Character background textarea" style="max-width:360px;" />`,
  }),
};

// ── Rows count ─────────────────────────────────────────────────────────────

export const RowsCount: Story = {
  name: 'Rows count',
  render: () => ({
    components: { AppTextarea },
    template: `
      <div style="display:flex; flex-direction:column; gap:var(--space-4); max-width:360px;">
        <AppTextarea :model-value="''" :rows="2" placeholder="2 rows" aria-label="2 rows textarea" />
        <AppTextarea :model-value="''" :rows="4" placeholder="4 rows (default)" aria-label="4 rows textarea" />
        <AppTextarea :model-value="''" :rows="8" placeholder="8 rows" aria-label="8 rows textarea" />
      </div>
    `,
  }),
};

// ── Max length ─────────────────────────────────────────────────────────────

export const MaxLength: Story = {
  name: 'Max length (200)',
  args: { maxlength: 200, placeholder: 'Limited to 200 characters…' },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `<AppTextarea v-bind="args" aria-label="Max length textarea" style="max-width:360px;" />`,
  }),
};

// ── Autosize — BEM modifier only; grow behaviour is a TODO ─────────────────

export const AutosizeBasic: Story = {
  name: 'Autosize (TODO — modifier only)',
  args: {
    autosize: true,
    modelValue:
      'The autosize modifier suppresses manual resize. ' +
      'Full grow-to-content (field-sizing + JS polyfill) is deferred — see active.md T-2026-05-08-019.',
  },
  render: (args) => ({
    components: { AppTextarea },
    setup: () => ({ args }),
    template: `<AppTextarea v-bind="args" aria-label="Autosize textarea" style="max-width:360px;" />`,
  }),
};

// ── All sizes overview ─────────────────────────────────────────────────────

export const AllSizes: Story = {
  name: 'All sizes',
  render: () => ({
    components: { AppTextarea },
    template: `
      <div style="display:flex; flex-direction:column; gap:var(--space-4); max-width:400px;">
        <AppTextarea size="sm" :model-value="''" placeholder="Small (sm)"  aria-label="Small textarea" />
        <AppTextarea size="md" :model-value="''" placeholder="Medium (md)" aria-label="Medium textarea" />
        <AppTextarea size="lg" :model-value="''" placeholder="Large (lg)"  aria-label="Large textarea" />
      </div>
    `,
  }),
};

// ── All states overview ────────────────────────────────────────────────────

export const AllStates: Story = {
  name: 'All states',
  render: () => ({
    components: { AppTextarea },
    template: `
      <div style="display:flex; flex-direction:column; gap:var(--space-4); max-width:400px;">
        <AppTextarea :model-value="''" placeholder="Default"  aria-label="Default state textarea" />
        <AppTextarea :model-value="'Has value — ready to submit.'"          aria-label="Filled textarea" />
        <AppTextarea :model-value="''" placeholder="Invalid"  aria-label="Invalid state textarea"  :invalid="true" />
        <AppTextarea :model-value="'Disabled content'"                      aria-label="Disabled textarea"   :disabled="true" />
        <AppTextarea :model-value="'Read-only content'"                     aria-label="Read-only textarea"  :readonly="true" />
      </div>
    `,
  }),
};
