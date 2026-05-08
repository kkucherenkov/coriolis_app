/**
 * Russian password-reset email template — Coriolis voice.
 * Same reassuring tone as the English version, adapted for natural Russian
 * rather than a direct translation.
 */
import { wrapInEmailShell } from '../email-shell';

import type { EmailTemplate, PasswordResetPayload } from './en';

function formatExpiry(expiresAt: Date): string {
  return expiresAt.toUTCString();
}

export function passwordResetEmailRu(payload: PasswordResetPayload): EmailTemplate {
  const { resetUrl, expiresAt } = payload;
  const expiry = formatExpiry(expiresAt);

  const subject = 'Проложите новый курс — сброс пароля';

  const htmlContent = `
    <h1 style="margin:0 0 20px 0;font-family:Georgia,'Times New Roman',serif;font-size:22px;font-weight:normal;color:#F4E4B8;letter-spacing:1px;">
      Проложите новый курс
    </h1>
    <p style="margin:0 0 16px 0;">
      Получен запрос на сброс пароля Coriolis Companion. Если это были вы — используйте
      ссылку ниже, чтобы установить новый пароль и вернуться на курс.
    </p>
    <p style="margin:0 0 24px 0;">
      Ссылка действует <strong style="color:#F4E4B8;">один час</strong>. После этого координаты
      устареют, и вам потребуется запросить новую.
    </p>

    <!-- CTA button -->
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="margin:0 0 24px 0;">
      <tr>
        <td align="center" style="border-radius:4px;background-color:#D4A95C;">
          <a href="${resetUrl}"
             target="_blank"
             style="display:inline-block;padding:14px 32px;font-family:Georgia,'Times New Roman',serif;font-size:14px;font-weight:bold;letter-spacing:1px;color:#0B0E2C;text-decoration:none;border-radius:4px;">
            Сбросить пароль
          </a>
        </td>
      </tr>
    </table>

    <p style="margin:0 0 12px 0;font-size:13px;color:#D9CDB0;">
      Если кнопка не отвечает, скопируйте ссылку в браузер:
    </p>
    <p style="margin:0 0 20px 0;font-size:12px;word-break:break-all;">
      <a href="${resetUrl}" style="color:#D4A95C;text-decoration:underline;">${resetUrl}</a>
    </p>

    <p style="margin:0 0 12px 0;font-size:12px;color:#D9CDB0;">
      Срок действия: ${expiry}
    </p>
    <p style="margin:0;font-size:12px;color:#D9CDB0;">
      Если вы не запрашивали сброс, ваш аккаунт в безопасности — никаких изменений не произошло.
      Это сообщение можно проигнорировать.
    </p>
  `;

  const text = `Проложите новый курс

Получен запрос на сброс пароля Coriolis Companion. Если это были вы — перейдите по ссылке ниже, чтобы установить новый пароль.

${resetUrl}

Ссылка действует один час. После этого потребуется запросить новую.

Срок действия: ${expiry}

Если вы не запрашивали сброс, ваш аккаунт в безопасности — никаких изменений не произошло. Это сообщение можно проигнорировать.`;

  return {
    subject,
    html: wrapInEmailShell(htmlContent, 'Сброс пароля Coriolis Companion — ссылка действует 1 час.'),
    text,
  };
}
