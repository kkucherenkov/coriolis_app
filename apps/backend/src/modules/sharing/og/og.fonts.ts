/**
 * WHY this file exists:
 * Satori requires font data as ArrayBuffer at render time. Loading fonts lazily
 * (once, on first render) avoids cold-start overhead for rare OG image requests.
 *
 * Font families match specs/design/tokens/typography.json:
 *   font.family.display → Forum (or Cormorant Garamond as fallback)
 *   font.family.body    → Inter
 *
 * In environments without internet access (CI, air-gapped production), font
 * fetching will fail and the service will catch the error, returning the
 * hardcoded fallback PNG. No crash — just a safe degradation.
 *
 * Google Fonts CSS API v2 is used to get the actual font file URL, then the
 * binary is fetched. Both requests carry a browser-like User-Agent header so
 * Google Fonts returns TTF/OTF (not woff2, which Satori cannot parse).
 */

import { Logger } from '@nestjs/common';

const logger = new Logger('OgFonts');

/** User-Agent header that makes Google Fonts return TTF (not woff2). */
const GFONTS_UA =
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.0.0 Safari/537.36';

/** Satori-compatible font descriptor. */
export interface SatoriFont {
  name: string;
  data: ArrayBuffer;
  weight: 400 | 500 | 600 | 700;
  style: 'normal' | 'italic';
}

async function fetchGoogleFont(family: string, weight: number): Promise<ArrayBuffer | null> {
  const cssUrl = `https://fonts.googleapis.com/css2?family=${encodeURIComponent(family)}:wght@${String(weight)}&display=swap`;
  try {
    const cssRes = await fetch(cssUrl, {
      headers: { 'User-Agent': GFONTS_UA },
      signal: AbortSignal.timeout(8000),
    });
    if (!cssRes.ok) {
      logger.warn(
        `Google Fonts CSS fetch failed for ${family}:${String(weight)} — status ${String(cssRes.status)}`,
      );
      return null;
    }
    const css = await cssRes.text();

    // Extract the first src: url(...) pointing to a font binary.
    const match = /src:\s*url\(([^)]+)\)/.exec(css);
    if (!match) {
      logger.warn(`No font URL found in Google Fonts CSS for ${family}:${String(weight)}`);
      return null;
    }

    const fontUrl = match[1];
    if (!fontUrl) {
      logger.warn(`Font URL capture group empty for ${family}:${String(weight)}`);
      return null;
    }
    const fontRes = await fetch(fontUrl, { signal: AbortSignal.timeout(8000) });
    if (!fontRes.ok) {
      logger.warn(
        `Font binary fetch failed for ${family}:${String(weight)} — status ${String(fontRes.status)}`,
      );
      return null;
    }
    return await fontRes.arrayBuffer();
  } catch (error) {
    logger.warn(`Font fetch error for ${family}:${String(weight)} — ${String(error)}`);
    return null;
  }
}

let cachedFonts: SatoriFont[] | null = null;

/**
 * Load and cache Satori font descriptors.
 *
 * Returns an empty array on failure; Satori will fall back to a built-in
 * sans-serif if no fonts are provided, which is acceptable for the fallback path.
 */
export async function loadOgFonts(): Promise<SatoriFont[]> {
  if (cachedFonts !== null) return cachedFonts;

  const [forumData, interRegularData, interMediumData] = await Promise.all([
    fetchGoogleFont('Forum', 400),
    fetchGoogleFont('Inter', 400),
    fetchGoogleFont('Inter', 500),
  ]);

  const fonts: SatoriFont[] = [];

  if (forumData) {
    fonts.push({ name: 'Forum', data: forumData, weight: 400, style: 'normal' });
  } else {
    logger.warn('Forum font unavailable — character names will render in fallback font');
  }

  if (interRegularData) {
    fonts.push({ name: 'Inter', data: interRegularData, weight: 400, style: 'normal' });
  }

  if (interMediumData) {
    fonts.push({ name: 'Inter', data: interMediumData, weight: 500, style: 'normal' });
  }

  cachedFonts = fonts;
  return fonts;
}

/** Reset the font cache — used only in tests. */
export function resetFontCache(): void {
  cachedFonts = null;
}
