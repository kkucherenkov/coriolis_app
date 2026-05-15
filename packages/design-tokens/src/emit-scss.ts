import { resolveTypographyValue } from './parse.ts';
import {
  BANNER,
  type ColorFile,
  type ColorGroup,
  type CubicBezierValue,
  type ShadowPart,
  type ShadowValue,
  type TokenBundle,
  type TypographyFile,
  type TypographyValue,
} from './types.ts';

const COLOR_GROUPS: readonly ColorGroup[] = ['surface', 'brand', 'text', 'state'];

function* leafEntries<T>(record: Record<string, T>): Iterable<[string, T]> {
  for (const [key, value] of Object.entries(record)) {
    if (key.startsWith('$')) continue;
    yield [key, value];
  }
}

function kebab(name: string): string {
  return name
    .replaceAll(/([a-z])([A-Z])/g, '$1-$2')
    .replaceAll(/([a-zA-Z])(\d)/g, '$1-$2')
    .toLowerCase();
}

function familyValue(value: string | string[]): string {
  const list = Array.isArray(value) ? value : [value];
  return list.map((name) => (name.includes(' ') ? `"${name}"` : name)).join(', ');
}

function bezierToCss(value: CubicBezierValue | string): string {
  if (typeof value === 'string') return value;
  return `cubic-bezier(${value.x1}, ${value.y1}, ${value.x2}, ${value.y2})`;
}

function shadowPartToCss(part: ShadowPart): string {
  const tokens = [part.offsetX, part.offsetY, part.blur];
  if (part.spread !== '0px' && part.spread !== '0') tokens.push(part.spread);
  tokens.push(part.color);
  return [part.inset === true ? 'inset' : '', ...tokens].filter(Boolean).join(' ');
}

function shadowsToCss(value: ShadowValue): string {
  const parts = Array.isArray(value) ? value : [value];
  return parts.map(shadowPartToCss).join(', ');
}

function familyRef(typography: TypographyFile, key: string): string {
  if (key in typography.font.family) return `var(--font-${kebab(key)})`;
  return key;
}

function weightRef(typography: TypographyFile, key: string | number): string {
  if (typeof key === 'number') return key.toString();
  if (key in typography.font.weight) return `var(--fw-${kebab(key)})`;
  return key;
}

function lineHeight(value: string | number): string {
  return typeof value === 'number' ? value.toString() : value;
}

function emitTypeRole(role: string, raw: TypographyValue, typography: TypographyFile): string[] {
  // Resolve `{font.<bucket>.<key>}` refs before emit — see ADR-0004.
  const value = resolveTypographyValue(typography, raw);
  const prefix = `--type-${kebab(role)}`;
  const lines = [
    `  ${prefix}-font-family: ${familyRef(typography, value.fontFamily)};`,
    `  ${prefix}-font-size: ${value.fontSize};`,
    `  ${prefix}-line-height: ${lineHeight(value.lineHeight)};`,
    `  ${prefix}-font-weight: ${weightRef(typography, value.fontWeight)};`,
    `  ${prefix}-letter-spacing: ${value.letterSpacing ?? 'normal'};`,
  ];
  if (value.textCase !== undefined && value.textCase !== 'none') {
    lines.push(`  ${prefix}-text-transform: ${value.textCase};`);
  }
  return lines;
}

function emitColorBlock(
  color: ColorFile['color'] | NonNullable<ColorFile['theme']>[string]['color'],
): string[] {
  const lines: string[] = [];
  if (!color) return lines;
  for (const group of COLOR_GROUPS) {
    const entries = color[group];
    if (!entries) continue;
    for (const [key, leaf] of leafEntries(entries)) {
      lines.push(`  --${group}-${kebab(key)}: ${leaf.$value};`);
    }
  }
  return lines;
}

function durationKey(name: string): string {
  return name === 'default' ? '--motion-duration' : `--motion-duration-${kebab(name)}`;
}

export function emitScss(tokens: TokenBundle): string {
  const lines: string[] = [BANNER, '', ':root {'];

  for (const [key, leaf] of leafEntries(tokens.typography.font.family)) {
    lines.push(`  --font-${kebab(key)}: ${familyValue(leaf.$value)};`);
  }
  for (const [key, leaf] of leafEntries(tokens.typography.font.weight)) {
    lines.push(`  --fw-${kebab(key)}: ${leaf.$value};`);
  }

  for (const [role, leaf] of leafEntries(tokens.typography.typography)) {
    lines.push(...emitTypeRole(role, leaf.$value, tokens.typography));
  }

  for (const [key, leaf] of leafEntries(tokens.spacing.spacing)) {
    lines.push(`  --space-${kebab(key)}: ${leaf.$value};`);
  }

  for (const [key, leaf] of leafEntries(tokens.radius.radius)) {
    lines.push(`  --radius-${kebab(key)}: ${leaf.$value};`);
  }

  for (const [key, leaf] of leafEntries(tokens.motion.motion.duration)) {
    lines.push(`  ${durationKey(key)}: ${leaf.$value};`);
  }
  for (const [key, leaf] of leafEntries(tokens.motion.motion.ease)) {
    lines.push(`  --motion-ease-${kebab(key)}: ${bezierToCss(leaf.$value)};`);
  }

  for (const [key, leaf] of leafEntries(tokens.zIndex['z-index'])) {
    lines.push(`  --z-${kebab(key)}: ${leaf.$value};`);
  }

  for (const [key, leaf] of leafEntries(tokens.opacity.opacity)) {
    lines.push(`  --opacity-${kebab(key)}: ${leaf.$value};`);
  }

  lines.push(...emitColorBlock(tokens.color.color));

  for (const [key, leaf] of leafEntries(tokens.shadow.shadow)) {
    lines.push(`  --shadow-${kebab(key)}: ${shadowsToCss(leaf.$value)};`);
  }

  lines.push('}');

  if (tokens.color.theme) {
    for (const [themeName, theme] of leafEntries(tokens.color.theme)) {
      const overrides = emitColorBlock(theme.color);
      if (overrides.length === 0) continue;
      lines.push('', `[data-theme='${themeName}'] {`, ...overrides, '}');
    }
  }

  lines.push('');
  return lines.join('\n');
}
