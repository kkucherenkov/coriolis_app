// Small parsers that turn CSS-shaped strings into Dart-friendly values.

import type { TypographyFile, TypographyValue } from './types.ts';

/**
 * Resolve a DTCG-style `{font.<bucket>.<key>}` reference against a
 * TypographyFile. Throws on unknown paths so `pnpm design:build` fails loud
 * on typos rather than silently emitting the literal `{font.size.42}` string.
 *
 * Resolution mode depends on the bucket — the downstream emitters need
 * different shapes:
 *
 * - `{font.family.X}` → returns the bare key `X` so emit-scss/emit-dart can
 *   still convert it to `var(--font-X)` / `AppFontFamily.X`.
 * - `{font.weight.X}` → returns the bare key `X` for the same reason.
 * - `{font.size.X}` → returns the leaf `$value` literal (e.g. `"16px"`).
 * - `{font.line-height.X}` → returns the leaf `$value` number (e.g. `1.25`).
 * - `{font.tracking.X}` → returns the leaf `$value` literal (e.g. `"0.06em"`).
 *
 * Non-ref inputs (literals without `{}` brackets) are returned unchanged so
 * pre-existing inline literals stay forward-compatible.
 */
export function resolveRef(typography: TypographyFile, input: string | number): string | number {
  if (typeof input !== 'string') return input;
  if (!input.startsWith('{') || !input.endsWith('}')) return input;

  const path = input.slice(1, -1).split('.');
  if (path[0] !== 'font') {
    throw new Error(`Unsupported token reference: ${input} (expected {font.*.*})`);
  }
  const bucket = path[1] ?? '';
  const key = path.slice(2).join('.');
  if (bucket === '' || key === '') {
    throw new Error(`Malformed token reference: ${input}`);
  }

  // For family / weight: return the bare key so downstream emitters keep
  // producing `var(--font-X)` / `var(--fw-X)` references rather than inlining.
  if (bucket === 'family' || bucket === 'weight') {
    const lookup = (typography.font as Record<string, Record<string, unknown> | undefined>)[bucket];
    if (lookup === undefined || !(key in lookup)) {
      throw new Error(`Unresolved token reference: ${input}`);
    }
    return key;
  }

  // For size / line-height / tracking: walk to the DTCG leaf and return its $value.
  const lookup = (typography.font as Record<string, Record<string, unknown> | undefined>)[bucket];
  if (lookup === undefined) {
    throw new Error(
      `Unknown token bucket in ${input} — bucket "${bucket}" is not declared on font.*`,
    );
  }
  if (!(key in lookup)) {
    throw new Error(`Unresolved token reference: ${input}`);
  }
  const leaf = lookup[key] as { $value?: string | number | string[] } | undefined;
  if (leaf?.$value === undefined) {
    throw new Error(`Token reference does not point at a DTCG leaf: ${input}`);
  }
  const value = leaf.$value;
  if (Array.isArray(value)) {
    return value.map((name) => (name.includes(' ') ? `"${name}"` : name)).join(', ');
  }
  return value;
}

/**
 * Resolve every field of a composite typography value through the atom layer.
 * After this pass, `fontFamily` / `fontWeight` carry their bucket key (string)
 * and `fontSize` / `lineHeight` / `letterSpacing` carry their literal values.
 * No `{...}` ref-form strings survive.
 */
export function resolveTypographyValue(
  typography: TypographyFile,
  value: TypographyValue,
): TypographyValue {
  const resolved: TypographyValue = {
    fontFamily: String(resolveRef(typography, value.fontFamily)),
    fontSize: String(resolveRef(typography, value.fontSize)),
    lineHeight: resolveRef(typography, value.lineHeight),
    fontWeight: resolveRef(typography, value.fontWeight),
  };
  if (value.letterSpacing !== undefined) {
    resolved.letterSpacing = String(resolveRef(typography, value.letterSpacing));
  }
  if (value.textCase !== undefined) {
    resolved.textCase = value.textCase;
  }
  return resolved;
}

export interface ParsedColor {
  r: number;
  g: number;
  b: number;
  a: number; // 0..1
}

export function parseColor(input: string): ParsedColor {
  const value = input.trim();

  if (value.startsWith('#')) {
    const hex = value.slice(1);
    // Hex color strings are pure ASCII (0-9, a-f) — code-unit spread is safe here.
    // eslint-disable-next-line @typescript-eslint/no-misused-spread
    const expand = (h: string): string => (h.length === 3 ? [...h].map((c) => c + c).join('') : h);
    const full = expand(hex);
    if (full.length !== 6 && full.length !== 8) {
      throw new Error(`Unsupported hex color: ${input}`);
    }
    const r = Number.parseInt(full.slice(0, 2), 16);
    const g = Number.parseInt(full.slice(2, 4), 16);
    const b = Number.parseInt(full.slice(4, 6), 16);
    const a = full.length === 8 ? Number.parseInt(full.slice(6, 8), 16) / 255 : 1;
    return { r, g, b, a };
  }

  const rgbaMatch =
    /^rgba?\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)\s*(?:,\s*([0-9.]+)\s*)?\)$/.exec(value);
  if (rgbaMatch) {
    return {
      r: Number(rgbaMatch[1]),
      g: Number(rgbaMatch[2]),
      b: Number(rgbaMatch[3]),
      a: rgbaMatch[4] === undefined ? 1 : Number(rgbaMatch[4]),
    };
  }

  throw new Error(`Cannot parse color: ${input}`);
}

function toHex2(value: number): string {
  return value.toString(16).padStart(2, '0').toUpperCase();
}

function packArgb(r: number, g: number, b: number, a: number): string {
  const alpha = Math.round(a * 255);
  return `0x${toHex2(alpha)}${toHex2(r)}${toHex2(g)}${toHex2(b)}`;
}

export function colorToDart(input: string): string {
  const { r, g, b, a } = parseColor(input);
  // Use packed ARGB literal so the expression is a const constructor call — required for
  // `static const` fields (Color.fromRGBO is not const).
  return `Color(${packArgb(r, g, b, a)})`;
}

export interface ParsedShadow {
  offsetX: number;
  offsetY: number;
  blur: number;
  spread: number;
  color: ParsedColor;
}

function stripPx(token: string): number {
  const trimmed = token.trim();
  if (trimmed === '0') return 0;
  if (trimmed.endsWith('px')) return Number(trimmed.slice(0, -2));
  return Number(trimmed);
}

export function parseShadow(input: string): ParsedShadow[] {
  // Split top-level commas (ignore commas inside rgba()/hsla()/etc parens).
  const parts: string[] = [];
  let depth = 0;
  let start = 0;
  for (let i = 0; i < input.length; i += 1) {
    const ch = input[i];
    if (ch === '(') depth += 1;
    else if (ch === ')') depth -= 1;
    else if (ch === ',' && depth === 0) {
      parts.push(input.slice(start, i).trim());
      start = i + 1;
    }
  }
  parts.push(input.slice(start).trim());

  return parts.map((part) => {
    // Extract the color (either #... or rgba(...) or rgb(...)) and leave the rest as offsets.
    const colorMatch = /(#[0-9a-fA-F]+|rgba?\([^)]+\))\s*$/.exec(part);
    if (!colorMatch) throw new Error(`Cannot find color in shadow: ${part}`);
    const colorRaw = colorMatch[1] ?? '';
    const head = part.slice(0, colorMatch.index).trim();
    const lengths = head.split(/\s+/).filter(Boolean);
    if (lengths.length < 2) throw new Error(`Invalid shadow offsets: ${part}`);

    return {
      offsetX: stripPx(lengths[0] ?? '0'),
      offsetY: stripPx(lengths[1] ?? '0'),
      blur: lengths[2] === undefined ? 0 : stripPx(lengths[2]),
      spread: lengths[3] === undefined ? 0 : stripPx(lengths[3]),
      color: parseColor(colorRaw),
    };
  });
}

export function shadowListToDart(input: string): string {
  const parsed = parseShadow(input);
  const shadows = parsed.map((s) => {
    const { r, g, b, a } = s.color;
    const color = `Color(${packArgb(r, g, b, a)})`;
    return `BoxShadow(color: ${color}, offset: Offset(${s.offsetX.toString()}, ${s.offsetY.toString()}), blurRadius: ${s.blur.toString()}, spreadRadius: ${s.spread.toString()})`;
  });
  return `<BoxShadow>[${shadows.join(', ')}]`;
}

export function stripPxForDart(input: string): string {
  const trimmed = input.trim();
  if (trimmed === '0') return '0.0';
  if (trimmed.endsWith('px')) {
    const n = Number(trimmed.slice(0, -2));
    return n.toString().includes('.') ? n.toString() : `${n.toString()}.0`;
  }
  return trimmed;
}

export function parseMs(input: string): number {
  const trimmed = input.trim();
  if (trimmed.endsWith('ms')) return Number(trimmed.slice(0, -2));
  if (trimmed.endsWith('s')) return Number(trimmed.slice(0, -1)) * 1000;
  return Number(trimmed);
}

export function parseCubicBezier(input: string): [number, number, number, number] {
  const match =
    /^cubic-bezier\(\s*([-0-9.]+)\s*,\s*([-0-9.]+)\s*,\s*([-0-9.]+)\s*,\s*([-0-9.]+)\s*\)$/.exec(
      input,
    );
  if (!match) throw new Error(`Not a cubic-bezier: ${input}`);
  return [Number(match[1]), Number(match[2]), Number(match[3]), Number(match[4])];
}
