import { describe, expect, it } from 'vitest';

import { passwordResetEmailEn } from '../password-reset/en';
import { passwordResetEmailRu } from '../password-reset/ru';
import { verificationEmailEn } from '../verification/en';
import { verificationEmailRu } from '../verification/ru';

const FUTURE = new Date(Date.now() + 60 * 60 * 1000);
const VERIFICATION_URL = 'https://coriolis-companion.app/auth/verify?token=abc123';
const RESET_URL = 'https://coriolis-companion.app/auth/reset?token=xyz789';
const RECIPIENT = 'pilot@example.com';

// ─── Verification templates ──────────────────────────────────────────────────

describe('verificationEmailEn', () => {
  it('produces a non-empty subject', () => {
    const tpl = verificationEmailEn({ recipient: RECIPIENT, verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    expect(tpl.subject.length).toBeGreaterThan(0);
  });

  it('html contains the verification URL', () => {
    const tpl = verificationEmailEn({ recipient: RECIPIENT, verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    expect(tpl.html).toContain(VERIFICATION_URL);
  });

  it('text contains the verification URL', () => {
    const tpl = verificationEmailEn({ recipient: RECIPIENT, verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    expect(tpl.text).toContain(VERIFICATION_URL);
  });

  it('html is non-empty and contains DOCTYPE', () => {
    const tpl = verificationEmailEn({ recipient: RECIPIENT, verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    expect(tpl.html).toContain('<!DOCTYPE html>');
  });

  it('text contains expiry information', () => {
    const tpl = verificationEmailEn({ recipient: RECIPIENT, verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    expect(tpl.text).toContain(FUTURE.toUTCString());
  });
});

describe('verificationEmailRu', () => {
  it('produces a non-empty subject in Russian', () => {
    const tpl = verificationEmailRu({ recipient: RECIPIENT, verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    expect(tpl.subject.length).toBeGreaterThan(0);
    // subject contains Cyrillic characters
    expect(/[а-яА-ЯёЁ]/.test(tpl.subject)).toBe(true);
  });

  it('html contains the verification URL', () => {
    const tpl = verificationEmailRu({ recipient: RECIPIENT, verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    expect(tpl.html).toContain(VERIFICATION_URL);
  });

  it('text contains the verification URL', () => {
    const tpl = verificationEmailRu({ recipient: RECIPIENT, verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    expect(tpl.text).toContain(VERIFICATION_URL);
  });

  it('html and text are both populated', () => {
    const tpl = verificationEmailRu({ recipient: RECIPIENT, verificationUrl: VERIFICATION_URL, expiresAt: FUTURE });
    expect(tpl.html.length).toBeGreaterThan(100);
    expect(tpl.text.length).toBeGreaterThan(50);
  });
});

// ─── Password-reset templates ────────────────────────────────────────────────

describe('passwordResetEmailEn', () => {
  it('produces a non-empty subject', () => {
    const tpl = passwordResetEmailEn({ recipient: RECIPIENT, resetUrl: RESET_URL, expiresAt: FUTURE });
    expect(tpl.subject.length).toBeGreaterThan(0);
  });

  it('html contains the reset URL', () => {
    const tpl = passwordResetEmailEn({ recipient: RECIPIENT, resetUrl: RESET_URL, expiresAt: FUTURE });
    expect(tpl.html).toContain(RESET_URL);
  });

  it('text contains the reset URL', () => {
    const tpl = passwordResetEmailEn({ recipient: RECIPIENT, resetUrl: RESET_URL, expiresAt: FUTURE });
    expect(tpl.text).toContain(RESET_URL);
  });

  it('html contains the email shell wrapper', () => {
    const tpl = passwordResetEmailEn({ recipient: RECIPIENT, resetUrl: RESET_URL, expiresAt: FUTURE });
    expect(tpl.html).toContain('Coriolis Companion');
    expect(tpl.html).toContain('<!DOCTYPE html>');
  });

  it('text mentions the 1-hour expiry', () => {
    const tpl = passwordResetEmailEn({ recipient: RECIPIENT, resetUrl: RESET_URL, expiresAt: FUTURE });
    expect(tpl.text).toContain('one hour');
  });
});

describe('passwordResetEmailRu', () => {
  it('produces a non-empty subject in Russian', () => {
    const tpl = passwordResetEmailRu({ recipient: RECIPIENT, resetUrl: RESET_URL, expiresAt: FUTURE });
    expect(tpl.subject.length).toBeGreaterThan(0);
    expect(/[а-яА-ЯёЁ]/.test(tpl.subject)).toBe(true);
  });

  it('html contains the reset URL', () => {
    const tpl = passwordResetEmailRu({ recipient: RECIPIENT, resetUrl: RESET_URL, expiresAt: FUTURE });
    expect(tpl.html).toContain(RESET_URL);
  });

  it('text contains the reset URL', () => {
    const tpl = passwordResetEmailRu({ recipient: RECIPIENT, resetUrl: RESET_URL, expiresAt: FUTURE });
    expect(tpl.text).toContain(RESET_URL);
  });

  it('html and text are both populated', () => {
    const tpl = passwordResetEmailRu({ recipient: RECIPIENT, resetUrl: RESET_URL, expiresAt: FUTURE });
    expect(tpl.html.length).toBeGreaterThan(100);
    expect(tpl.text.length).toBeGreaterThan(50);
  });
});
