#!/usr/bin/env bash
# PostToolUse hook: format files Claude just edited with Prettier.
# Quiet on success. Never blocks the tool — exits 0 even on failure.
# Scoped to Prettier only — lint --fix / stylelint:fix stay manual or pre-commit
# because they're slow and project-context-aware.

set -u

# Hook contract: tool input arrives on stdin as JSON; pull file_path out.
input="$(cat || true)"
[ -z "$input" ] && exit 0

file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
[ -z "$file_path" ] && exit 0

# Only run inside the project directory.
project_dir="${CLAUDE_PROJECT_DIR:-/Users/kkucherenkov/project/petProjets/coriolis_app}"
case "$file_path" in
  "$project_dir"/*) ;;
  *) exit 0 ;;
esac

# Extension allowlist — match what Prettier in this repo handles.
case "$file_path" in
  *.ts|*.tsx|*.vue|*.js|*.mjs|*.cjs|*.json|*.jsonc|*.md|*.mdx|*.scss|*.css|*.yaml|*.yml|*.html) ;;
  *) exit 0 ;;
esac

# Skip generated/ignored paths even if Prettier would touch them.
case "$file_path" in
  */generated/*|*/.generated.*|*node_modules*|*/dist/*|*/.nuxt/*|*/.output/*) exit 0 ;;
esac

cd "$project_dir" 2>/dev/null || exit 0
pnpm prettier --write --log-level=warn "$file_path" >/dev/null 2>&1 || true
exit 0
