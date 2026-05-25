#!/usr/bin/env node
/**
 * Design-token resolution check.
 *
 * Fails when a `var(--token)` reference WITHOUT a fallback names a custom
 * property that is defined nowhere in the scanned source. Catches the class of
 * bug where a component references a non-existent token (e.g. `--text-lg-size`,
 * `--motion-duration-standard`) so the declaration silently resolves to its
 * CSS initial value. References that supply a fallback (`var(--x, 1rem)`) are
 * allowed: those degrade gracefully by design.
 *
 * "Defined" = a CSS custom-property declaration (`--x:`) OR a JS style-object
 * key (`'--x':`) anywhere in the scanned tree, so component-local vars injected
 * via :style bindings are not flagged.
 *
 * Run: pnpm tokens:check   (or: node scripts/check-design-tokens.mjs)
 * Exit 0 = clean, 1 = unresolved tokens found.
 */
import { readdirSync, readFileSync, statSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

// Where component styles and tokens live.
const SCAN_DIRS = ['packages/ui/src', 'apps/web/app'];
const EXTENSIONS = new Set(['.vue', '.scss', '.css']);
const SKIP_DIR = new Set(['node_modules', 'dist', '.nuxt', '.output', 'generated']);

/** Recursively collect files with the wanted extensions. */
function walk(dir, out = []) {
  let entries;
  try {
    entries = readdirSync(dir, { withFileTypes: true });
  } catch {
    return out;
  }
  for (const e of entries) {
    if (e.name.startsWith('.') && e.name !== '.') continue;
    const full = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (!SKIP_DIR.has(e.name)) walk(full, out);
    } else if (EXTENSIONS.has(path.extname(e.name))) {
      out.push(full);
    }
  }
  return out;
}

const files = SCAN_DIRS.flatMap((d) => {
  const abs = path.join(REPO_ROOT, d);
  try {
    statSync(abs);
  } catch {
    return [];
  }
  return walk(abs);
});

const TOKEN = '--[a-zA-Z0-9-]+';
const DEF_CSS = new RegExp(`(?<![\\w-])(${TOKEN})\\s*:`, 'g'); // `--x:` declaration
const DEF_JS = new RegExp(`['"](${TOKEN})['"]\\s*:`, 'g'); // `'--x':` style-object key
const REF = new RegExp(`var\\(\\s*(${TOKEN})\\s*([,)])`, 'g'); // var(--x) or var(--x,

/**
 * Blank out comments so token mentions in doc-comments are not scanned, while
 * preserving line numbers (replace comment bodies with spaces/newlines).
 * Handles block comments (CSS/JS), HTML comments (Vue templates), and `//`
 * line comments (SCSS/JS, but not the `//` in `https://` or `url(//`).
 */
function stripComments(src) {
  const blanked = src
    .replace(/\/\*[\s\S]*?\*\//g, (m) => m.replace(/[^\n]/g, ' '))
    .replace(/<!--[\s\S]*?-->/g, (m) => m.replace(/[^\n]/g, ' '));
  return blanked
    .split('\n')
    .map((line) => line.replace(/(^|[^:])\/\/.*$/, (_m, p1) => p1))
    .join('\n');
}

const defined = new Set();
const references = []; // { token, file, line, hasFallback }

for (const file of files) {
  const text = stripComments(readFileSync(file, 'utf8'));
  for (const m of text.matchAll(DEF_CSS)) defined.add(m[1]);
  for (const m of text.matchAll(DEF_JS)) defined.add(m[1]);
  const lines = text.split('\n');
  lines.forEach((line, i) => {
    for (const m of line.matchAll(REF)) {
      references.push({
        token: m[1],
        file: path.relative(REPO_ROOT, file),
        line: i + 1,
        hasFallback: m[2] === ',',
      });
    }
  });
}

const unresolved = references.filter((r) => !r.hasFallback && !defined.has(r.token));

if (unresolved.length === 0) {
  process.stdout.write(
    `tokens:check OK — ${String(references.length)} var() refs across ${String(files.length)} files, all resolve.\n`,
  );
  process.exit(0);
}

process.stderr.write(
  `tokens:check FAILED — ${String(unresolved.length)} unresolved token reference(s):\n\n`,
);
for (const u of unresolved) {
  process.stderr.write(
    `  ${u.file}:${String(u.line)}  var(${u.token})  (defined nowhere, no fallback)\n`,
  );
}
process.stderr.write(
  '\nFix: reference a real token from tokens.generated.css, or supply a fallback value.\n',
);
process.exit(1);
