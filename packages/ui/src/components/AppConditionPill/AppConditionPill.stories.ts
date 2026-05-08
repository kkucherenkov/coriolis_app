import { ref } from 'vue';

import AppConditionPill from './AppConditionPill.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const CONDITIONS = ['exhausted', 'sleepless', 'thirsty', 'hungry'] as const;
const SIZES = ['sm', 'md'] as const;

const meta: Meta<typeof AppConditionPill> = {
  title: 'Coriolis/AppConditionPill',
  component: AppConditionPill,
  tags: ['autodocs'],
  argTypes: {
    condition: { control: { type: 'select' }, options: CONDITIONS },
    modelValue: { control: 'boolean' },
    disabled: { control: 'boolean' },
    size: { control: { type: 'select' }, options: SIZES },
  },
  args: {
    condition: 'exhausted',
    modelValue: false,
    disabled: false,
    size: 'md',
  },
};

export default meta;

type Story = StoryObj<typeof AppConditionPill>;

// ── Default (interactive single pill) ────────────────────────────────────────

export const Default: Story = {
  name: 'Default — Exhausted (interactive)',
  render: (args) => ({
    components: { AppConditionPill },
    setup() {
      const active = ref(args.modelValue ?? false);
      return { args, active };
    },
    template: `<AppConditionPill v-bind="args" v-model="active" />`,
  }),
};

// ── Inactive row (all 4 conditions) ──────────────────────────────────────────

export const InactiveRow: Story = {
  name: 'Inactive — all 4 conditions',
  render: () => ({
    components: { AppConditionPill },
    setup() {
      return { conditions: CONDITIONS };
    },
    template: `
      <div style="display:flex;gap:8px;flex-wrap:wrap;padding:24px;background:var(--surface-void);">
        <AppConditionPill
          v-for="c in conditions"
          :key="c"
          :condition="c"
          :model-value="false"
          size="md"
        />
      </div>
    `,
  }),
};

// ── Active row (all 4 conditions) ─────────────────────────────────────────────

export const ActiveRow: Story = {
  name: 'Active — all 4 conditions',
  render: () => ({
    components: { AppConditionPill },
    setup() {
      return { conditions: CONDITIONS };
    },
    template: `
      <div style="display:flex;gap:8px;flex-wrap:wrap;padding:24px;background:var(--surface-void);">
        <AppConditionPill
          v-for="c in conditions"
          :key="c"
          :condition="c"
          :model-value="true"
          size="md"
        />
      </div>
    `,
  }),
};

// ── Disabled ─────────────────────────────────────────────────────────────────

export const Disabled: Story = {
  name: 'Disabled (inactive)',
  render: () => ({
    components: { AppConditionPill },
    setup() {
      return { conditions: CONDITIONS };
    },
    template: `
      <div style="display:flex;gap:8px;flex-wrap:wrap;padding:24px;background:var(--surface-void);">
        <AppConditionPill
          v-for="c in conditions"
          :key="c"
          :condition="c"
          :model-value="false"
          disabled
          size="md"
        />
      </div>
    `,
  }),
};

// ── Toggle interactive ────────────────────────────────────────────────────────

export const ToggleInteractive: Story = {
  name: 'Toggle — interactive (click to toggle)',
  render: () => ({
    components: { AppConditionPill },
    setup() {
      const states = ref<Record<string, boolean>>({
        exhausted: false,
        sleepless: false,
        thirsty: true,
        hungry: false,
      });
      function toggle(c: string) {
        states.value[c] = !states.value[c];
      }
      return { conditions: CONDITIONS, states, toggle };
    },
    template: `
      <div style="display:flex;gap:8px;flex-wrap:wrap;padding:24px;background:var(--surface-void);">
        <AppConditionPill
          v-for="c in conditions"
          :key="c"
          :condition="c"
          :model-value="states[c]"
          size="md"
          @update:modelValue="toggle(c)"
        />
      </div>
    `,
  }),
};

// ── Sizes ─────────────────────────────────────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes — sm / md',
  render: () => ({
    components: { AppConditionPill },
    setup() {
      return { sizes: SIZES };
    },
    template: `
      <div style="display:flex;flex-direction:column;gap:12px;padding:24px;background:var(--surface-void);">
        <div v-for="s in sizes" :key="s" style="display:flex;gap:8px;align-items:center;">
          <span style="width:24px;font-size:11px;color:var(--text-secondary);font-family:Inter,sans-serif;">{{ s }}</span>
          <AppConditionPill condition="exhausted" :model-value="false" :size="s" />
          <AppConditionPill condition="sleepless" :model-value="true" :size="s" />
        </div>
      </div>
    `,
  }),
};

// ── Custom slot label ─────────────────────────────────────────────────────────

export const WithSlotLabel: Story = {
  name: 'Custom slot label — "Истощение"',
  render: () => ({
    components: { AppConditionPill },
    template: `
      <div style="display:flex;gap:8px;padding:24px;background:var(--surface-void);">
        <AppConditionPill condition="exhausted" :model-value="false">Истощение</AppConditionPill>
        <AppConditionPill condition="sleepless" :model-value="true">Бессонница</AppConditionPill>
        <AppConditionPill condition="thirsty" :model-value="false">Жажда</AppConditionPill>
        <AppConditionPill condition="hungry" :model-value="false">Голод</AppConditionPill>
      </div>
    `,
  }),
};

// ── Disabled active ───────────────────────────────────────────────────────────

export const DisabledActive: Story = {
  name: 'Disabled — active state',
  render: () => ({
    components: { AppConditionPill },
    setup() {
      return { conditions: CONDITIONS };
    },
    template: `
      <div style="display:flex;gap:8px;flex-wrap:wrap;padding:24px;background:var(--surface-void);">
        <AppConditionPill
          v-for="c in conditions"
          :key="c"
          :condition="c"
          :model-value="true"
          disabled
          size="md"
        />
      </div>
    `,
  }),
};

// ── In combat-tracker context ─────────────────────────────────────────────────

export const InCombatRow: Story = {
  name: 'Combat row context (mixed states)',
  render: () => ({
    components: { AppConditionPill },
    setup() {
      const conditionStates = ref({
        exhausted: true,
        sleepless: false,
        thirsty: true,
        hungry: false,
      });
      return { conditions: CONDITIONS, conditionStates };
    },
    template: `
      <div style="display:flex;gap:6px;align-items:center;padding:16px;background:var(--surface-night);border:1px solid var(--brand-brass-deep);border-radius:4px;">
        <AppConditionPill
          v-for="c in conditions"
          :key="c"
          :condition="c"
          :model-value="conditionStates[c]"
          size="sm"
          @update:modelValue="conditionStates[c] = $event"
        />
      </div>
    `,
  }),
};
