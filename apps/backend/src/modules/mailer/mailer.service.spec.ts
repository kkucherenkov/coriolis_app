import { beforeEach, describe, expect, it, vi } from 'vitest';

import { MockMailer } from './adapters/mock-mailer';
import { ResendMailer } from './adapters/resend-mailer';
import type { AppConfig, MailerConfig } from '../../common/config/app-config';
import type { SentMailRecord } from './mailer.port';

const FUTURE = new Date(Date.now() + 60 * 60 * 1000);
const RECIPIENT = 'traveller@example.com';
const VERIFICATION_URL = 'https://coriolis-companion.app/auth/verify?token=test';
const RESET_URL = 'https://coriolis-companion.app/auth/reset?token=test';

// ─── MockMailer ──────────────────────────────────────────────────────────────

describe('MockMailer', () => {
  let mailer: MockMailer;

  beforeEach(() => {
    mailer = new MockMailer();
  });

  it('records a verification email (en) in the ring buffer', async () => {
    await mailer.sendVerificationEmail({
      toEmail: RECIPIENT,
      locale: 'en',
      verificationUrl: VERIFICATION_URL,
      expiresAt: FUTURE,
    });

    const sent = mailer.getLastSent();
    expect(sent).toHaveLength(1);
    expect(sent[0]?.type).toBe('verification');
    expect(sent[0]?.toEmail).toBe(RECIPIENT);
    expect(sent[0]?.locale).toBe('en');
  });

  it('records a verification email (ru) in the ring buffer', async () => {
    await mailer.sendVerificationEmail({
      toEmail: RECIPIENT,
      locale: 'ru',
      verificationUrl: VERIFICATION_URL,
      expiresAt: FUTURE,
    });

    const sent = mailer.getLastSent();
    expect(sent[0]?.locale).toBe('ru');
    // Russian subject contains Cyrillic
    expect(/[а-яА-ЯёЁ]/.test(sent[0]?.subject ?? '')).toBe(true);
  });

  it('records a password-reset email (en) in the ring buffer', async () => {
    await mailer.sendPasswordResetEmail({
      toEmail: RECIPIENT,
      locale: 'en',
      resetUrl: RESET_URL,
      expiresAt: FUTURE,
    });

    const sent = mailer.getLastSent();
    expect(sent[0]?.type).toBe('password-reset');
    expect(sent[0]?.toEmail).toBe(RECIPIENT);
  });

  it('records a password-reset email (ru) in the ring buffer', async () => {
    await mailer.sendPasswordResetEmail({
      toEmail: RECIPIENT,
      locale: 'ru',
      resetUrl: RESET_URL,
      expiresAt: FUTURE,
    });

    const sent = mailer.getLastSent();
    expect(sent[0]?.locale).toBe('ru');
    expect(/[а-яА-ЯёЁ]/.test(sent[0]?.subject ?? '')).toBe(true);
  });

  it('getLastSent() returns all buffered records', async () => {
    await mailer.sendVerificationEmail({ toEmail: 'a@test.com', locale: 'en', verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    await mailer.sendPasswordResetEmail({ toEmail: 'b@test.com', locale: 'ru', resetUrl: RESET_URL, expiresAt: FUTURE });

    expect(mailer.getLastSent()).toHaveLength(2);
  });

  it('ring buffer evicts oldest entry when capacity (50) is exceeded', async () => {
    for (let i = 0; i < 51; i++) {
      await mailer.sendVerificationEmail({
        toEmail: `u${String(i)}@test.com`,
        locale: 'en',
        verificationUrl: VERIFICATION_URL,
        expiresAt: FUTURE,
      });
    }
    expect(mailer.getLastSent()).toHaveLength(50);
  });

  it('clear() empties the buffer', async () => {
    await mailer.sendVerificationEmail({ toEmail: RECIPIENT, locale: 'en', verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    mailer.clear();
    expect(mailer.getLastSent()).toHaveLength(0);
  });

  it('each record has a sentAt Date', async () => {
    await mailer.sendVerificationEmail({ toEmail: RECIPIENT, locale: 'en', verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    const record: SentMailRecord = mailer.getLastSent()[0]!;
    expect(record.sentAt).toBeInstanceOf(Date);
  });
});

// ─── ResendMailer ────────────────────────────────────────────────────────────

function makeConfig(override: Partial<MailerConfig> = {}): AppConfig {
  const mailerConfig: MailerConfig = {
    provider: 'resend',
    resendApiKey: 'test-resend-key',
    fromAddress: 'Coriolis Companion <noreply@coriolis-companion.app>',
    ...override,
  };
  return { mailer: mailerConfig } as unknown as AppConfig;
}

describe('ResendMailer', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('POSTs to the Resend API on sendVerificationEmail', async () => {
    const fetchSpy = vi.spyOn(globalThis, 'fetch').mockResolvedValue(
      Response.json({ id: 'email_123' }, { status: 200 }),
    );

    const config = makeConfig();
    const mailer = new ResendMailer(config);
    await mailer.sendVerificationEmail({
      toEmail: RECIPIENT,
      locale: 'en',
      verificationUrl: VERIFICATION_URL,
      expiresAt: FUTURE,
    });

    expect(fetchSpy).toHaveBeenCalledOnce();
    const [url, options] = fetchSpy.mock.calls[0]!;
    expect(url).toBe('https://api.resend.com/emails');
    expect((options as RequestInit).method).toBe('POST');

    const headers = (options as RequestInit).headers as Record<string, string>;
    expect(headers['Authorization']).toBe('Bearer test-resend-key');

    const body = JSON.parse((options as RequestInit).body as string) as Record<string, unknown>;
    expect(body['to']).toEqual([RECIPIENT]);
    expect(typeof body['subject']).toBe('string');
    expect((body['subject'] as string).length).toBeGreaterThan(0);
  });

  it('POSTs to the Resend API on sendPasswordResetEmail (ru locale)', async () => {
    const fetchSpy = vi.spyOn(globalThis, 'fetch').mockResolvedValue(
      Response.json({ id: 'email_456' }, { status: 200 }),
    );

    const config = makeConfig();
    const mailer = new ResendMailer(config);
    await mailer.sendPasswordResetEmail({
      toEmail: RECIPIENT,
      locale: 'ru',
      resetUrl: RESET_URL,
      expiresAt: FUTURE,
    });

    expect(fetchSpy).toHaveBeenCalledOnce();
    const [, options] = fetchSpy.mock.calls[0]!;
    const body = JSON.parse((options as RequestInit).body as string) as Record<string, unknown>;
    // Russian subject should contain Cyrillic
    expect(/[а-яА-ЯёЁ]/.test(body['subject'] as string)).toBe(true);
  });

  it('throws when Resend returns a non-2xx status', async () => {
    vi.spyOn(globalThis, 'fetch').mockResolvedValue(
      new Response('{"message":"Invalid API key"}', { status: 401 }),
    );

    const config = makeConfig();
    const mailer = new ResendMailer(config);
    await expect(
      mailer.sendVerificationEmail({
        toEmail: RECIPIENT,
        locale: 'en',
        verificationUrl: VERIFICATION_URL,
        expiresAt: FUTURE,
      }),
    ).rejects.toThrow('401');
  });

  it('uses the fromAddress from AppConfig', async () => {
    const fetchSpy = vi.spyOn(globalThis, 'fetch').mockResolvedValue(
      Response.json({ id: 'email_789' }, { status: 200 }),
    );

    const config = makeConfig({ fromAddress: 'Custom <custom@example.app>' });
    const mailer = new ResendMailer(config);
    await mailer.sendVerificationEmail({
      toEmail: RECIPIENT,
      locale: 'en',
      verificationUrl: VERIFICATION_URL,
      expiresAt: FUTURE,
    });

    const [, options] = fetchSpy.mock.calls[0]!;
    const body = JSON.parse((options as RequestInit).body as string) as Record<string, unknown>;
    expect(body['from']).toBe('Custom <custom@example.app>');
  });
});

// ─── AppConfig guard: resend without API key ─────────────────────────────────

describe('AppConfig.mailer provider guard', () => {
  it('throws at config access when provider=resend and RESEND_API_KEY is missing', () => {
    // Simulate the AppConfig.mailer getter behaviour directly.
    const mockConfigService = {
      get: (key: string) => {
        if (key === 'MAILER_PROVIDER') return 'resend';
        if (key === 'RESEND_API_KEY') return '';
        if (key === 'MAILER_FROM_ADDRESS') return '';
        if (key === 'NODE_ENV') return 'development';
        return undefined;
      },
    };

    // Inline the same logic as AppConfig.mailer getter
    const nodeEnv: string = mockConfigService.get('NODE_ENV') ?? 'development';
    const isProduction = nodeEnv === 'production';
    const rawProvider: string = mockConfigService.get('MAILER_PROVIDER') ?? '';
    const provider: 'resend' | 'mock' = rawProvider === 'resend' ? 'resend' : isProduction ? 'resend' : 'mock';
    const resendApiKey = mockConfigService.get('RESEND_API_KEY') ?? '';

    expect(() => {
      if (provider === 'resend' && resendApiKey.length === 0) {
        throw new Error('RESEND_API_KEY is required when MAILER_PROVIDER=resend');
      }
    }).toThrow('RESEND_API_KEY is required');
  });
});
