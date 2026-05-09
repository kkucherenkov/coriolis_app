import { colorToDart, parseCubicBezier, parseMs, stripPxForDart } from './parse.ts';
import {
  DART_BANNER,
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

const DART_RESERVED: ReadonlySet<string> = new Set([
  'default',
  'class',
  'void',
  'return',
  'null',
  'true',
  'false',
  'new',
  'this',
  'super',
  'const',
  'final',
  'var',
  'if',
  'else',
  'for',
  'while',
  'switch',
  'case',
  'break',
  'continue',
  'try',
  'catch',
  'in',
  'is',
  'as',
  'with',
  'extends',
  'implements',
  'enum',
]);

function* leafEntries<T>(record: Record<string, T>): Iterable<[string, T]> {
  for (const [key, value] of Object.entries(record)) {
    if (key.startsWith('$')) continue;
    yield [key, value];
  }
}

function camel(name: string): string {
  return name.replaceAll(/[-_]([a-z0-9])/g, (_, c: string) => c.toUpperCase());
}

function safeKey(prefix: string, raw: string): string {
  const key = camel(raw);
  if (/^[0-9]/.test(key)) return `${prefix}${key.charAt(0).toUpperCase()}${key.slice(1)}`;
  if (DART_RESERVED.has(key)) return `${prefix}${key.charAt(0).toUpperCase()}${key.slice(1)}`;
  return key;
}

function dartDouble(value: number | string): string {
  const s = typeof value === 'number' ? value.toString() : value.trim();
  if (s === '0' || s === '0.0') return '0.0';
  if (s.includes('.')) return s;
  return `${s}.0`;
}

function stripEmForDart(input: string): string {
  const trimmed = input.trim();
  if (trimmed === '0') return '0.0';
  if (trimmed.endsWith('em')) return dartDouble(trimmed.slice(0, -2));
  return dartDouble(trimmed);
}

function colorClass(
  name: string,
  color: ColorFile['color'] | NonNullable<ColorFile['theme']>[string]['color'],
): string[] {
  const lines: string[] = [`abstract final class ${name} {`];
  if (color) {
    for (const group of COLOR_GROUPS) {
      const entries = color[group];
      if (!entries) continue;
      for (const [key, leaf] of leafEntries(entries)) {
        const field = camel(`${group}-${key}`);
        lines.push(`  static const Color ${field} = ${colorToDart(leaf.$value)};`);
      }
    }
  }
  lines.push('}');
  return lines;
}

function bezierToDart(value: CubicBezierValue | string): string {
  const tuple: [number, number, number, number] =
    typeof value === 'string' ? parseCubicBezier(value) : [value.x1, value.y1, value.x2, value.y2];
  const [x1, y1, x2, y2] = tuple;
  return `Cubic(${x1}, ${y1}, ${x2}, ${y2})`;
}

function shadowParts(value: ShadowValue): ShadowPart[] {
  return Array.isArray(value) ? value : [value];
}

function boxShadowExpr(part: ShadowPart): string {
  const color = colorToDart(part.color);
  const offsetX = stripPxForDart(part.offsetX);
  const offsetY = stripPxForDart(part.offsetY);
  const blur = stripPxForDart(part.blur);
  const spread = stripPxForDart(part.spread);
  return `BoxShadow(color: ${color}, offset: Offset(${offsetX}, ${offsetY}), blurRadius: ${blur}, spreadRadius: ${spread})`;
}

function shadowExpr(value: ShadowValue): string {
  const outer = shadowParts(value).filter((p) => p.inset !== true);
  if (outer.length === 0) return '<BoxShadow>[]';
  return `<BoxShadow>[${outer.map(boxShadowExpr).join(', ')}]`;
}

function familyValue(value: string | string[]): string {
  const list = Array.isArray(value) ? value : [value];
  const primary = list[0] ?? '';
  return JSON.stringify(primary);
}

function typeRoleField(role: string, value: TypographyValue, typography: TypographyFile): string[] {
  const fieldName = camel(role);
  const familyKey = value.fontFamily;
  const familyExpr =
    familyKey in typography.font.family
      ? `AppFontFamily.${camel(familyKey)}`
      : JSON.stringify(familyKey);
  const weightKey = value.fontWeight;
  const weightExpr =
    typeof weightKey === 'number'
      ? `FontWeight.w${weightKey}`
      : weightKey in typography.font.weight
        ? `AppFontWeight.${camel(weightKey)}`
        : weightKey;
  const fontSizePx = stripPxForDart(value.fontSize);
  const lineHeightSrc =
    typeof value.lineHeight === 'number'
      ? value.lineHeight
      : value.lineHeight.endsWith('px')
        ? Number(value.lineHeight.slice(0, -2)) / Number(value.fontSize.slice(0, -2))
        : Number(value.lineHeight);
  const height = dartDouble(lineHeightSrc);
  const letterSpacing =
    value.letterSpacing === undefined || value.letterSpacing === 'normal'
      ? '0.0'
      : `${stripEmForDart(value.letterSpacing)} * ${fontSizePx}`;
  const lines = [
    `  static const TextStyle ${fieldName} = TextStyle(`,
    `    fontFamily: ${familyExpr},`,
    `    fontSize: ${fontSizePx},`,
    `    fontWeight: ${weightExpr},`,
    `    height: ${height},`,
    `    letterSpacing: ${letterSpacing},`,
  ];
  if (value.textCase !== undefined && value.textCase !== 'none') {
    lines.push(
      `    // textCase: ${value.textCase} — apply via Text.toUpperCase() at the call site`,
    );
  }
  lines.push('  );');
  return lines;
}

export function emitDart(tokens: TokenBundle): string {
  const parts: string[] = [DART_BANNER, '', "import 'package:flutter/widgets.dart';", ''];

  parts.push(...colorClass('AppColors', tokens.color.color), '');
  if (tokens.color.theme) {
    for (const [name, theme] of leafEntries(tokens.color.theme)) {
      const className = `AppColors${camel(name).replace(/^./, (c) => c.toUpperCase())}`;
      parts.push(...colorClass(className, theme.color), '');
    }
  }

  parts.push('abstract final class AppSpacing {');
  for (const [key, leaf] of leafEntries(tokens.spacing.spacing)) {
    parts.push(`  static const double ${safeKey('s', key)} = ${stripPxForDart(leaf.$value)};`);
  }
  parts.push('}', '');

  parts.push('abstract final class AppRadius {');
  for (const [key, leaf] of leafEntries(tokens.radius.radius)) {
    parts.push(`  static const double ${safeKey('r', key)} = ${stripPxForDart(leaf.$value)};`);
  }
  parts.push('}', '');

  parts.push('abstract final class AppFontFamily {');
  for (const [key, leaf] of leafEntries(tokens.typography.font.family)) {
    parts.push(`  static const String ${camel(key)} = ${familyValue(leaf.$value)};`);
  }
  parts.push('}', '', 'abstract final class AppFontWeight {');
  for (const [key, leaf] of leafEntries(tokens.typography.font.weight)) {
    parts.push(`  static const FontWeight ${camel(key)} = FontWeight.w${leaf.$value};`);
  }
  parts.push('}', '');

  parts.push('abstract final class AppTypography {');
  for (const [role, leaf] of leafEntries(tokens.typography.type)) {
    parts.push(...typeRoleField(role, leaf.$value, tokens.typography));
  }
  parts.push('}', '');

  parts.push('abstract final class AppDuration {');
  for (const [key, leaf] of leafEntries(tokens.motion.motion.duration)) {
    parts.push(
      `  static const Duration ${safeKey('d', key)} = Duration(milliseconds: ${parseMs(leaf.$value)});`,
    );
  }
  parts.push('}', '', 'abstract final class AppEasing {');
  for (const [key, leaf] of leafEntries(tokens.motion.motion.ease)) {
    parts.push(`  static const Cubic ${safeKey('ease', key)} = ${bezierToDart(leaf.$value)};`);
  }
  parts.push('}', '');

  parts.push('abstract final class AppZIndex {');
  for (const [key, leaf] of leafEntries(tokens.zIndex['z-index'])) {
    parts.push(`  static const int ${safeKey('z', key)} = ${leaf.$value};`);
  }
  parts.push('}', '');

  parts.push('abstract final class AppOpacity {');
  for (const [key, leaf] of leafEntries(tokens.opacity.opacity)) {
    parts.push(`  static const double ${safeKey('o', key)} = ${dartDouble(leaf.$value)};`);
  }
  parts.push('}', '');

  parts.push('abstract final class AppShadows {');
  for (const [key, leaf] of leafEntries(tokens.shadow.shadow)) {
    parts.push(`  static const List<BoxShadow> ${camel(key)} = ${shadowExpr(leaf.$value)};`);
  }
  parts.push('}', '');

  return parts.join('\n');
}
