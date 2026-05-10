import { ref } from 'vue';

import UserMenu from './UserMenu.vue';

import type { Meta, StoryObj } from '@storybook/vue3';
import type { Locale, MenuLabels } from './UserMenu.vue';

const LOCALES: Locale[] = [
  { code: 'en', name: 'English' },
  { code: 'ru', name: 'Русский' },
  { code: 'uk', name: 'Українська' },
  { code: 'el', name: 'Ελληνικά' },
];

const LABELS_EN: MenuLabels = {
  triggerAriaLabel: 'Open user menu',
  languageLabel: 'Language',
  settingsLabel: 'Settings',
  signOutLabel: 'Sign out',
};

const PLACEHOLDER_AVATAR =
  'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><rect width="64" height="64" fill="%23D4A95C"/><text x="50%25" y="55%25" dominant-baseline="middle" text-anchor="middle" font-size="28" fill="%230B0E2C" font-family="serif">ZK</text></svg>';

const meta: Meta<typeof UserMenu> = {
  title: 'Composites/UserMenu',
  component: UserMenu,
  tags: ['autodocs'],
  argTypes: {
    displayName: { control: 'text' },
    avatarUrl: { control: 'text' },
    currentLocale: {
      control: 'select',
      options: LOCALES.map((l) => l.code),
    },
    open: { control: 'boolean' },
  },
  args: {
    displayName: 'Zara al-Khatib',
    avatarUrl: null,
    locales: LOCALES,
    currentLocale: 'en',
    labels: LABELS_EN,
    open: false,
  },
};

export default meta;

type Story = StoryObj<typeof UserMenu>;

// ── Default: closed, English locale, initials ─────────────────────────────────

export const Default: Story = {
  name: 'Default — closed, English, initials',
  render: () => ({
    components: { UserMenu },
    setup() {
      const open = ref(false);
      return { open, LOCALES, LABELS_EN };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px 40px;">
        <UserMenu
          display-name="Zara al-Khatib"
          :avatar-url="null"
          :locales="LOCALES"
          current-locale="en"
          :labels="LABELS_EN"
          v-model:open="open"
        />
      </div>
    `,
  }),
};

// ── Open: panel visible, English locale, initials ─────────────────────────────

export const Open: Story = {
  name: 'Open — panel visible, English locale, initials',
  render: () => ({
    components: { UserMenu },
    setup() {
      const open = ref(true);
      return { open, LOCALES, LABELS_EN };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px 40px;">
        <UserMenu
          display-name="Zara al-Khatib"
          :avatar-url="null"
          :locales="LOCALES"
          current-locale="en"
          :labels="LABELS_EN"
          v-model:open="open"
          @language-change="open = false"
          @settings-click="open = false"
          @sign-out-click="open = false"
        />
      </div>
    `,
  }),
};

// ── OpenWithAvatar: open + avatar image ───────────────────────────────────────

export const OpenWithAvatar: Story = {
  name: 'Open — with avatar image',
  render: () => ({
    components: { UserMenu },
    setup() {
      const open = ref(true);
      return { open, LOCALES, LABELS_EN, PLACEHOLDER_AVATAR };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px 40px;">
        <UserMenu
          display-name="Zara al-Khatib"
          :avatar-url="PLACEHOLDER_AVATAR"
          :locales="LOCALES"
          current-locale="en"
          :labels="LABELS_EN"
          v-model:open="open"
          @language-change="open = false"
          @settings-click="open = false"
          @sign-out-click="open = false"
        />
      </div>
    `,
  }),
};

// ── OpenRussian: open + Russian locale selected ───────────────────────────────

export const OpenRussian: Story = {
  name: 'Open — Russian locale selected',
  render: () => ({
    components: { UserMenu },
    setup() {
      const open = ref(true);
      const currentLocale = ref('ru');
      const LABELS_RU: MenuLabels = {
        triggerAriaLabel: 'Открыть меню пользователя',
        languageLabel: 'Язык',
        settingsLabel: 'Настройки',
        signOutLabel: 'Выйти',
      };
      function onLangChange(code: string) {
        currentLocale.value = code;
        open.value = false;
      }
      return { open, LOCALES, LABELS_RU, currentLocale, onLangChange };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px 40px;">
        <UserMenu
          display-name="Зара аль-Хатиб"
          :avatar-url="null"
          :locales="LOCALES"
          :current-locale="currentLocale"
          :labels="LABELS_RU"
          v-model:open="open"
          @language-change="onLangChange"
          @settings-click="open = false"
          @sign-out-click="open = false"
        />
      </div>
    `,
  }),
};
