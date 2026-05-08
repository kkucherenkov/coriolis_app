import AppField from './AppField.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppField> = {
  title: 'Primitives/AppField',
  component: AppField,
  tags: ['autodocs'],
  args: {
    label: 'Email address',
    size: 'md',
  },
  argTypes: {
    label: { control: 'text', description: 'Visible label text. Translated by the consumer.' },
    for: {
      control: 'text',
      description: 'Explicit input id. Auto-generated via useId() when omitted.',
    },
    required: { control: 'boolean' },
    helpText: {
      control: 'text',
      description: 'Secondary hint below the control. Hidden when `error` is set.',
    },
    error: {
      control: 'text',
      description: 'Error copy; replaces `helpText` and sets `aria-invalid` on the control.',
    },
    size: { control: 'select', options: ['sm', 'md'] },
  },
  parameters: {
    docs: {
      description: {
        component: [
          'AppField is the form-row composer: label → control → help/error.',
          '',
          'Consumers spread the scoped slot attrs onto their control:',
          '`<AppInput v-bind="slotAttrs" v-model="…" />`',
          '',
          'Slot attrs provided: `id`, `aria-describedby`, `aria-invalid`, `aria-required`.',
          'The label is rendered inline — no dependency on AppLabel.',
        ].join('\n'),
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppField>;

// Shared native-input style used as a stand-in for AppInput in stories.
// Uses only design tokens — no hex literals.
const inputStyle = [
  'display: block',
  'width: 100%',
  'padding: var(--space-2) var(--space-4)',
  'border: 1px solid var(--brand-brass-shadow)',
  'border-radius: var(--radius-md)',
  'background: var(--surface-night)',
  'color: var(--text-primary)',
  'font: inherit',
].join('; ');

// ── Base single-field renderer ────────────────────────────────────────────────

const singleField: Story['render'] = (args) => ({
  components: { AppField },
  setup: () => ({ args, inputStyle }),
  template: `
    <AppField v-bind="args">
      <template #default="a">
        <input type="text" v-bind="a" :style="inputStyle" />
      </template>
    </AppField>
  `,
});

// ── Stories ───────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default',
  render: singleField,
};

export const WithHelp: Story = {
  name: 'With help text',
  args: { helpText: "We'll only use this to send appointment reminders." },
  render: singleField,
};

export const WithError: Story = {
  name: 'With error',
  args: { error: 'Enter a valid email address.' },
  render: singleField,
};

export const Required: Story = {
  name: 'Required',
  args: { required: true, helpText: 'Required to complete your profile.' },
  render: singleField,
};

export const ErrorReplacesHelp: Story = {
  name: 'Error replaces help',
  args: {
    helpText: 'Choose a password at least 12 characters long.',
    error: 'Password is too short.',
  },
  render: singleField,
};

export const SizeSm: Story = {
  name: 'Size / sm',
  args: { size: 'sm', label: 'Callsign', helpText: 'Your crew callsign.' },
  render: singleField,
};

export const SizeMd: Story = {
  name: 'Size / md',
  args: { size: 'md', label: 'Ship name', helpText: 'Registered ship name.' },
  render: singleField,
};

export const ExplicitId: Story = {
  name: 'Explicit id via `for`',
  args: { for: 'my-stable-id', label: 'Stable id field' },
  render: singleField,
};

export const RequiredWithError: Story = {
  name: 'Required + error',
  args: { required: true, label: 'Faction', error: 'Please select a faction.' },
  render: singleField,
};

export const NoHelpNoError: Story = {
  name: 'No help / no error',
  args: { label: 'Notes' },
  render: singleField,
};

export const ComposedFieldRow: Story = {
  name: 'Composed field row (3 fields stacked)',
  render: () => ({
    components: { AppField },
    setup: () => ({ inputStyle }),
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-6); max-width: 480px;">
        <AppField label="Character name" required>
          <template #default="a">
            <input type="text" v-bind="a" placeholder="Kara ibn Rashid" :style="inputStyle" />
          </template>
        </AppField>

        <AppField
          label="Email address"
          help-text="Used for sharing sheets and notifications."
        >
          <template #default="a">
            <input type="email" v-bind="a" placeholder="pilot@coriolis.station" :style="inputStyle" />
          </template>
        </AppField>

        <AppField
          label="Passphrase"
          required
          error="Passphrase must be at least 12 characters."
        >
          <template #default="a">
            <input type="password" v-bind="a" :style="inputStyle" />
          </template>
        </AppField>
      </div>
    `,
  }),
};
