/**
 * WHY this file exists:
 * Domain errors for the Darkness Points sub-context. Each error maps to an
 * RFC 9457 problem+json document via HttpExceptionFilter.
 * Clients key off `code` for i18n and retry logic.
 */
import { DomainError } from '../../../../common/errors/domain-error';

/** Thrown when delta == 0 (a no-op adjustment is meaningless). */
export class DpInvalidDeltaError extends DomainError {
  constructor() {
    super({
      code: 'DP_INVALID_DELTA',
      status: 422,
      title: 'Invalid DP Delta',
      detail: 'delta must be non-zero.',
    });
  }
}

/** Thrown when applying delta would push dpCount below 0. */
export class DpBelowZeroError extends DomainError {
  constructor(current: number, delta: number) {
    super({
      code: 'DP_BELOW_ZERO',
      status: 422,
      title: 'DP Below Zero',
      detail: `Applying delta ${String(delta)} to dpCount ${String(current)} would result in a negative count.`,
    });
  }
}
