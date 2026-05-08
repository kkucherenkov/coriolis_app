import { ref } from 'vue';
import type { Meta, StoryObj } from '@storybook/vue3';
import AppModal from './AppModal.vue';

const meta: Meta<typeof AppModal> = {
  title: 'Primitives/AppModal',
  component: AppModal,
  tags: ['autodocs'],
  argTypes: {
    open: { control: 'boolean' },
    closeOnBackdrop: { control: 'boolean' },
    closeOnEsc: { control: 'boolean' },
    size: { control: 'select', options: ['sm', 'md', 'lg'] },
    ariaLabel: { control: 'text' },
  },
  args: {
    open: false,
    closeOnBackdrop: true,
    closeOnEsc: true,
    size: 'md',
    ariaLabel: 'Dialog',
  },
};

export default meta;

type Story = StoryObj<typeof AppModal>;

// ── Default — text content ─────────────────────────────────────────────────

export const Default: Story = {
  name: 'Default — text content',
  render: () => ({
    components: { AppModal },
    setup() {
      const open = ref(false);
      return { open };
    },
    template: `
      <div style="padding: 40px; font-family: var(--type-body-md-font-family);">
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
          @click="open = true"
        >
          Open modal
        </button>

        <AppModal
          v-model:open="open"
          aria-label="Example modal"
          size="md"
        >
          <div style="display: flex; flex-direction: column; gap: var(--space-4);">
            <h2
              style="
                font-family: var(--type-display-sm-font-family);
                font-size: var(--type-display-sm-font-size);
                color: var(--brand-brass-light);
                margin: 0;
                letter-spacing: var(--type-display-sm-letter-spacing);
              "
            >
              Modal heading
            </h2>
            <p style="color: var(--text-secondary); font-size: var(--type-body-md-font-size); margin: 0;">
              This is the modal body. Press Escape or click outside the panel to close.
              The focus is trapped inside until the modal is dismissed.
            </p>
          </div>
        </AppModal>
      </div>
    `,
  }),
};

// ── With trigger slot ─────────────────────────────────────────────────────

export const WithTriggerSlot: Story = {
  name: 'With trigger slot',
  render: () => ({
    components: { AppModal },
    setup() {
      const open = ref(false);
      return { open };
    },
    template: `
      <div style="padding: 40px;">
        <AppModal
          v-model:open="open"
          aria-label="Triggered modal"
          size="md"
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
              Open via trigger slot
            </button>
          </template>

          <div style="color: var(--text-primary); font-family: var(--type-body-md-font-family);">
            <p style="margin: 0;">
              This modal was opened via the trigger slot. The trigger is rendered
              inline and clicking it toggles the modal open state.
            </p>
          </div>
        </AppModal>
      </div>
    `,
  }),
};

// ── With footer slot ──────────────────────────────────────────────────────

export const WithFooterSlot: Story = {
  name: 'With footer slot (confirm / cancel)',
  render: () => ({
    components: { AppModal },
    setup() {
      const open = ref(false);
      function confirm() {
        open.value = false;
      }
      return { open, confirm };
    },
    template: `
      <div style="padding: 40px; font-family: var(--type-body-md-font-family);">
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
          @click="open = true"
        >
          Open confirmation
        </button>

        <AppModal
          v-model:open="open"
          aria-label="Confirm action"
          size="sm"
        >
          <div style="display: flex; flex-direction: column; gap: var(--space-3);">
            <h2
              style="
                font-family: var(--type-display-sm-font-family);
                font-size: var(--type-display-sm-font-size);
                color: var(--brand-brass-light);
                margin: 0;
              "
            >
              Confirm action?
            </h2>
            <p style="color: var(--text-secondary); margin: 0; font-size: var(--type-body-md-font-size);">
              This action cannot be undone. Are you sure you want to proceed?
            </p>
          </div>

          <template #footer>
            <button
              type="button"
              style="
                padding: 8px 16px;
                border: 1px solid var(--brand-brass-deep);
                background: transparent;
                color: var(--text-secondary);
                border-radius: var(--radius-md);
                cursor: pointer;
                font-family: var(--type-body-md-font-family);
              "
              @click="open = false"
            >
              Cancel
            </button>
            <button
              type="button"
              style="
                padding: 8px 16px;
                border: none;
                background: var(--brand-brass);
                color: var(--text-on-brass);
                border-radius: var(--radius-md);
                cursor: pointer;
                font-family: var(--type-body-md-font-family);
              "
              @click="confirm"
            >
              Confirm
            </button>
          </template>
        </AppModal>
      </div>
    `,
  }),
};

// ── Sizes — sm / md / lg side by side ─────────────────────────────────────

export const Sizes: Story = {
  name: 'Sizes — sm / md / lg',
  render: () => ({
    components: { AppModal },
    setup() {
      const openSm = ref(false);
      const openMd = ref(false);
      const openLg = ref(false);
      return { openSm, openMd, openLg };
    },
    template: `
      <div style="display: flex; gap: var(--space-4); padding: 40px; flex-wrap: wrap; font-family: var(--type-body-md-font-family);">
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
          @click="openSm = true"
        >
          Small modal
        </button>
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
          @click="openMd = true"
        >
          Medium modal
        </button>
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
          @click="openLg = true"
        >
          Large modal
        </button>

        <AppModal v-model:open="openSm" aria-label="Small modal" size="sm">
          <p style="color: var(--text-primary); margin: 0;">Small modal content (max 360px)</p>
        </AppModal>

        <AppModal v-model:open="openMd" aria-label="Medium modal" size="md">
          <p style="color: var(--text-primary); margin: 0;">Medium modal content (max 520px)</p>
        </AppModal>

        <AppModal v-model:open="openLg" aria-label="Large modal" size="lg">
          <p style="color: var(--text-primary); margin: 0;">Large modal content (max 720px)</p>
        </AppModal>
      </div>
    `,
  }),
};
