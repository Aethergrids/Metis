#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage: install-orca-fleet.sh --target PATH [--harness all|codex|claude|opencode] [--force]

Install Orca Fleet as project-local configuration in another repository.
Existing destination files are preserved unless --force is supplied.
EOF
}

target=""
harness="all"
force=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      target=$2
      shift 2
      ;;
    --harness)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      harness=$2
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[ -n "$target" ] || { printf '%s\n' 'Missing required --target PATH.' >&2; usage >&2; exit 2; }
[ -d "$target" ] || { printf 'Target directory does not exist: %s\n' "$target" >&2; exit 2; }

case "$harness" in
  all|codex|claude|opencode) ;;
  *)
    printf 'Unsupported harness: %s\n' "$harness" >&2
    usage >&2
    exit 2
    ;;
esac

source_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

files='skills/orca-fleet/SKILL.md
skills/orca-fleet/AGENTS.md'

if [ "$harness" = "all" ] || [ "$harness" = "codex" ] || [ "$harness" = "opencode" ]; then
  files="$files
.agents/skills/orca-fleet/SKILL.md"
fi

if [ "$harness" = "all" ] || [ "$harness" = "codex" ]; then
  files="$files
.codex/agents/orca-fleet-explorer.toml
.codex/agents/orca-fleet-general-executor.toml
.codex/agents/orca-fleet-hard-executor.toml
.codex/agents/orca-fleet-evaluator.toml"
fi

if [ "$harness" = "all" ] || [ "$harness" = "claude" ]; then
  files="$files
.claude/skills/orca-fleet/SKILL.md
.claude/agents/orca-fleet-explorer.md
.claude/agents/orca-fleet-general-executor.md
.claude/agents/orca-fleet-hard-executor.md
.claude/agents/orca-fleet-evaluator.md"
fi

if [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; then
  files="$files
.opencode/agents/orca-fleet.md
.opencode/agents/orca-fleet-explorer.md
.opencode/agents/orca-fleet-general-executor.md
.opencode/agents/orca-fleet-hard-executor.md
.opencode/agents/orca-fleet-evaluator.md
.opencode/commands/orca-fleet.md"
fi

if [ "$force" -eq 0 ]; then
  conflicts=""
  for relative_path in $files; do
    if [ -e "$target/$relative_path" ]; then
      conflicts="$conflicts
$relative_path"
    fi
  done

  if [ -n "$conflicts" ]; then
    printf '%s\n' 'Refusing to overwrite existing files:' >&2
    printf '%s\n' "$conflicts" >&2
    printf '%s\n' 'Re-run with --force to replace them.' >&2
    exit 1
  fi
fi

count=0
for relative_path in $files; do
  source_path="$source_root/$relative_path"
  destination_path="$target/$relative_path"

  [ -f "$source_path" ] || { printf 'Missing source file: %s\n' "$source_path" >&2; exit 1; }
  mkdir -p "$(dirname -- "$destination_path")"
  cp -f "$source_path" "$destination_path"
  count=$((count + 1))
done

printf 'Installed %s Orca Fleet files for %s into %s\n' "$count" "$harness" "$target"
