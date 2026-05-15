import AppSkillRow from './AppSkillRow.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppSkillRow> = {
  title: 'Coriolis/AppSkillRow',
  component: AppSkillRow,
  tags: ['autodocs'],
  argTypes: {
    name: { control: { type: 'text' } },
    attr: { control: { type: 'text' } },
    rank: { control: { type: 'number', min: 0, max: 5, step: 1 } },
    rankMax: { control: { type: 'number', min: 1, max: 10, step: 1 } },
    tone: { control: { type: 'inline-radio' }, options: ['brass', 'mystic'] },
  },
  args: {
    name: 'Pilot',
    attr: 'Agility',
    rank: 3,
    rankMax: 5,
    tone: 'brass',
  },
  parameters: {
    docs: {
      description: {
        component:
          'Dense skill row used by the character sheet (desktop + mobile) and the wizard Skills step. Grid: name · attr eyebrow · dot meter · monospace rank. The `name` slot lets callers inject inline decorations like the "key" chip on advanced-key skills. Tone `mystic` colours the eyebrow + meter for advanced skills.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppSkillRow>;

const surfaceWrap = (theme: 'dark' | 'light' = 'dark'): string => {
  const bg = theme === 'dark' ? 'var(--surface-night)' : 'var(--surface-parchment)';
  return [
    `padding:24px`,
    `background:${bg}`,
    `display:flex`,
    `flex-direction:column`,
    `width:360px`,
    `border:1px solid var(--brand-brass-deep)`,
    `border-radius:var(--radius-md)`,
  ].join(';');
};

const generalSkills = [
  { name: 'Pilot', attr: 'Agility', rank: 3 },
  { name: 'Observation', attr: 'Wits', rank: 2 },
  { name: 'Survival', attr: 'Wits', rank: 0 },
  { name: 'Manipulation', attr: 'Empathy', rank: 4 },
  { name: 'Force', attr: 'Strength', rank: 1 },
] as const;

const advancedSkills = [
  { name: 'Dexterity', attr: 'Agility', rank: 2 },
  { name: 'Infiltration', attr: 'Agility', rank: 0 },
  { name: 'Mystic Powers', attr: 'Empathy', rank: 1 },
] as const;

// ── Default ───────────────────────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — general, rank 3',
  render: (args) => ({
    components: { AppSkillRow },
    setup() {
      return { args };
    },
    template: `
      <div style="${surfaceWrap()}">
        <AppSkillRow v-bind="args" />
      </div>
    `,
  }),
};

// ── Empty (rank 0) ───────────────────────────────────────────────────────────

export const Empty: Story = {
  name: 'Untrained — rank 0',
  args: { rank: 0 },
  render: (args) => ({
    components: { AppSkillRow },
    setup() {
      return { args };
    },
    template: `
      <div style="${surfaceWrap()}">
        <AppSkillRow v-bind="args" />
      </div>
    `,
  }),
};

// ── Maxed ────────────────────────────────────────────────────────────────────

export const Maxed: Story = {
  name: 'Maxed — rank 5',
  args: { rank: 5 },
  render: (args) => ({
    components: { AppSkillRow },
    setup() {
      return { args };
    },
    template: `
      <div style="${surfaceWrap()}">
        <AppSkillRow v-bind="args" />
      </div>
    `,
  }),
};

// ── General column (multi-row) ───────────────────────────────────────────────

export const GeneralColumn: Story = {
  name: 'General column — list of brass rows',
  render: () => ({
    components: { AppSkillRow },
    setup() {
      return { rows: generalSkills };
    },
    template: `
      <div style="${surfaceWrap()}">
        <AppSkillRow
          v-for="r in rows"
          :key="r.name"
          :name="r.name"
          :attr="r.attr"
          :rank="r.rank"
        />
      </div>
    `,
  }),
};

// ── Mystic tone — advanced skills ────────────────────────────────────────────

export const AdvancedMystic: Story = {
  name: 'Advanced column — mystic tone',
  render: () => ({
    components: { AppSkillRow },
    setup() {
      return { rows: advancedSkills };
    },
    template: `
      <div style="${surfaceWrap()}">
        <AppSkillRow
          v-for="r in rows"
          :key="r.name"
          :name="r.name"
          :attr="r.attr"
          :rank="r.rank"
          tone="mystic"
        />
      </div>
    `,
  }),
};

// ── Slot-injected "key" chip (advanced key skill) ────────────────────────────

export const NameSlotKeyChip: Story = {
  name: 'Name slot — key-skill chip injection',
  args: { name: 'Pilot', attr: 'Agility', rank: 4, tone: 'mystic' },
  render: (args) => ({
    components: { AppSkillRow },
    setup() {
      return { args };
    },
    template: `
      <div style="${surfaceWrap()}">
        <AppSkillRow v-bind="args">
          <template #name>
            <span style="display:inline-flex;align-items:center;gap:8px;">
              {{ args.name }}
              <span style="
                font-family:var(--font-body);
                font-size:9px;
                font-weight:var(--fw-medium);
                letter-spacing:0.12em;
                text-transform:uppercase;
                padding:1px 6px;
                border-radius:var(--radius-pill);
                color:var(--state-mystic-teal);
                background:color-mix(in srgb, var(--state-mystic-teal) 14%, transparent);
                border:1px solid var(--state-mystic-teal);
              ">key</span>
            </span>
          </template>
        </AppSkillRow>
      </div>
    `,
  }),
};

// ── Cyrillic stress (i18n) ───────────────────────────────────────────────────

export const Localized: Story = {
  name: 'Localized — Russian name + attr',
  args: { name: 'Пилотирование', attr: 'Ловкость', rank: 3 },
  render: (args) => ({
    components: { AppSkillRow },
    setup() {
      return { args };
    },
    template: `
      <div style="${surfaceWrap()}">
        <AppSkillRow v-bind="args" />
      </div>
    `,
  }),
};

// ── Light surface (share-viewer parchment) ───────────────────────────────────

export const OnParchment: Story = {
  name: 'On parchment — share-viewer surface',
  render: () => ({
    components: { AppSkillRow },
    setup() {
      return { rows: generalSkills.slice(0, 3) };
    },
    template: `
      <div style="${surfaceWrap('light')};color:var(--text-ink);">
        <AppSkillRow
          v-for="r in rows"
          :key="r.name"
          :name="r.name"
          :attr="r.attr"
          :rank="r.rank"
        />
      </div>
    `,
  }),
};

// ── Reduced motion ───────────────────────────────────────────────────────────

export const ReducedMotion: Story = {
  name: 'Reduced motion — no transitions',
  parameters: { pseudo: { reducedMotion: 'reduce' } },
  render: () => ({
    components: { AppSkillRow },
    setup() {
      return { rows: generalSkills.slice(0, 3) };
    },
    template: `
      <div style="${surfaceWrap()}">
        <AppSkillRow
          v-for="r in rows"
          :key="r.name"
          :name="r.name"
          :attr="r.attr"
          :rank="r.rank"
        />
      </div>
    `,
  }),
};
