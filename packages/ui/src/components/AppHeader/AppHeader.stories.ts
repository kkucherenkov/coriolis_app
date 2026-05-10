import AppHeader from './AppHeader.vue';

import type { Meta, StoryObj } from '@storybook/vue3';
import type { NavItem } from './AppHeader.vue';

// ── Shared fixtures ────────────────────────────────────────────────────────────

const NAV_ITEMS: NavItem[] = [
  { key: 'characters', href: '/app/characters', label: 'Characters' },
  { key: 'ships', href: '/app/ships', label: 'Ships' },
  { key: 'npcs', href: '/app/npcs', label: 'NPCs' },
  { key: 'sessions', href: '/app/sessions', label: 'Sessions' },
];

const BRAND = {
  brandName: 'Coriolis · Companion',
  brandHomeAriaLabel: 'Go to dashboard',
  navAriaLabel: 'Main navigation',
};

// ── Meta ───────────────────────────────────────────────────────────────────────

const meta: Meta<typeof AppHeader> = {
  title: 'Composites/AppHeader',
  component: AppHeader,
  tags: ['autodocs'],
  argTypes: {
    activeKey: {
      control: 'select',
      options: [undefined, 'characters', 'ships', 'npcs', 'sessions'],
    },
    navItems: { control: 'object' },
    brandHref: { control: 'text' },
  },
  args: {
    brand: BRAND,
    navItems: NAV_ITEMS,
    activeKey: 'characters',
    brandHref: '/app',
  },
};

export default meta;

type Story = StoryObj<typeof AppHeader>;

// ── Default: 4 nav items, Characters active, no user-menu slot ────────────────

export const Default: Story = {
  name: 'Default — Characters active, no user menu',
  render: (args) => ({
    components: { AppHeader },
    setup() {
      return { args };
    },
    template: `
      <AppHeader v-bind="args" />
    `,
  }),
};

// ── WithUserMenu: same + stubbed user-menu slot ───────────────────────────────
// Real consumers will slot in <UserMenu> from @app/ui here.

export const WithUserMenu: Story = {
  name: 'WithUserMenu — user-menu slot filled with stub',
  render: (args) => ({
    components: { AppHeader },
    setup() {
      return { args };
    },
    template: `
      <AppHeader v-bind="args">
        <!-- Real consumers slot in <UserMenu> from @app/ui here -->
        <template #user-menu>
          <div
            style="
              padding: 4px 12px;
              border: 1px solid var(--brand-brass-deep);
              border-radius: 6px;
              color: var(--text-secondary);
              font-size: 0.8rem;
            "
          >
            [UserMenu placeholder]
          </div>
        </template>
      </AppHeader>
    `,
  }),
};

// ── ShipsActive: Ships nav link highlighted ───────────────────────────────────

export const ShipsActive: Story = {
  name: 'ShipsActive — Ships link highlighted',
  args: {
    activeKey: 'ships',
  },
  render: (args) => ({
    components: { AppHeader },
    setup() {
      return { args };
    },
    template: `<AppHeader v-bind="args" />`,
  }),
};

// ── NoActive: no active key (e.g. /app/settings view) ────────────────────────

export const NoActive: Story = {
  name: 'NoActive — no nav item highlighted',
  args: {
    activeKey: undefined,
  },
  render: (args) => ({
    components: { AppHeader },
    setup() {
      return { args };
    },
    template: `<AppHeader v-bind="args" />`,
  }),
};
