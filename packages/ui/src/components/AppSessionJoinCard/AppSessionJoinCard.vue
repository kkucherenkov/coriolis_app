<script setup lang="ts">
  import { computed } from 'vue';

  export type JoinState = 'valid' | 'revoked' | 'already-member' | 'not-signed-in';

  export interface AppSessionJoinCardPreview {
    sessionName: string;
    gmDisplayName: string;
  }

  export interface AppSessionJoinCardLabels {
    titleValid: string;
    titleRevoked: string;
    titleAlreadyMember: string;
    titleNotSignedIn: string;
    sessionLabel: string;
    gmLabel: string;
    ctaJoin: string;
    ctaSignIn: string;
    ctaGoToSession: string;
    revokedMessage: string;
    alreadyMemberMessage: string;
  }

  export interface AppSessionJoinCardProps {
    state: JoinState;
    preview: AppSessionJoinCardPreview | null;
    labels: AppSessionJoinCardLabels;
  }

  const props = defineProps<AppSessionJoinCardProps>();
  defineEmits<{ join: []; signIn: []; goToSession: [] }>();

  const title = computed(() => {
    switch (props.state) {
      case 'valid': {
        return props.labels.titleValid;
      }
      case 'revoked': {
        return props.labels.titleRevoked;
      }
      case 'already-member': {
        return props.labels.titleAlreadyMember;
      }
      case 'not-signed-in': {
        return props.labels.titleNotSignedIn;
      }
      default: {
        return props.labels.titleValid;
      }
    }
  });
</script>

<template>
  <article class="app-session-join-card" :class="`app-session-join-card--${state}`">
    <h2 class="app-session-join-card__title">
      {{ title }}
    </h2>

    <div v-if="state === 'valid' && preview" class="app-session-join-card__body">
      <p class="app-session-join-card__meta-row">
        <strong class="app-session-join-card__meta-label">{{ labels.sessionLabel }}:</strong>
        <span>{{ preview.sessionName }}</span>
      </p>
      <p class="app-session-join-card__meta-row">
        <strong class="app-session-join-card__meta-label">{{ labels.gmLabel }}:</strong>
        <span>{{ preview.gmDisplayName }}</span>
      </p>
      <button type="button" class="app-session-join-card__cta" @click="$emit('join')">
        {{ labels.ctaJoin }}
      </button>
    </div>

    <div v-else-if="state === 'revoked'" class="app-session-join-card__body">
      <p class="app-session-join-card__message">
        {{ labels.revokedMessage }}
      </p>
    </div>

    <div v-else-if="state === 'already-member' && preview" class="app-session-join-card__body">
      <p class="app-session-join-card__meta-row">
        <strong class="app-session-join-card__meta-label">{{ labels.sessionLabel }}:</strong>
        <span>{{ preview.sessionName }}</span>
      </p>
      <p class="app-session-join-card__message">
        {{ labels.alreadyMemberMessage }}
      </p>
      <button type="button" class="app-session-join-card__cta" @click="$emit('goToSession')">
        {{ labels.ctaGoToSession }}
      </button>
    </div>

    <div v-else-if="state === 'not-signed-in' && preview" class="app-session-join-card__body">
      <p class="app-session-join-card__meta-row">
        <strong class="app-session-join-card__meta-label">{{ labels.sessionLabel }}:</strong>
        <span>{{ preview.sessionName }}</span>
      </p>
      <p class="app-session-join-card__meta-row">
        <strong class="app-session-join-card__meta-label">{{ labels.gmLabel }}:</strong>
        <span>{{ preview.gmDisplayName }}</span>
      </p>
      <button type="button" class="app-session-join-card__cta" @click="$emit('signIn')">
        {{ labels.ctaSignIn }}
      </button>
    </div>
  </article>
</template>

<style lang="scss" scoped>
  // Sub-token vertical padding literal — same escape hatch as AppSessionHeader uses for $badge-pad-v.
  $cta-pad-v: 10px;

  .app-session-join-card {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-7);
    background: var(--surface-night);
    border: 1px solid var(--brand-brass-shadow);
    border-radius: var(--radius-md);

    &__title {
      margin: 0;
      font-family: var(--type-display-md-font-family);
      font-size: var(--type-display-sm-font-size);
      font-weight: var(--fw-bold);
      letter-spacing: var(--type-display-sm-letter-spacing);
      color: var(--text-primary);
    }

    &__body {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
    }

    &__meta-row {
      margin: 0;
      display: flex;
      gap: var(--space-2);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);
      color: var(--text-primary);
    }

    &__meta-label {
      font-weight: var(--fw-medium);
      color: var(--text-secondary);
      flex-shrink: 0;
    }

    &__message {
      margin: 0;
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);
      color: var(--text-secondary);
    }

    // ── CTA button: ghost style matching AppSessionHeader __leave convention ──
    &__cta {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: var(--space-2);
      padding: $cta-pad-v var(--space-5);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      background-color: transparent;
      color: var(--brand-brass-light);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      font-weight: var(--type-body-md-font-weight);
      line-height: var(--type-body-md-line-height);
      cursor: pointer;
      align-self: flex-start;
      white-space: nowrap;
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background-color: color-mix(in srgb, var(--brand-brass) 8%, transparent);
        border-color: var(--brand-brass);
      }

      &:active {
        background-color: color-mix(in srgb, var(--brand-brass) 14%, transparent);
        border-color: var(--brand-brass);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    // ── State modifiers: border accent ───────────────────────────────────────
    &--valid {
      border-color: var(--brand-brass);
    }

    &--revoked {
      border-color: var(--state-crimson);
    }

    &--already-member {
      border-color: var(--state-mystic-teal);
    }

    &--not-signed-in {
      border-color: var(--brand-brass-deep);
    }
  }
</style>
