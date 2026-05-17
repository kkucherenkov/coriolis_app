<script setup lang="ts">
  import { computed } from 'vue';

  import { AppButton } from '../AppButton';
  import { AppPanelTitle } from '../AppPanelTitle';
  import { AppSessionShareLinkCard } from '../AppSessionShareLinkCard';

  type State = 'none' | 'active' | 'just-generated' | 'just-rotated';

  interface Props {
    state: State;
    rotatedAt?: string | null;
    revealUrl?: string;
    labels: {
      title: string;
      blurbNone: string;
      ctaGenerate: string;
      labelActiveSince: string;
      noteActive: string;
      ctaCopy: string;
      ctaRotate: string;
      ctaRevoke: string;
      revealTitleNew: string;
      revealTitleRotated: string;
      revealClose: string;
      revealWarning: string;
      revealCopy: string;
      revealCopied: string;
    };
  }

  const props = defineProps<Props>();
  const emit = defineEmits<{
    generate: [];
    rotate: [];
    revoke: [];
    copy: [];
    closeReveal: [];
  }>();

  const isReveal = computed(
    () => props.state === 'just-generated' || props.state === 'just-rotated',
  );
  const revealTitle = computed(() =>
    props.state === 'just-rotated' ? props.labels.revealTitleRotated : props.labels.revealTitleNew,
  );
</script>

<template>
  <section class="app-invite-manager" role="region" aria-labelledby="app-invite-manager-title">
    <!-- AppPanelTitle has no id prop; the id attr falls through to its root <div> via Vue's $attrs -->
    <AppPanelTitle id="app-invite-manager-title" size="md">
      {{ labels.title }}
    </AppPanelTitle>

    <div v-if="state === 'none'" class="app-invite-manager__body">
      <p class="app-invite-manager__blurb">
        {{ labels.blurbNone }}
      </p>
      <AppButton @click="emit('generate')">
        {{ labels.ctaGenerate }}
      </AppButton>
    </div>

    <div v-else-if="state === 'active'" class="app-invite-manager__body">
      <div class="app-invite-manager__since">
        <span aria-hidden="true" class="app-invite-manager__pulse" />
        <span class="app-invite-manager__since-label">{{ labels.labelActiveSince }}</span>
        <time class="app-invite-manager__since-time" :datetime="rotatedAt ?? undefined">{{
          rotatedAt
        }}</time>
      </div>
      <p class="app-invite-manager__note">
        {{ labels.noteActive }}
      </p>
      <div class="app-invite-manager__actions">
        <AppButton @click="emit('copy')">
          {{ labels.ctaCopy }}
        </AppButton>
        <AppButton variant="secondary" @click="emit('rotate')">
          {{ labels.ctaRotate }}
        </AppButton>
        <AppButton variant="danger" class="app-invite-manager__revoke" @click="emit('revoke')">
          {{ labels.ctaRevoke }}
        </AppButton>
      </div>
    </div>

    <!--
      The reveal states render an inline alertdialog — matching the handoff JSX which also
      renders inline (no teleport). AppModal is not used here because its <Teleport to="body">
      would place content outside the component's DOM tree, breaking both the a11y tree
      (role="alertdialog" must contain the labelling h2) and unit-test queries.
      close-on-esc and close-on-backdrop are intentionally disabled (user must act).
    -->
    <div
      v-else-if="isReveal"
      class="app-invite-manager__reveal-backdrop"
      role="alertdialog"
      aria-modal="true"
      aria-labelledby="app-invite-manager-reveal-title"
    >
      <div class="app-invite-manager__reveal-panel">
        <header class="app-invite-manager__reveal-header">
          <h2 id="app-invite-manager-reveal-title" class="app-invite-manager__reveal-title">
            {{ revealTitle }}
          </h2>
        </header>
        <AppSessionShareLinkCard
          :url="revealUrl ?? ''"
          :warning="labels.revealWarning"
          :copy-label="labels.revealCopy"
          :copied-label="labels.revealCopied"
        />
        <footer class="app-invite-manager__reveal-footer">
          <AppButton @click="emit('closeReveal')">
            {{ labels.revealClose }}
          </AppButton>
        </footer>
      </div>
    </div>
  </section>
</template>

<style scoped lang="scss">
  $pulse-size: 8px;
  $reveal-panel-max-width: 520px;

  .app-invite-manager {
    background: var(--surface-night);
    border: 1px solid var(--brand-brass-deep);
    border-radius: var(--radius-md);
    padding: var(--space-5);

    &__body {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
      margin-top: var(--space-3);
    }

    &__blurb,
    &__note {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__since {
      display: flex;
      align-items: center;
      gap: var(--space-2);
    }

    &__pulse {
      width: $pulse-size;
      height: $pulse-size;
      border-radius: 50%;
      background: var(--state-success);
      box-shadow: 0 0 8px var(--state-success);
    }

    &__since-label {
      font-family: var(--font-body);
      /* --font-size-mono-md not in token set; --type-body-xs-font-size is the closest */
      font-size: var(--type-body-xs-font-size);
      letter-spacing: 0.16em;
      text-transform: uppercase;
      color: var(--state-success);
    }

    &__since-time {
      font-family: var(--font-mono);
      font-size: var(--type-body-xs-font-size);
      color: var(--brand-brass-light);
    }

    &__actions {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-2);
    }

    &__revoke {
      margin-left: auto;
    }

    // ── Reveal overlay ──────────────────────────────────────────────────────────

    &__reveal-backdrop {
      position: fixed;
      inset: 0;
      z-index: var(--z-modal);
      display: flex;
      align-items: center;
      justify-content: center;
      padding: var(--space-4);
      background: color-mix(in srgb, var(--surface-void) 75%, transparent);
    }

    &__reveal-panel {
      width: 100%;
      max-width: $reveal-panel-max-width;
      max-height: calc(100vh - var(--space-8));
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      background: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-lg);
      box-shadow: var(--shadow-brass-bevel), var(--shadow-panel-rise);
      padding: var(--space-6);
      gap: var(--space-3);
    }

    &__reveal-header {
      margin-bottom: 0;
    }

    &__reveal-title {
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      letter-spacing: 0.04em;
      color: var(--brand-brass-light);
      margin: 0;
    }

    &__reveal-footer {
      display: flex;
      justify-content: flex-end;
      margin-top: var(--space-3);
    }
  }
</style>
