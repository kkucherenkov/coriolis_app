<script lang="ts">
  /** A single option rendered inside the dropdown. */
  export interface AppSelectOption {
    value: string | number;
    label: string;
    disabled?: boolean;
  }

  // Opt out of the default root-level $attrs merge so props (aria-*, id, name)
  // are forwarded only to the inner <select>, not the wrapper <div>.
  export default { inheritAttrs: false };
</script>

<script setup lang="ts">
  import { computed } from 'vue';

  type Size = 'sm' | 'md' | 'lg';

  const props = withDefaults(
    defineProps<{
      /** Currently selected value. `null` = no selection (placeholder shown). */
      modelValue: string | number | null;
      /** Option list rendered as native `<option>` elements. */
      options: AppSelectOption[];
      /** Displayed when `modelValue` is null. Translated by the consumer. */
      placeholder?: string;
      /** Size scale — drives padding + font-size tokens. Same scale as AppInput. */
      size?: Size;
      disabled?: boolean;
      invalid?: boolean;
      /** Forwarded as `id` on the native `<select>` for AppField `for=` binding. */
      selectId?: string;
      /** Forwarded as `name` on the native `<select>`. */
      name?: string;
      /** Native `required` for HTML form submission. */
      required?: boolean;
    }>(),
    {
      placeholder: undefined,
      size: 'md',
      disabled: false,
      invalid: false,
      selectId: undefined,
      name: undefined,
      required: false,
    },
  );

  const emit = defineEmits<{
    'update:modelValue': [value: string | number];
  }>();

  const rootClasses = computed(() => [
    'app-select',
    `app-select--${props.size}`,
    { 'app-select--disabled': props.disabled },
    { 'app-select--invalid': props.invalid },
  ]);

  // Sentinel for the placeholder <option> — empty string is safe since real
  // option values are enforced non-empty by the options type contract.
  const PLACEHOLDER_VALUE = '';

  // Bind the native <select> value attribute. null → placeholder sentinel.
  const boundValue = computed<string>(() =>
    props.modelValue === null ? PLACEHOLDER_VALUE : String(props.modelValue),
  );

  function onChange(event: Event): void {
    if (props.disabled) return;
    const target = event.target;
    if (!(target instanceof HTMLSelectElement)) return;
    const raw = target.value;
    if (raw === PLACEHOLDER_VALUE) return;
    // Preserve number type when the matched option carries a numeric value.
    const matched = props.options.find((o) => String(o.value) === raw);
    const next: string | number =
      matched !== undefined && typeof matched.value === 'number' ? matched.value : raw;
    if (next === props.modelValue) return;
    emit('update:modelValue', next);
  }
</script>

<template>
  <div :class="rootClasses">
    <select
      class="app-select__control"
      :id="selectId"
      :name="name"
      :value="boundValue"
      :disabled="disabled"
      :required="required"
      :aria-disabled="disabled ? 'true' : undefined"
      :aria-invalid="invalid ? 'true' : undefined"
      @change="onChange"
    >
      <!-- Placeholder: disabled + hidden so it shows on trigger but is never re-selectable. -->
      <option v-if="placeholder !== undefined" :value="PLACEHOLDER_VALUE" disabled hidden>
        {{ placeholder }}
      </option>
      <option
        v-for="option in options"
        :key="String(option.value)"
        :value="String(option.value)"
        :disabled="option.disabled"
      >
        {{ option.label }}
      </option>
    </select>
    <!-- Decorative chevron. pointer-events:none so clicks fall through to the <select>. -->
    <span class="app-select__chevron" aria-hidden="true">
      <svg viewBox="0 0 12 12" width="12" height="12" fill="none">
        <path
          d="M3 4.5l3 3 3-3"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </svg>
    </span>
  </div>
</template>

<style lang="scss" scoped>
  .app-select {
    position: relative;
    display: inline-flex;
    width: 100%;

    // ── Control ──────────────────────────────────────────────────────────────

    &__control {
      flex: 1 1 auto;
      width: 100%;
      min-width: 0;
      appearance: none;
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      color: var(--brand-brass-light);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);
      cursor: pointer;
      transition: border-color var(--motion-duration-fast) var(--motion-ease-standard);

      // Right-side padding: leaves room for the chevron icon.
      padding: var(--space-2) var(--space-10) var(--space-2) var(--space-4);

      &:hover:not(:disabled) {
        border-color: var(--brand-brass-deep);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
        border-color: var(--brand-brass);
      }

      &:disabled {
        cursor: not-allowed;
      }
    }

    // ── Chevron ───────────────────────────────────────────────────────────────

    &__chevron {
      position: absolute;
      top: 50%;
      inset-inline-end: var(--space-4);
      display: inline-flex;
      align-items: center;
      justify-content: center;
      color: var(--brand-brass);
      pointer-events: none;
      transform: translateY(-50%);
    }

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm {
      .app-select__control {
        padding: var(--space-1) var(--space-8) var(--space-1) var(--space-3);
        font-size: var(--type-body-sm-font-size);
        line-height: var(--type-body-sm-line-height);
      }

      .app-select__chevron {
        inset-inline-end: var(--space-3);
      }
    }

    &--md {
      .app-select__control {
        padding: var(--space-2) var(--space-10) var(--space-2) var(--space-4);
        font-size: var(--type-body-md-font-size);
        line-height: var(--type-body-md-line-height);
      }
    }

    &--lg {
      .app-select__control {
        padding: var(--space-3) var(--space-12) var(--space-3) var(--space-5);
        font-size: var(--type-body-lg-font-size);
        line-height: var(--type-body-lg-line-height);
      }

      .app-select__chevron {
        inset-inline-end: var(--space-5);
      }
    }

    // ── State: invalid ────────────────────────────────────────────────────────

    &--invalid {
      .app-select__control {
        border-color: var(--state-crimson);

        &:hover:not(:disabled) {
          border-color: var(--state-crimson-bright);
        }

        &:focus-visible {
          outline-color: var(--state-crimson-bright);
          border-color: var(--state-crimson);
        }
      }
    }

    // ── State: disabled ───────────────────────────────────────────────────────

    &--disabled {
      opacity: var(--opacity-disabled);
      pointer-events: none;
      cursor: not-allowed;
    }
  }
</style>
