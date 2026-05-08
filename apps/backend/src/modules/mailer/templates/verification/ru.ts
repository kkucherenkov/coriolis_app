/**
 * Russian verification email template — Coriolis voice.
 * Same warmth as the English version, adapted naturally to Russian — not a
 * literal translation. The tone is ceremonial but accessible.
 */
import { wrapInEmailShell } from '../email-shell';

import type { EmailTemplate, VerificationPayload } from './en';

function formatExpiry(expiresAt: Date): string {
  return expiresAt.toUTCString();
}

export function verificationEmailRu(payload: VerificationPayload): EmailTemplate {
  const { verificationUrl, expiresAt } = payload;
  const expiry = formatExpiry(expiresAt);

  const subject = 'Подтвердите связь с Компаньоном';

  const htmlContent = `
    <h1 style="margin:0 0 20px 0;font-family:Georgia,'Times New Roman',serif;font-size:22px;font-weight:normal;color:#F4E4B8;letter-spacing:1px;">
      Добро пожаловать в Третий Горизонт
    </h1>
    <p style="margin:0 0 16px 0;">
      Запечатанная передача достигла вас — ваше место среди Компаньонов Третьего Горизонта
      ожидает подтверждения.
    </p>
    <p style="margin:0 0 24px 0;">
      Нажмите на печать ниже, чтобы подтвердить адрес и занять своё место на борту. Ссылка
      действует 24 часа — после этого переход закроется.
    </p>

    <!-- CTA button -->
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="margin:0 0 24px 0;">
      <tr>
        <td align="center" style="border-radius:4px;background-color:#D4A95C;">
          <a href="${verificationUrl}"
             target="_blank"
             style="display:inline-block;padding:14px 32px;font-family:Georgia,'Times New Roman',serif;font-size:14px;font-weight:bold;letter-spacing:1px;color:#0B0E2C;text-decoration:none;border-radius:4px;">
            Подтвердить связь
          </a>
        </td>
      </tr>
    </table>

    <p style="margin:0 0 12px 0;font-size:13px;color:#D9CDB0;">
      Если кнопка не отвечает, скопируйте ссылку в браузер:
    </p>
    <p style="margin:0 0 20px 0;font-size:12px;word-break:break-all;">
      <a href="${verificationUrl}" style="color:#D4A95C;text-decoration:underline;">${verificationUrl}</a>
    </p>

    <p style="margin:0;font-size:12px;color:#D9CDB0;">
      Срок действия: ${expiry}
    </p>
  `;

  const text = `Добро пожаловать в Третий Горизонт

Запечатанная передача достигла вас — ваше место среди Компаньонов Третьего Горизонта ожидает подтверждения.

Подтвердите свой адрес по ссылке ниже. Ссылка действует 24 часа.

${verificationUrl}

Срок действия: ${expiry}

Если вы не создавали аккаунт в Coriolis Companion, просто проигнорируйте это письмо.`;

  return {
    subject,
    html: wrapInEmailShell(htmlContent, 'Подтвердите связь с Компаньоном Кориолиса.'),
    text,
  };
}
