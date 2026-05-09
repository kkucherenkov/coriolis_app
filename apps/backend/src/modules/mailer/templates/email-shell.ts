/**
 * Canonical HTML shell for all Coriolis Companion transactional emails.
 * Uses inline CSS only — no external stylesheets, no @import — for maximum
 * email client compatibility. Colors are expressed here as hex literals
 * because email clients do not support CSS custom properties. This is the
 * ONLY file in the backend that is allowed to use hex literals for brand
 * colors.
 *
 * Design reference: DESIGN.md §1 (warm, slightly ceremonial; brass-on-indigo)
 *   --surface-void      #0B0E2C
 *   --brand-brass-light #F4E4B8
 *   --brand-brass       #D4A95C
 *   --brand-brass-deep  #A67C28
 *   --text-primary      #F2E8D0
 *   --text-secondary    #D9CDB0
 */

export function wrapInEmailShell(content: string, previewText: string): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="x-apple-disable-message-reformatting" />
  <title>Coriolis Companion</title>
  <!--[if mso]>
  <noscript><xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript>
  <![endif]-->
</head>
<body style="margin:0;padding:0;background-color:#0B0E2C;font-family:Georgia,serif;">
  <!-- Preview text (hidden) -->
  <div style="display:none;font-size:1px;color:#0B0E2C;line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">
    ${escapeHtml(previewText)}&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;
  </div>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation"
         style="background-color:#0B0E2C;min-height:100vh;">
    <tr>
      <td align="center" style="padding:40px 20px;">

        <!-- Outer card -->
        <table width="560" border="0" cellpadding="0" cellspacing="0" role="presentation"
               style="max-width:560px;width:100%;background-color:#15193F;border-radius:6px;border:2px solid #A67C28;overflow:hidden;">

          <!-- Brass top bar -->
          <tr>
            <td style="background-color:#A67C28;height:4px;font-size:0;line-height:0;">&nbsp;</td>
          </tr>

          <!-- Header -->
          <tr>
            <td align="center" style="padding:32px 40px 16px 40px;">
              <p style="margin:0;font-family:Georgia,'Times New Roman',serif;font-size:11px;letter-spacing:4px;text-transform:uppercase;color:#D4A95C;">
                Coriolis Companion
              </p>
            </td>
          </tr>

          <!-- Content -->
          <tr>
            <td style="padding:0 40px 32px 40px;color:#F2E8D0;font-family:Georgia,'Times New Roman',serif;font-size:15px;line-height:1.7;">
              ${content}
            </td>
          </tr>

          <!-- Divider -->
          <tr>
            <td style="padding:0 40px;">
              <div style="border-top:1px solid #A67C28;"></div>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td align="center" style="padding:20px 40px 28px 40px;">
              <p style="margin:0;font-size:11px;color:#D9CDB0;font-family:Georgia,'Times New Roman',serif;line-height:1.6;">
                You are receiving this because an action was taken on your Coriolis Companion account.<br />
                This is an automated message — replies are not monitored.
              </p>
            </td>
          </tr>

          <!-- Brass bottom bar -->
          <tr>
            <td style="background-color:#A67C28;height:2px;font-size:0;line-height:0;">&nbsp;</td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

function escapeHtml(str: string): string {
  return str
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}
