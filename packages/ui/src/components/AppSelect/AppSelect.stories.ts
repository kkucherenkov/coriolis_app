import { ref } from 'vue';

import AppSelect, { type AppSelectOption } from './AppSelect.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppSelect> = {
  title: 'Primitives/AppSelect',
  component: AppSelect,
  tags: ['autodocs'],
  argTypes: {
    modelValue: { control: 'text' },
    placeholder: { control: 'text' },
    size: { control: 'select', options: ['sm', 'md', 'lg'] },
    disabled: { control: 'boolean' },
    invalid: { control: 'boolean' },
    required: { control: 'boolean' },
  },
  parameters: {
    docs: {
      description: {
        component: [
          'AppSelect is the brand dropdown primitive built on a native `<select>`.',
          '',
          'Native select inherits the platform accessibility contract for free:',
          'keyboard navigation, screen-reader announcements, and OS-native menus.',
          '',
          'Props drive styling (size, disabled, invalid) and the option list.',
          'Translations come in via the `placeholder` prop and option `label` strings.',
          'Compose inside `AppField` to link label + help/error + ARIA wiring.',
        ].join('\n'),
      },
    },
  },
  // Default render wraps the select with a <label> so the autodocs story
  // and any story without a custom render function satisfies the select-name rule.
  render: (args) => ({
    components: { AppSelect },
    setup() {
      return {
        args,
        options: [
          { value: 'apple', label: 'Apple' },
          { value: 'banana', label: 'Banana' },
        ],
      };
    },
    template: `
      <div style="width:280px;">
        <label for="select-meta-default" style="display:block;margin-bottom:var(--space-2);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Option</label>
        <AppSelect v-bind="args" :options="options" select-id="select-meta-default" />
      </div>
    `,
  }),
};

export default meta;

type Story = StoryObj<typeof AppSelect>;

// ── Fixture data ──────────────────────────────────────────────────────────────

const FRUITS: AppSelectOption[] = [
  { value: 'apple', label: 'Apple' },
  { value: 'banana', label: 'Banana' },
  { value: 'cherry', label: 'Cherry' },
];

const FRUITS_WITH_DISABLED: AppSelectOption[] = [
  { value: 'apple', label: 'Apple' },
  { value: 'banana', label: 'Banana' },
  { value: 'cherry', label: 'Cherry (seasonal)', disabled: true },
  { value: 'durian', label: 'Durian' },
];

const NUMBER_OPTIONS: AppSelectOption[] = [
  { value: 1, label: 'One' },
  { value: 2, label: 'Two' },
  { value: 3, label: 'Three' },
  { value: 4, label: 'Four' },
  { value: 5, label: 'Five' },
];

const MANY_OPTIONS: AppSelectOption[] = [
  { value: 'aether', label: 'Aether' },
  { value: 'algol', label: 'Algol' },
  { value: 'altair', label: 'Altair' },
  { value: 'antares', label: 'Antares' },
  { value: 'arcturus', label: 'Arcturus' },
  { value: 'betelgeuse', label: 'Betelgeuse' },
  { value: 'capella', label: 'Capella' },
  { value: 'castor', label: 'Castor' },
  { value: 'deneb', label: 'Deneb' },
  { value: 'fomalhaut', label: 'Fomalhaut' },
  { value: 'mintaka', label: 'Mintaka' },
  { value: 'pollux', label: 'Pollux' },
  { value: 'procyon', label: 'Procyon' },
  { value: 'rigel', label: 'Rigel' },
  { value: 'sirius', label: 'Sirius' },
  { value: 'vega', label: 'Vega' },
];

// ── Stories ───────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default (3 fruits)',
  render: () => ({
    components: { AppSelect },
    setup() {
      const value = ref<string | null>(null);
      return { value, options: FRUITS };
    },
    template: `
      <div style="width:280px;">
        <label for="select-default" style="display:block;margin-bottom:var(--space-2);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Fruit</label>
        <AppSelect v-model="value" :options="options" select-id="select-default" />
        <p style="margin-top:var(--space-4);color:var(--text-secondary);font-size:var(--type-body-sm-font-size);">
          modelValue: {{ value ?? 'null' }}
        </p>
      </div>
    `,
  }),
};

export const WithPlaceholder: Story = {
  name: 'With placeholder',
  render: () => ({
    components: { AppSelect },
    setup() {
      const value = ref<string | null>(null);
      return { value, options: FRUITS };
    },
    template: `
      <div style="width:280px;">
        <label for="select-placeholder" style="display:block;margin-bottom:var(--space-2);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Fruit</label>
        <AppSelect v-model="value" :options="options" placeholder="Choose a fruit…" select-id="select-placeholder" />
        <p style="margin-top:var(--space-4);color:var(--text-secondary);font-size:var(--type-body-sm-font-size);">
          modelValue: {{ value ?? 'null' }}
        </p>
      </div>
    `,
  }),
};

export const Sizes: Story = {
  name: 'Sizes (sm / md / lg)',
  render: () => ({
    components: { AppSelect },
    setup() {
      const sm = ref<string | null>(null);
      const md = ref<string | null>(null);
      const lg = ref<string | null>(null);
      return { sm, md, lg, options: FRUITS };
    },
    template: `
      <div style="display:flex;flex-direction:column;gap:var(--space-6);width:280px;">
        <div>
          <label for="select-size-sm" style="display:block;margin-bottom:var(--space-1);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Small (sm)</label>
          <AppSelect size="sm" placeholder="Small (sm)" :options="options" v-model="sm" select-id="select-size-sm" />
        </div>
        <div>
          <label for="select-size-md" style="display:block;margin-bottom:var(--space-1);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Medium (md)</label>
          <AppSelect size="md" placeholder="Medium (md)" :options="options" v-model="md" select-id="select-size-md" />
        </div>
        <div>
          <label for="select-size-lg" style="display:block;margin-bottom:var(--space-1);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Large (lg)</label>
          <AppSelect size="lg" placeholder="Large (lg)" :options="options" v-model="lg" select-id="select-size-lg" />
        </div>
      </div>
    `,
  }),
};

export const Disabled: Story = {
  render: () => ({
    components: { AppSelect },
    setup() {
      const value = ref<string>('banana');
      return { value, options: FRUITS };
    },
    template: `
      <div style="width:280px;">
        <label for="select-disabled" style="display:block;margin-bottom:var(--space-2);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Fruit (disabled)</label>
        <AppSelect v-model="value" :options="options" disabled select-id="select-disabled" />
      </div>
    `,
  }),
};

export const Invalid: Story = {
  render: () => ({
    components: { AppSelect },
    setup() {
      const value = ref<string | null>(null);
      return { value, options: FRUITS };
    },
    template: `
      <div style="width:280px;display:flex;flex-direction:column;gap:var(--space-2);">
        <label for="select-invalid" style="display:block;font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Fruit</label>
        <AppSelect v-model="value" :options="options" placeholder="Pick a fruit…" invalid select-id="select-invalid" />
        <p style="margin:0;color:var(--state-crimson);font-size:var(--type-body-sm-font-size);">
          Selection is required.
        </p>
      </div>
    `,
  }),
};

export const RequiredInForm: Story = {
  name: 'Required in form',
  render: () => ({
    components: { AppSelect },
    setup() {
      const value = ref<string | null>(null);
      return { value, options: FRUITS };
    },
    template: `
      <form @submit.prevent style="width:280px;display:flex;flex-direction:column;gap:var(--space-4);">
        <label for="fruit-required" style="font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Fruit (required)</label>
        <AppSelect
          v-model="value"
          :options="options"
          placeholder="Required field…"
          select-id="fruit-required"
          name="fruit"
          required
        />
        <button type="submit" style="padding:var(--space-2) var(--space-4);background:var(--brand-brass);color:var(--text-on-brass);border:none;border-radius:var(--radius-md);cursor:pointer;">
          Submit
        </button>
      </form>
    `,
  }),
};

export const NumberValues: Story = {
  name: 'Number values',
  render: () => ({
    components: { AppSelect },
    setup() {
      const value = ref<number | null>(null);
      return { value, options: NUMBER_OPTIONS };
    },
    template: `
      <div style="width:280px;">
        <label for="select-number" style="display:block;margin-bottom:var(--space-2);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Number</label>
        <AppSelect v-model="value" :options="options" placeholder="Pick a number…" select-id="select-number" />
        <p style="margin-top:var(--space-4);color:var(--text-secondary);font-size:var(--type-body-sm-font-size);">
          modelValue: {{ value ?? 'null' }} (type: {{ typeof value }})
        </p>
      </div>
    `,
  }),
};

export const ManyOptions: Story = {
  name: 'Many options (overflow)',
  render: () => ({
    components: { AppSelect },
    setup() {
      const value = ref<string | null>(null);
      return { value, options: MANY_OPTIONS };
    },
    template: `
      <div style="width:280px;">
        <label for="select-many" style="display:block;margin-bottom:var(--space-2);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Star System</label>
        <AppSelect v-model="value" :options="options" placeholder="Select a star system…" select-id="select-many" />
      </div>
    `,
  }),
};

export const DisabledOption: Story = {
  name: 'With disabled option',
  render: () => ({
    components: { AppSelect },
    setup() {
      const value = ref<string | null>(null);
      return { value, options: FRUITS_WITH_DISABLED };
    },
    template: `
      <div style="width:280px;">
        <label for="select-disabled-option" style="display:block;margin-bottom:var(--space-2);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Fruit</label>
        <AppSelect v-model="value" :options="options" placeholder="Pick a fruit…" select-id="select-disabled-option" />
        <p style="margin-top:var(--space-4);color:var(--text-secondary);font-size:var(--type-body-sm-font-size);">
          Cherry is disabled (out of season).
        </p>
      </div>
    `,
  }),
};

export const SmInvalid: Story = {
  name: 'Invalid / sm',
  render: () => ({
    components: { AppSelect },
    setup() {
      const value = ref<string | null>(null);
      return { value, options: FRUITS };
    },
    template: `
      <div style="width:240px;">
        <label for="select-sm-invalid" style="display:block;margin-bottom:var(--space-1);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Fruit</label>
        <AppSelect size="sm" v-model="value" :options="options" placeholder="Small invalid…" invalid select-id="select-sm-invalid" />
      </div>
    `,
  }),
};

export const LgInvalid: Story = {
  name: 'Invalid / lg',
  render: () => ({
    components: { AppSelect },
    setup() {
      const value = ref<string | null>(null);
      return { value, options: FRUITS };
    },
    template: `
      <div style="width:320px;">
        <label for="select-lg-invalid" style="display:block;margin-bottom:var(--space-1);font-family:var(--type-body-sm-font-family);font-size:var(--type-body-sm-font-size);color:var(--text-secondary);">Fruit</label>
        <AppSelect size="lg" v-model="value" :options="options" placeholder="Large invalid…" invalid select-id="select-lg-invalid" />
      </div>
    `,
  }),
};
