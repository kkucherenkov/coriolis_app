import { All, Controller, Req, Res } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';

import { AuthService } from './auth.service';

import type { Request, Response } from 'express';

/**
 * Better Auth catch-all controller. Better Auth owns its own wire protocol, so
 * we hand every `/api/v1/auth/*` request to `auth.handler(Request)` and stream
 * the resulting Web `Response` back through the Express `res` object.
 *
 * The path `auth/{*rest}` (NestJS v10+ catch-all syntax) resolves to
 * `/api/v1/auth/*` via `setGlobalPrefix('api')` + `enableVersioning({ URI, defaultVersion: '1' })`.
 * No `VERSION_NEUTRAL` — we deliberately live under `v1`.
 *
 * Rate limit: `100 req / 60s` is a deliberate raise from the original `10/60s`.
 * The catch-all routes the entire Better Auth API surface — including the
 * hot `auth/get-session` endpoint that the SPA hits on every route navigation
 * via the `auth-required.global` middleware. `10/60s` is fine for credential
 * endpoints (sign-in/sign-up/forget-password) but starves `get-session` and
 * burns through the budget after ~10 page transitions, causing 429s that the
 * frontend used to treat as "no session" → redirect to /login (effectively a
 * silent sign-out). `100/60s` keeps the brute-force ceiling without that
 * collateral. If we later split the catch-all into per-endpoint controllers
 * we can tighten the credential paths back to ~10/60s individually.
 *
 * See T-UX-2026-05-15-AUTH-THROTTLE.
 */
@Throttle({ default: { limit: 100, ttl: 60_000 } })
@Controller({ path: 'auth/{*rest}', version: '1' })
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @All()
  async handle(@Req() req: Request, @Res() res: Response): Promise<void> {
    const host = req.get('host') ?? 'localhost';
    const protocol = req.protocol || 'http';
    const url = new URL(req.originalUrl || req.url, `${protocol}://${host}`);

    const headers = new Headers();
    for (const [key, value] of Object.entries(req.headers)) {
      if (typeof value === 'string') headers.set(key, value);
      else if (Array.isArray(value)) headers.set(key, value.join(','));
    }

    const init: RequestInit = { method: req.method, headers };
    if (
      req.method !== 'GET' &&
      req.method !== 'HEAD' &&
      req.body !== undefined &&
      req.body !== null &&
      typeof req.body === 'object' &&
      Object.keys(req.body as Record<string, unknown>).length > 0
    ) {
      init.body = JSON.stringify(req.body);
    }

    const request = new Request(url.toString(), init);
    const response = await this.auth.auth.handler(request);

    for (const [key, value] of response.headers.entries()) {
      res.setHeader(key, value);
    }
    res.status(response.status);
    const buffer = Buffer.from(await response.arrayBuffer());
    res.send(buffer);
  }
}
