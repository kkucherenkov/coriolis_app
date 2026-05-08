import { ref } from 'vue';

import AppSwitch from './AppSwitch.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppSwitch> = {
  title: 'Primitives/AppSwitch',
  component: AppSwitch,
  tags: ['autodocs'],
  // Default args include a label so every story (including autodocs default)
  // renders an accessible switch. Stories that want to show a bare switch
  // (no visible label) must override label and supply aria-label themselves.
  args: { modelValue: false, label: 'Feature toggle' },
  argTypes: {
    modelValue: { control: 'boolean', description: 'Current on/off state (v-model).' },
    label: {
      control: 'text',
      description:
        'Accessible label text. Rendered beside the switch. If the default slot is also provided, the slot content wins and this prop is ignored visually.',
    },
    disabled: { control: 'boolean' },
    size: { control: 'select', options: ['sm', 'md'] },
    name: { control: 'text', description: 'Optional form field name attribute.' },
  },
};

export default meta;

type Story = StoryObj<typeof AppSwitch>;

// ── Individual states ──────────────────────────────────────────────────────

/** Switch in the off (unchecked) state — no label. */
export const DefaultOff: Story = {
  // Reset label so the bare-button branch is rendered; aria-label provides
  // the accessible name that the button-name rule requires.
  args: { label: undefined },
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const checked = ref(false);
      return { args, checked };
    },
    // No visible label — aria-label applied via $attrs to the root <button>.
    template: `<AppSwitch v-bind="args" v-model="checked" aria-label="Toggle feature off" />`,
  }),
};

/** Switch in the on (checked) state — no label. */
export const DefaultOn: Story = {
  // Reset label so the bare-button branch is rendered; aria-label provides
  // the accessible name that the button-name rule requires.
  args: { label: undefined },
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const checked = ref(true);
      return { args, checked };
    },
    // No visible label — aria-label applied via $attrs to the root <button>.
    template: `<AppSwitch v-bind="args" v-model="checked" aria-label="Toggle feature on" />`,
  }),
};

// ── With label prop ────────────────────────────────────────────────────────

/** Label prop: string shown to the right; clicking it toggles the switch. */
export const WithLabelProp: Story = {
  args: { label: 'Push notifications' },
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const checked = ref(false);
      return { args, checked };
    },
    template: `<AppSwitch v-bind="args" v-model="checked" />`,
  }),
};

/** Label prop — checked state. */
export const WithLabelPropChecked: Story = {
  args: { label: 'Auto-save character sheet' },
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const checked = ref(true);
      return { args, checked };
    },
    template: `<AppSwitch v-bind="args" v-model="checked" />`,
  }),
};

// ── Default slot ───────────────────────────────────────────────────────────

/** Default slot allows rich label markup (e.g. bold + muted hint). */
export const WithSlot: Story = {
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const checked = ref(false);
      return { args, checked };
    },
    template: `
      <AppSwitch v-bind="args" v-model="checked">
        <span>
          Dark mode
          <span style="color: var(--text-secondary); font-size: var(--type-body-sm-font-size); margin-left: var(--space-2);">
            Applies system-wide
          </span>
        </span>
      </AppSwitch>
    `,
  }),
};

/** Slot wins over label prop when both are provided. */
export const SlotWinsOverProp: Story = {
  args: { label: 'This prop label is ignored' },
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const checked = ref(false);
      return { args, checked };
    },
    template: `
      <AppSwitch v-bind="args" v-model="checked">
        <strong>Slot label wins</strong>
      </AppSwitch>
    `,
  }),
};

// ── Sizes ──────────────────────────────────────────────────────────────────

/** Both available sizes side by side. */
export const Sizes: Story = {
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const sm = ref(true);
      const md = ref(true);
      return { args, sm, md };
    },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-4);">
        <AppSwitch v-bind="args" v-model="sm" size="sm" label="Small (sm)" />
        <AppSwitch v-bind="args" v-model="md" size="md" label="Medium (md) — default" />
      </div>
    `,
  }),
};

// ── Disabled ───────────────────────────────────────────────────────────────

/** Disabled off — cursor not-allowed, opacity reduced. */
export const DisabledOff: Story = {
  args: { label: 'Sync over cellular', disabled: true },
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const checked = ref(false);
      return { args, checked };
    },
    template: `<AppSwitch v-bind="args" v-model="checked" />`,
  }),
};

/** Disabled on — still visually marked as checked, but not interactive. */
export const DisabledOn: Story = {
  args: { label: 'Location services (managed)', disabled: true },
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const checked = ref(true);
      return { args, checked };
    },
    template: `<AppSwitch v-bind="args" v-model="checked" />`,
  }),
};

// ── Form field (name prop) ─────────────────────────────────────────────────

/** Form usage: name prop forwarded to the button for progressive enhancement. */
export const FormField: Story = {
  args: { label: 'Agree to terms', name: 'terms' },
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const checked = ref(false);
      return { args, checked };
    },
    template: `<AppSwitch v-bind="args" v-model="checked" />`,
  }),
};

// ── Form field row ─────────────────────────────────────────────────────────

/** Vertical stack of three switches — representative preferences panel. */
export const FormFieldRow: Story = {
  render: (args) => ({
    components: { AppSwitch },
    setup: () => {
      const email = ref(true);
      const sms = ref(false);
      const push = ref(true);
      return { args, email, sms, push };
    },
    template: `
      <div style="display: flex; flex-direction: column; gap: var(--space-4);">
        <AppSwitch v-bind="args" v-model="email" name="notify_email" label="Email notifications" />
        <AppSwitch v-bind="args" v-model="sms"   name="notify_sms"   label="SMS alerts" />
        <AppSwitch v-bind="args" v-model="push"  name="notify_push"  label="Push notifications" />
      </div>
    `,
  }),
};
