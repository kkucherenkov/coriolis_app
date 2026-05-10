<script setup lang="ts">
  import { computed, ref } from 'vue';

  type Size = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  type Tone = 'brass' | 'mystic' | 'crimson' | 'darkness';
  type Shape = 'circle' | 'squircle';

  interface Props {
    name: string;
    src?: string;
    size?: Size;
    tone?: Tone;
    shape?: Shape;
  }

  const props = withDefaults(defineProps<Props>(), {
    src: undefined,
    size: 'md',
    tone: 'brass',
    shape: 'circle',
  });

  const imageError = ref(false);

  const showImage = computed(() => Boolean(props.src) && !imageError.value);

  /**
   * Compute initials: first character of each whitespace-separated word,
   * take up to 2, uppercase. Works for any Unicode script.
   */
  const initials = computed(() => {
    const words = props.name.trim().split(/\s+/);
    return words
      .slice(0, 2)
      .map((w) => [...w][0] ?? '')
      .join('')
      .toUpperCase();
  });

  const classes = computed(() => [
    'app-avatar',
    `app-avatar--${props.size}`,
    `app-avatar--${props.tone}`,
    `app-avatar--${props.shape}`,
  ]);

  function handleError(): void {
    imageError.value = true;
  }
</script>

<template>
  <span
    :class="classes"
    role="img"
    :aria-label="name"
  >
    <img
      v-if="showImage"
      class="app-avatar__image"
      :src="src"
      :alt="name"
      loading="lazy"
      decoding="async"
      @error="handleError"
    />
    <template v-else>
      <span
        class="app-avatar__initials"
        aria-hidden="true"
      >{{ initials }}</span>
      <span class="app-avatar__sr">{{ name }}</span>
    </template>
  </span>
</template>

<style lang="scss" scoped>
  // Named size variables — design token scale has no avatar-specific stops.
  $avatar-size-xs: 24px;
  $avatar-size-sm: 32px;
  $avatar-size-md: 48px;
  $avatar-size-lg: 64px;
  $avatar-size-xl: 96px;

  // Font-size ratio relative to avatar diameter (matches Portrait helper ~0.36)
  $avatar-initials-ratio: 0.36;

  .app-avatar {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    overflow: hidden;
    position: relative;
    // Default size — overridden by size modifiers below
    width: $avatar-size-md;
    height: $avatar-size-md;

    // ── Shape modifiers ──────────────────────────────────────────────────────

    &--circle {
      border-radius: 50%;
    }

    &--squircle {
      border-radius: var(--radius-md);
    }

    // ── Size modifiers ───────────────────────────────────────────────────────

    &--xs {
      width: $avatar-size-xs;
      height: $avatar-size-xs;

      .app-avatar__initials {
        font-size: calc(#{$avatar-size-xs} * #{$avatar-initials-ratio});
      }
    }

    &--sm {
      width: $avatar-size-sm;
      height: $avatar-size-sm;

      .app-avatar__initials {
        font-size: calc(#{$avatar-size-sm} * #{$avatar-initials-ratio});
      }
    }

    &--md {
      width: $avatar-size-md;
      height: $avatar-size-md;

      .app-avatar__initials {
        font-size: calc(#{$avatar-size-md} * #{$avatar-initials-ratio});
      }
    }

    &--lg {
      width: $avatar-size-lg;
      height: $avatar-size-lg;

      .app-avatar__initials {
        font-size: calc(#{$avatar-size-lg} * #{$avatar-initials-ratio});
      }
    }

    &--xl {
      width: $avatar-size-xl;
      height: $avatar-size-xl;

      .app-avatar__initials {
        font-size: calc(#{$avatar-size-xl} * #{$avatar-initials-ratio});
      }
    }

    // ── Tone modifiers (initials background) ─────────────────────────────────
    // Only applied in initials mode (image hides the background via overflow:hidden)

    &--brass {
      background: var(--brand-brass-shadow);
      border: 1px solid var(--brand-brass-deep);
      box-shadow: inset 0 0 0 1px var(--brand-brass-shadow);

      .app-avatar__initials {
        color: var(--brand-brass-light);
      }
    }

    &--mystic {
      background: color-mix(in srgb, var(--state-mystic-teal) 20%, var(--surface-night));
      border: 1px solid var(--state-mystic-teal);

      .app-avatar__initials {
        color: var(--state-mystic-teal);
      }
    }

    &--crimson {
      background: color-mix(in srgb, var(--state-crimson) 25%, var(--surface-night));
      border: 1px solid var(--state-crimson);

      .app-avatar__initials {
        color: var(--state-crimson-bright);
      }
    }

    &--darkness {
      background: color-mix(in srgb, var(--state-darkness) 30%, var(--surface-void));
      border: 1px solid var(--state-darkness);

      .app-avatar__initials {
        color: var(--text-primary);
      }
    }

    // ── Elements ─────────────────────────────────────────────────────────────

    &__image {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }

    &__initials {
      font-family: var(--type-display-md-font-family);
      font-weight: 400;
      letter-spacing: 0.04em;
      line-height: 1;
      user-select: none;
    }

    // Visually hidden — readable by screen readers
    &__sr {
      position: absolute;
      width: 1px;
      height: 1px;
      padding: 0;
      margin: -1px;
      overflow: hidden;
      clip-path: inset(50%);
      white-space: nowrap;
      border-width: 0;
    }
  }
</style>
