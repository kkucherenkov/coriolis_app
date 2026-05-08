import { ref } from 'vue';

import AppPopover from './AppPopover.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const PLACEMENTS = ['top', 'bottom', 'left', 'right'] as const;

const meta: Meta<typeof AppPopover> = {
  title: 'Primitives/AppPopover',
  component: AppPopover,
  tags: ['autodocs'],
  argTypes: {
    placement: { control: 'select', options: PLACEMENTS },
    open: { control: 'boolean' },
  },
  args: {
    placement: 'bottom',
    open: false,
    ariaLabel: 'Edit value',
  },
};

export default meta;

type Story = StoryObj<typeof AppPopover>;

// ── Default: bottom-placed, "Edit Strength" demo ──────────────────────────────

export const Default: Story = {
  name: 'Default — Bottom placement (Edit Strength demo)',
  render: () => ({
    components: { AppPopover },
    setup() {
      const open = ref(false);
      return { open };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 120px 80px;">
        <AppPopover
          v-model:open="open"
          placement="bottom"
          aria-label="Edit Strength"
        >
          <template #trigger>
            <button
              type="button"
              style="
                padding: 8px 16px;
                border: 1px solid var(--brand-brass-deep);
                background: transparent;
                color: var(--brand-brass-light);
                border-radius: var(--radius-md);
                cursor: pointer;
                font-family: var(--type-body-md-font-family);
              "
            >
              STR · 3 (click to edit)
            </button>
          </template>

          <div style="display: flex; flex-direction: column; gap: var(--space-3); min-width: 200px;">
            <div style="font-family: var(--type-display-sm-font-family); font-size: 11px; color: var(--brand-brass-light); letter-spacing: 0.1em; text-transform: uppercase;">
              Edit Strength
            </div>
            <div style="display: flex; gap: var(--space-2); justify-content: center;">
              <button
                v-for="n in 5"
                :key="n"
                type="button"
                style="
                  width: 36px; height: 36px;
                  border: 1px solid var(--brand-brass-deep);
                  background: transparent;
                  color: var(--brand-brass-light);
                  border-radius: var(--radius-md);
                  cursor: pointer;
                  font-family: var(--type-mono-stat-md-font-family);
                "
              >{{ n }}</button>
            </div>
            <button
              type="button"
              style="
                padding: 6px 12px;
                border: none;
                background: var(--brand-brass);
                color: var(--text-on-brass);
                border-radius: var(--radius-md);
                cursor: pointer;
                font-family: var(--type-body-sm-font-family);
              "
              @click="open = false"
            >
              Done
            </button>
          </div>
        </AppPopover>
      </div>
    `,
  }),
};

// ── Top placement ─────────────────────────────────────────────────────────────

export const TopPlacement: Story = {
  name: 'Placement — Top',
  render: () => ({
    components: { AppPopover },
    setup() {
      const open = ref(false);
      return { open };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 160px 80px 80px;">
        <AppPopover
          v-model:open="open"
          placement="top"
          aria-label="Edit Agility"
        >
          <template #trigger>
            <button
              type="button"
              style="
                padding: 8px 16px;
                border: 1px solid var(--brand-brass-deep);
                background: transparent;
                color: var(--brand-brass-light);
                border-radius: var(--radius-md);
                cursor: pointer;
              "
            >
              AGI · 5 (opens above)
            </button>
          </template>
          <div style="padding: var(--space-2); color: var(--text-primary); font-family: var(--type-body-md-font-family);">
            Top-placed popover content
          </div>
        </AppPopover>
      </div>
    `,
  }),
};

// ── Left + Right placements ───────────────────────────────────────────────────

export const SidePlacements: Story = {
  name: 'Placements — Left & Right',
  render: () => ({
    components: { AppPopover },
    setup() {
      const openLeft = ref(false);
      const openRight = ref(false);
      return { openLeft, openRight };
    },
    template: `
      <div style="display: flex; justify-content: center; gap: 120px; padding: 80px;">
        <AppPopover
          v-model:open="openLeft"
          placement="left"
          aria-label="Edit Wits"
        >
          <template #trigger>
            <button
              type="button"
              style="
                padding: 8px 16px;
                border: 1px solid var(--brand-brass-deep);
                background: transparent;
                color: var(--brand-brass-light);
                border-radius: var(--radius-md);
                cursor: pointer;
              "
            >
              WIT (opens left)
            </button>
          </template>
          <div style="padding: var(--space-2); color: var(--text-primary); font-family: var(--type-body-md-font-family);">
            Left-placed content
          </div>
        </AppPopover>

        <AppPopover
          v-model:open="openRight"
          placement="right"
          aria-label="Edit Empathy"
        >
          <template #trigger>
            <button
              type="button"
              style="
                padding: 8px 16px;
                border: 1px solid var(--brand-brass-deep);
                background: transparent;
                color: var(--brand-brass-light);
                border-radius: var(--radius-md);
                cursor: pointer;
              "
            >
              EMP (opens right)
            </button>
          </template>
          <div style="padding: var(--space-2); color: var(--text-primary); font-family: var(--type-body-md-font-family);">
            Right-placed content
          </div>
        </AppPopover>
      </div>
    `,
  }),
};

// ── Reduced motion comparison ─────────────────────────────────────────────────

export const ReducedMotion: Story = {
  name: 'Reduced-motion — no scale animation',
  parameters: {
    docs: {
      description: {
        story:
          'When `prefers-reduced-motion: reduce` is active, the entrance animation is disabled. Simulate via devtools OS settings or the a11y addon.',
      },
    },
  },
  render: () => ({
    components: { AppPopover },
    setup() {
      const open = ref(true);
      return { open };
    },
    template: `
      <div style="display: flex; justify-content: center; padding: 80px; gap: 32px;">
        <div>
          <div style="font-family: var(--type-body-sm-font-family); color: var(--text-secondary); margin-bottom: var(--space-2);">
            Panel shown (open=true) — observe no animation under prefers-reduced-motion:
          </div>
          <AppPopover
            v-model:open="open"
            placement="bottom"
            aria-label="Reduced motion demo"
          >
            <template #trigger>
              <button
                type="button"
                style="
                  padding: 8px 16px;
                  border: 1px solid var(--brand-brass-deep);
                  background: transparent;
                  color: var(--brand-brass-light);
                  border-radius: var(--radius-md);
                  cursor: pointer;
                "
                @click="open = !open"
              >
                Toggle popover
              </button>
            </template>
            <div style="padding: var(--space-3); color: var(--text-primary); font-family: var(--type-body-md-font-family);">
              Popover content — no scale/fade when reduced-motion active.
            </div>
          </AppPopover>
        </div>
      </div>
    `,
  }),
};
