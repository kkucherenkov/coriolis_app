import { readFileSync } from 'node:fs';
import path from 'node:path';

import type {
  ColorFile,
  MotionFile,
  OpacityFile,
  RadiusFile,
  ShadowFile,
  SpacingFile,
  TokenBundle,
  TypographyFile,
  ZIndexFile,
} from './types.ts';

function readJson<T>(file: string): T {
  return JSON.parse(readFileSync(file, 'utf8')) as T;
}

export function loadTokens(repoRoot: string): TokenBundle {
  const dir = path.join(repoRoot, 'specs/design/tokens');
  return {
    color: readJson<ColorFile>(path.join(dir, 'color.json')),
    typography: readJson<TypographyFile>(path.join(dir, 'typography.json')),
    spacing: readJson<SpacingFile>(path.join(dir, 'spacing.json')),
    radius: readJson<RadiusFile>(path.join(dir, 'radius.json')),
    shadow: readJson<ShadowFile>(path.join(dir, 'shadow.json')),
    motion: readJson<MotionFile>(path.join(dir, 'motion.json')),
    opacity: readJson<OpacityFile>(path.join(dir, 'opacity.json')),
    zIndex: readJson<ZIndexFile>(path.join(dir, 'z-index.json')),
  };
}
