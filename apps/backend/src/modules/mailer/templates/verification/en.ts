/**
 * English verification email template — Coriolis voice.
 * Voice: warm, slightly ceremonial. Suggests the mystique of the Third
 * Horizon without heavy lore drops. The reader is a new Companion registrant,
 * not a Coriolis scholar.
 */
import { wrapInEmailShell } from '../email-shell';

export interface EmailTemplate {
  readonly subject: string;
  readonly html: string;
  readonly text: string;
}

export interface VerificationPayload {
  readonly recipient: string;
  readonly verificationUrl: string;
  readonly expiresAt: Date;
}

function formatExpiry(expiresAt: Date): string {
  return expiresAt.toUTCString();
}

export function verificationEmailEn(payload: VerificationPayload): EmailTemplate {
  const { verificationUrl, expiresAt } = payload;
  const expiry = formatExpiry(expiresAt);

  const subject = 'Confirm your bond with the Companion';

  const htmlContent = `
    <h1 style="margin:0 0 20px 0;font-family:Georgia,'Times New Roman',serif;font-size:22px;font-weight:normal;color:#F4E4B8;letter-spacing:1px;">
      Welcome to the Third Horizon
    </h1>
    <p style="margin:0 0 16px 0;">
      A sealed transmission has arrived — your place among the Companions of the Third Horizon awaits
      your confirmation.
    </p>
    <p style="margin:0 0 24px 0;">
      Press the seal below to verify your address and claim your berth. This link holds for 24 hours
      before the passage closes.
    </p>

    <!-- CTA button -->
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="margin:0 0 24px 0;">
      <tr>
        <td align="center" style="border-radius:4px;background-color:#D4A95C;">
          <a href="${verificationUrl}"
             target="_blank"
             style="display:inline-block;padding:14px 32px;font-family:Georgia,'Times New Roman',serif;font-size:14px;font-weight:bold;letter-spacing:1px;color:#0B0E2C;text-decoration:none;border-radius:4px;">
            Confirm Your Bond
          </a>
        </td>
      </tr>
    </table>

    <p style="margin:0 0 12px 0;font-size:13px;color:#D9CDB0;">
      If the button does not respond, copy this link into your navigator:
    </p>
    <p style="margin:0 0 20px 0;font-size:12px;word-break:break-all;">
      <a href="${verificationUrl}" style="color:#D4A95C;text-decoration:underline;">${verificationUrl}</a>
    </p>

    <p style="margin:0;font-size:12px;color:#D9CDB0;">
      Link expires: ${expiry}
    </p>
  `;

  const text = `Welcome to the Third Horizon

A sealed transmission has arrived — your place among the Companions of the Third Horizon awaits your confirmation.

Confirm your bond by visiting the link below. This link holds for 24 hours before the passage closes.

${verificationUrl}

Link expires: ${expiry}

If you did not create a Coriolis Companion account, you may safely disregard this message.`;

  return {
    subject,
    html: wrapInEmailShell(htmlContent, 'Confirm your bond with the Coriolis Companion.'),
    text,
  };
}
