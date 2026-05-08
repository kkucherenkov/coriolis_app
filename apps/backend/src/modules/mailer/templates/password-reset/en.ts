/**
 * English password-reset email template — Coriolis voice.
 * Tone: calm reassurance — a Navigator helping you re-chart your course,
 * not a cold system alert. Expires in 1 hour (PRD §5.1).
 */
import { wrapInEmailShell } from '../email-shell';

export interface EmailTemplate {
  readonly subject: string;
  readonly html: string;
  readonly text: string;
}

export interface PasswordResetPayload {
  readonly recipient: string;
  readonly resetUrl: string;
  readonly expiresAt: Date;
}

function formatExpiry(expiresAt: Date): string {
  return expiresAt.toUTCString();
}

export function passwordResetEmailEn(payload: PasswordResetPayload): EmailTemplate {
  const { resetUrl, expiresAt } = payload;
  const expiry = formatExpiry(expiresAt);

  const subject = 'Chart a new course — password reset';

  const htmlContent = `
    <h1 style="margin:0 0 20px 0;font-family:Georgia,'Times New Roman',serif;font-size:22px;font-weight:normal;color:#F4E4B8;letter-spacing:1px;">
      Re-chart Your Course
    </h1>
    <p style="margin:0 0 16px 0;">
      A request to reset your Coriolis Companion password was received. If you sent this signal,
      use the link below to set a new passphrase and regain your heading.
    </p>
    <p style="margin:0 0 24px 0;">
      This link remains open for <strong style="color:#F4E4B8;">one hour</strong>. After that,
      the coordinates expire and you will need to request a fresh bearing.
    </p>

    <!-- CTA button -->
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="margin:0 0 24px 0;">
      <tr>
        <td align="center" style="border-radius:4px;background-color:#D4A95C;">
          <a href="${resetUrl}"
             target="_blank"
             style="display:inline-block;padding:14px 32px;font-family:Georgia,'Times New Roman',serif;font-size:14px;font-weight:bold;letter-spacing:1px;color:#0B0E2C;text-decoration:none;border-radius:4px;">
            Reset My Password
          </a>
        </td>
      </tr>
    </table>

    <p style="margin:0 0 12px 0;font-size:13px;color:#D9CDB0;">
      If the button does not respond, copy this link into your navigator:
    </p>
    <p style="margin:0 0 20px 0;font-size:12px;word-break:break-all;">
      <a href="${resetUrl}" style="color:#D4A95C;text-decoration:underline;">${resetUrl}</a>
    </p>

    <p style="margin:0 0 12px 0;font-size:12px;color:#D9CDB0;">
      Link expires: ${expiry}
    </p>
    <p style="margin:0;font-size:12px;color:#D9CDB0;">
      If you did not request this reset, your account is safe — no changes have been made.
      You may ignore this transmission.
    </p>
  `;

  const text = `Re-chart Your Course

A request to reset your Coriolis Companion password was received. If you sent this signal, use the link below to set a new passphrase.

${resetUrl}

This link remains open for one hour. After that, you will need to request a fresh bearing.

Link expires: ${expiry}

If you did not request this reset, your account is safe — no changes have been made. You may ignore this transmission.`;

  return {
    subject,
    html: wrapInEmailShell(htmlContent, 'Reset your Coriolis Companion password — link valid for 1 hour.'),
    text,
  };
}
