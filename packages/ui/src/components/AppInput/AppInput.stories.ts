import AppInput from './AppInput.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppInput> = {
  title: 'Primitives/AppInput',
  component: AppInput,
  tags: ['autodocs'],
  argTypes: {
    type: {
      control: 'select',
      options: ['text', 'email', 'password', 'number', 'search', 'tel', 'url'],
    },
    size: { control: 'select', options: ['sm', 'md', 'lg'] },
    disabled: { control: 'boolean' },
    readonly: { control: 'boolean' },
    invalid: { control: 'boolean' },
  },
  args: {
    modelValue: '',
    type: 'text',
    size: 'md',
    disabled: false,
    readonly: false,
    invalid: false,
  },
};

export default meta;

type Story = StoryObj<typeof AppInput>;

// ── Default × size matrix ──────────────────────────────────────────────────

export const DefaultSm: Story = {
  name: 'Default / sm',
  args: { size: 'sm', placeholder: 'Small input' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `<AppInput v-bind="args" style="max-width:280px;" />`,
  }),
};

export const DefaultMd: Story = {
  name: 'Default / md',
  args: { size: 'md', placeholder: 'Medium input' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `<AppInput v-bind="args" style="max-width:280px;" />`,
  }),
};

export const DefaultLg: Story = {
  name: 'Default / lg',
  args: { size: 'lg', placeholder: 'Large input' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `<AppInput v-bind="args" style="max-width:280px;" />`,
  }),
};

// ── Invalid × size matrix ──────────────────────────────────────────────────

export const InvalidSm: Story = {
  name: 'Invalid / sm',
  args: { size: 'sm', invalid: true, modelValue: 'bad-input' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `
      <div style="max-width:280px; display:flex; flex-direction:column; gap:var(--space-2);">
        <AppInput v-bind="args" />
        <p style="color:var(--state-crimson); font-size:var(--type-body-sm-font-size); margin:0;">Field is required.</p>
      </div>
    `,
  }),
};

export const InvalidMd: Story = {
  name: 'Invalid / md',
  args: { size: 'md', invalid: true, modelValue: 'bad-input' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `
      <div style="max-width:280px; display:flex; flex-direction:column; gap:var(--space-2);">
        <AppInput v-bind="args" />
        <p style="color:var(--state-crimson); font-size:var(--type-body-sm-font-size); margin:0;">Please enter a valid email.</p>
      </div>
    `,
  }),
};

export const InvalidLg: Story = {
  name: 'Invalid / lg',
  args: { size: 'lg', invalid: true, modelValue: 'bad-input' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `
      <div style="max-width:280px; display:flex; flex-direction:column; gap:var(--space-2);">
        <AppInput v-bind="args" />
        <p style="color:var(--state-crimson); font-size:var(--type-body-sm-font-size); margin:0;">This value is invalid.</p>
      </div>
    `,
  }),
};

// ── Special states ─────────────────────────────────────────────────────────

export const Disabled: Story = {
  args: { disabled: true, modelValue: 'Not editable' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `<AppInput v-bind="args" style="max-width:280px;" />`,
  }),
};

export const Readonly: Story = {
  args: { readonly: true, modelValue: 'Read-only value' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `<AppInput v-bind="args" style="max-width:280px;" />`,
  }),
};

export const WithPlaceholder: Story = {
  name: 'With placeholder',
  args: { placeholder: 'Enter your callsign…' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `<AppInput v-bind="args" style="max-width:280px;" />`,
  }),
};

// ── Input types ────────────────────────────────────────────────────────────

export const PasswordType: Story = {
  name: 'Password type',
  args: { type: 'password', placeholder: 'Your passphrase' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `<AppInput v-bind="args" style="max-width:280px;" />`,
  }),
};

export const NumberType: Story = {
  name: 'Number type',
  args: { type: 'number', placeholder: '0' },
  render: (args) => ({
    components: { AppInput },
    setup: () => ({ args }),
    template: `<AppInput v-bind="args" style="max-width:160px;" />`,
  }),
};

// ── All sizes overview ─────────────────────────────────────────────────────

export const AllSizes: Story = {
  name: 'All sizes',
  render: () => ({
    components: { AppInput },
    template: `
      <div style="display:flex; flex-direction:column; gap:var(--space-4); max-width:320px;">
        <AppInput size="sm" :model-value="''" placeholder="Small (sm)" />
        <AppInput size="md" :model-value="''" placeholder="Medium (md)" />
        <AppInput size="lg" :model-value="''" placeholder="Large (lg)" />
      </div>
    `,
  }),
};

// ── All types overview ─────────────────────────────────────────────────────

export const AllTypes: Story = {
  name: 'All types',
  render: () => ({
    components: { AppInput },
    template: `
      <div style="display:flex; flex-direction:column; gap:var(--space-4); max-width:320px;">
        <AppInput type="text"     :model-value="''" placeholder="text" />
        <AppInput type="email"    :model-value="''" placeholder="email" />
        <AppInput type="password" :model-value="''" placeholder="password" />
        <AppInput type="number"   :model-value="''" placeholder="number" />
        <AppInput type="search"   :model-value="''" placeholder="search" />
        <AppInput type="tel"      :model-value="''" placeholder="tel (+357 99 123 456)" />
        <AppInput type="url"      :model-value="''" placeholder="url (https://…)" />
      </div>
    `,
  }),
};

// ── States overview ────────────────────────────────────────────────────────

export const AllStates: Story = {
  name: 'All states',
  render: () => ({
    components: { AppInput },
    template: `
      <div style="display:flex; flex-direction:column; gap:var(--space-4); max-width:320px;">
        <AppInput :model-value="''" placeholder="Default" />
        <AppInput :model-value="'Has value'" />
        <AppInput :model-value="''" placeholder="Invalid" :invalid="true" />
        <AppInput :model-value="'Disabled'" :disabled="true" />
        <AppInput :model-value="'Readonly'" :readonly="true" />
      </div>
    `,
  }),
};
