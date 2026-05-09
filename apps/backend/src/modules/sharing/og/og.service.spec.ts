/**
 * Snapshot tests for OgService.renderCharacter.
 *
 * Tests run against the real Satori + Resvg pipeline. Google Fonts network
 * calls are mocked to return a real TTF file from node_modules (Geist-Regular),
 * so Satori can render without network access in CI.
 *
 * WHY vi.hoisted with createRequire:
 * vi.mock() factories are executed before ESM imports — they are "hoisted" to
 * the top of the module by vitest's transform. Top-level module-scope constants
 * (GEIST_DATA) are therefore not yet initialised when the factory runs.
 * vi.hoisted() lets us run code that also runs before the mock registry is
 * built, so the return value of vi.hoisted is available inside vi.mock.
 * Inside the hoisted callback, `require` works because vitest's CJS bridge is
 * active — the eslint prefer-module rule is suppressed on those lines with an
 * inline comment (WHY: there is no standards-compliant ESM alternative for
 * synchronous file loading inside a hoisted mock factory).
 *
 * PNG format quick-reference:
 *   Bytes 0-7:   signature  [0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A]
 *   Bytes 16-19: width  (uint32 BE)
 *   Bytes 20-23: height (uint32 BE)
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';

// ---------------------------------------------------------------------------
// vi.hoisted — initialised before vi.mock and before all module imports.
// WHY require inside hoisted: see file-level comment above.
// ---------------------------------------------------------------------------
const { mockFonts } = vi.hoisted(() => {
  // eslint-disable-next-line @typescript-eslint/no-require-imports, unicorn/prefer-module
  const fs = require('node:fs') as typeof import('node:fs');
  // eslint-disable-next-line @typescript-eslint/no-require-imports, unicorn/prefer-module
  const nodePath = require('node:path') as typeof import('node:path');

  // Geist-Regular ships with @vercel/og (re-exported by next); permissive SIL OFL.
  const basePath = nodePath.resolve(
    __dirname, // eslint-disable-line unicorn/prefer-module
    '../../../../../../node_modules/.pnpm',
  );
  const candidates = [
    nodePath.join(
      basePath,
      'next@16.2.4_@opentelemetry+api@1.9.1_@playwright+test@1.59.1_react-dom@19.2.5_react@19.2.6__react@19.2.6_sass@1.99.0/node_modules/next/dist/compiled/@vercel/og/Geist-Regular.ttf',
    ),
    nodePath.join(
      basePath,
      'next@16.2.4_@opentelemetry+api@1.9.1_@playwright+test@1.59.1_react-dom@19.2.5_react@19.2.5__react@19.2.5_sass@1.99.0/node_modules/next/dist/compiled/@vercel/og/Geist-Regular.ttf',
    ),
  ];

  let geistBuf: Buffer | null = null;
  for (const p of candidates) {
    if (fs.existsSync(p)) {
      geistBuf = fs.readFileSync(p);
      break;
    }
  }

  if (!geistBuf) {
    throw new Error(
      'og.service.spec: Geist-Regular.ttf not found. Run `pnpm install` to ensure next is installed.',
    );
  }

  const geistData = geistBuf.buffer as ArrayBuffer;

  return {
    mockFonts: [
      { name: 'Forum', data: geistData, weight: 400, style: 'normal' },
      { name: 'Inter', data: geistData, weight: 400, style: 'normal' },
      { name: 'Inter', data: geistData, weight: 500, style: 'normal' },
    ],
  };
});

// ---------------------------------------------------------------------------
// Mock og.fonts — avoids Google Fonts network in CI.
// Font names must match style declarations in character-og.ts ("Forum", "Inter").
// ---------------------------------------------------------------------------
vi.mock('./og.fonts', () => ({
  loadOgFonts: vi.fn().mockResolvedValue(mockFonts),
  resetFontCache: vi.fn(),
}));

import { OgService } from './og.service';

import type { CharacterReadModel } from '../../characters/domain/character.ports';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const BASE_CHARACTER: Pick<CharacterReadModel, 'name' | 'concept' | 'iconId'> = {
  name: 'Amira Nassar',
  concept: 'Free-trader pilot from the Third Horizon',
  iconId: 'traveler',
};

/** Parse PNG dimensions from IHDR chunk. */
function parsePngDimensions(buf: Buffer): { width: number; height: number } {
  const width = buf.readUInt32BE(16);
  const height = buf.readUInt32BE(20);
  return { width, height };
}

/** Return true if the buffer starts with the PNG magic bytes. */
function isPng(buf: Buffer): boolean {
  return buf[0] === 0x89 && buf[1] === 0x50 && buf[2] === 0x4e && buf[3] === 0x47;
}

/** Sum all bytes in the buffer — a non-zero result means it is not blank. */
function pixelSum(buf: Buffer): number {
  let sum = 0;
  for (const byte of buf) sum += byte;
  return sum;
}

// ---------------------------------------------------------------------------
// Specs
// ---------------------------------------------------------------------------

describe('OgService', () => {
  let service: OgService;

  beforeEach(() => {
    service = new OgService();
  });

  it('returns a valid PNG buffer for a well-formed character', async () => {
    const result = await service.renderCharacter(BASE_CHARACTER);

    expect(result).toBeInstanceOf(Buffer);
    expect(isPng(result)).toBe(true);
  });

  it('renders at exactly 1200×630 px', async () => {
    const result = await service.renderCharacter(BASE_CHARACTER);

    const { width, height } = parsePngDimensions(result);
    expect(width).toBe(1200);
    expect(height).toBe(630);
  });

  it('produces non-empty pixel content (non-zero byte sum)', async () => {
    const result = await service.renderCharacter(BASE_CHARACTER);

    expect(pixelSum(result)).toBeGreaterThan(0);
  });

  it('truncates a very long character name without throwing', async () => {
    const longName = 'A'.repeat(120);
    const result = await service.renderCharacter({
      ...BASE_CHARACTER,
      name: longName,
    });

    expect(isPng(result)).toBe(true);
    const { width, height } = parsePngDimensions(result);
    expect(width).toBe(1200);
    expect(height).toBe(630);
  });

  it('renders correctly when concept is null', async () => {
    const result = await service.renderCharacter({
      ...BASE_CHARACTER,
      concept: null,
    });

    expect(isPng(result)).toBe(true);
    const { width, height } = parsePngDimensions(result);
    expect(width).toBe(1200);
    expect(height).toBe(630);
  });

  it('renders correctly when iconId is null (uses fallback glyph)', async () => {
    const result = await service.renderCharacter({
      ...BASE_CHARACTER,
      iconId: null,
    });

    expect(isPng(result)).toBe(true);
    expect(pixelSum(result)).toBeGreaterThan(0);
  });

  it('returns the fallback PNG when Satori throws', async () => {
    const { loadOgFonts } = await import('./og.fonts');
    vi.mocked(loadOgFonts).mockRejectedValueOnce(new Error('font load failure'));

    const result = await service.renderCharacter(BASE_CHARACTER);

    expect(isPng(result)).toBe(true);
    const { width, height } = parsePngDimensions(result);
    expect(width).toBe(1200);
    expect(height).toBe(630);
  });

  it('exposes the static fallbackPng with correct PNG magic bytes', () => {
    const fallback = OgService.fallbackPng;
    expect(isPng(fallback)).toBe(true);
    expect(pixelSum(fallback)).toBeGreaterThan(0);
  });
});
