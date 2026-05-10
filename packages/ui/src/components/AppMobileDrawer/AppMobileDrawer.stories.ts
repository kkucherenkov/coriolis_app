import { ref } from 'vue';

import AppMobileDrawer from './AppMobileDrawer.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

// ── Shared fixtures ────────────────────────────────────────────────────────────

const LABELS = {
  ariaLabel: 'Navigation menu',
  closeAriaLabel: 'Close menu',
};

const SAMPLE_NAV = `
  <div style="display:flex;flex-direction:column;gap:8px">
    <a href="#" style="padding:10px 12px;color:var(--brand-brass-light);text-decoration:none;border-radius:6px;border:1px solid var(--brand-brass-deep)">Characters</a>
    <a href="#" style="padding:10px 12px;color:var(--text-secondary);text-decoration:none;border-radius:6px;border:1px solid var(--brand-brass-deep)">Ships</a>
    <a href="#" style="padding:10px 12px;color:var(--text-secondary);text-decoration:none;border-radius:6px;border:1px solid var(--brand-brass-deep)">NPCs</a>
    <a href="#" style="padding:10px 12px;color:var(--text-secondary);text-decoration:none;border-radius:6px;border:1px solid var(--brand-brass-deep)">Sessions</a>
  </div>
`;

// ── Meta ───────────────────────────────────────────────────────────────────────

const meta: Meta<typeof AppMobileDrawer> = {
  title: 'Composites/AppMobileDrawer',
  component: AppMobileDrawer,
  tags: ['autodocs'],
  argTypes: {
    open: { control: 'boolean' },
    side: { control: 'radio', options: ['left', 'right'] },
  },
  args: {
    open: false,
    labels: LABELS,
    side: 'left',
  },
};

export default meta;

type Story = StoryObj<typeof AppMobileDrawer>;

// ── Closed: interactive — clicking "Open drawer" opens it ─────────────────────

export const Closed: Story = {
  name: 'Closed — click button to open',
  render: () => ({
    components: { AppMobileDrawer },
    setup() {
      const isOpen = ref(false);
      return { isOpen, LABELS, SAMPLE_NAV };
    },
    template: `
      <div>
        <button
          type="button"
          style="
            padding: 8px 16px;
            background: var(--brand-brass-deep);
            color: var(--text-primary);
            border: 1px solid var(--brand-brass);
            border-radius: 6px;
            cursor: pointer;
          "
          @click="isOpen = true"
        >
          Open drawer
        </button>

        <AppMobileDrawer
          :open="isOpen"
          :labels="LABELS"
          side="left"
          @update:open="isOpen = $event"
        >
          <div v-html="SAMPLE_NAV" />
        </AppMobileDrawer>
      </div>
    `,
  }),
};

// ── OpenLeft: left-side panel with nav links ───────────────────────────────────

export const OpenLeft: Story = {
  name: 'OpenLeft — left panel with nav links',
  render: () => ({
    components: { AppMobileDrawer },
    setup() {
      const isOpen = ref(true);
      return { isOpen, LABELS, SAMPLE_NAV };
    },
    template: `
      <AppMobileDrawer
        :open="isOpen"
        :labels="LABELS"
        side="left"
        @update:open="isOpen = $event"
      >
        <div v-html="SAMPLE_NAV" />
      </AppMobileDrawer>
    `,
  }),
};

// ── OpenRight: right-side panel ────────────────────────────────────────────────

export const OpenRight: Story = {
  name: 'OpenRight — right panel with nav links',
  render: () => ({
    components: { AppMobileDrawer },
    setup() {
      const isOpen = ref(true);
      return { isOpen, LABELS, SAMPLE_NAV };
    },
    template: `
      <AppMobileDrawer
        :open="isOpen"
        :labels="LABELS"
        side="right"
        @update:open="isOpen = $event"
      >
        <div v-html="SAMPLE_NAV" />
      </AppMobileDrawer>
    `,
  }),
};
