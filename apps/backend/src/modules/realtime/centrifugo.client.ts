/**
 * WHY this file exists:
 * Thin HTTP wrapper around the Centrifugo server-side publish API.
 * Handlers inject ICentrifugoClient via CENTRIFUGO_CLIENT token.
 * The real adapter (this class) makes an HTTP call to Centrifugo /api.
 * Unit tests swap in a vi.fn() mock without spawning a server.
 *
 * Publish failures are intentionally non-fatal: callers wrap the call in
 * try/catch. A slow or unreachable Centrifugo instance must not roll back
 * database writes.
 *
 * The 250 ms AbortController timeout ensures the backend request thread
 * is not held open while Centrifugo is unavailable.
 */
import { Injectable, Logger } from '@nestjs/common';

import { AppConfig } from '../../common/config/app-config';

export const CENTRIFUGO_CLIENT = Symbol('CENTRIFUGO_CLIENT');

export interface ICentrifugoClient {
  publish(channel: string, data: Record<string, unknown>): Promise<void>;
}

@Injectable()
export class CentrifugoClient implements ICentrifugoClient {
  private readonly logger = new Logger(CentrifugoClient.name);

  constructor(private readonly config: AppConfig) {}

  async publish(channel: string, data: Record<string, unknown>): Promise<void> {
    const { apiUrl, apiKey } = this.config.centrifugo;
    const url = `${apiUrl}/api`;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => {
      controller.abort();
    }, 250);

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `apikey ${apiKey}`,
        },
        body: JSON.stringify({
          method: 'publish',
          params: { channel, data },
        }),
        signal: controller.signal,
      });

      if (!response.ok) {
        this.logger.warn(
          `Centrifugo publish to "${channel}" returned HTTP ${response.status.toString()}`,
        );
      }
    } catch (error) {
      if (error instanceof Error && error.name === 'AbortError') {
        this.logger.warn(`Centrifugo publish to "${channel}" timed out after 250ms`);
      } else {
        this.logger.warn(`Centrifugo publish to "${channel}" failed: ${String(error)}`);
      }
    } finally {
      clearTimeout(timeoutId);
    }
  }
}
