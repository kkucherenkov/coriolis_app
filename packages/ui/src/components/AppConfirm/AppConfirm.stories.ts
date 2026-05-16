import type { Meta, StoryObj } from '@storybook/vue3';
import { ref } from 'vue';

import AppButton from '../AppButton/AppButton.vue';

import AppConfirm from './AppConfirm.vue';

const meta: Meta<typeof AppConfirm> = {
  title: 'Patterns/AppConfirm',
  component: AppConfirm,
  parameters: {
    docs: {
      description: {
        component:
          'Confirm dialog for destructive or hard-to-reverse actions. ' +
          'Wraps AppModal at size="sm" with closeOnBackdrop=false (PATTERNS.md §5) ' +
          'and ESC disabled while loading so an async confirm cannot be ' +
          'half-cancelled.\n\nUse `tone="danger"` for kick / revoke / delete; ' +
          'use the default `neutral` tone for publish / archive / submit.',
      },
    },
  },
};

export default meta;
type Story = StoryObj<typeof AppConfirm>;

export const Neutral: Story = {
  render: () => ({
    components: { AppConfirm, AppButton },
    setup() {
      const open = ref(false);
      return { open };
    },
    template: `
      <div>
        <AppButton @click="open = true">Open neutral confirm</AppButton>
        <AppConfirm
          v-model:open="open"
          title="Archive this session?"
          body="Archived sessions still appear in the &ldquo;Archived&rdquo; tab."
          confirm-label="Archive"
          cancel-label="Cancel"
          @confirm="open = false"
        />
      </div>
    `,
  }),
};

export const Danger: Story = {
  render: () => ({
    components: { AppConfirm, AppButton },
    setup() {
      const open = ref(false);
      return { open };
    },
    template: `
      <div>
        <AppButton variant="danger" @click="open = true">Open destructive confirm</AppButton>
        <AppConfirm
          v-model:open="open"
          tone="danger"
          title="Revoke invite?"
          body="The current link will stop working. Players who open it will see a blank state."
          confirm-label="Revoke"
          cancel-label="Keep link"
          @confirm="open = false"
        />
      </div>
    `,
  }),
};

export const Loading: Story = {
  render: () => ({
    components: { AppConfirm, AppButton },
    setup() {
      const open = ref(true);
      return { open };
    },
    template: `
      <AppConfirm
        :open="open"
        loading
        tone="danger"
        title="Kicking Yara&hellip;"
        body="Removing them from the session and revoking their next realtime token."
        confirm-label="Kick"
        cancel-label="Cancel"
      />
    `,
  }),
};

export const TitleOnly: Story = {
  render: () => ({
    components: { AppConfirm, AppButton },
    setup() {
      const open = ref(false);
      return { open };
    },
    template: `
      <div>
        <AppButton @click="open = true">Open title-only confirm</AppButton>
        <AppConfirm
          v-model:open="open"
          title="Apply these changes?"
          confirm-label="Apply"
          cancel-label="Cancel"
          @confirm="open = false"
        />
      </div>
    `,
  }),
};
