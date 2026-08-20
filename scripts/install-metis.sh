#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage: install-metis.sh --target PATH [--plugin NAME] [--skill NAME] [--harness NAME] [--force]

Plugins: metis-prelude, metis-prelude-zh,
         metis-context-ledger, metis-context-ledger-zh
Skills: all, or any skill in the selected plugin
Harnesses: all, codex, claude, opencode2

Install one Metis plugin as project-local harness configuration. Complete
skill directories are copied into each harness's discovery path. Orca Fleet
provider definitions and Context Ledger's export runtime are included when
their corresponding skills are selected. Existing destination files are
preserved unless --force is supplied.
EOF
}

target=""
plugin="metis-prelude"
skill="all"
harness="all"
force=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      target=$2
      shift 2
      ;;
    --plugin)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      plugin=$2
      shift 2
      ;;
    --skill)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      skill=$2
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

case "$plugin" in
  metis-prelude|metis-prelude-zh|metis-context-ledger|metis-context-ledger-zh) ;;
  *)
    printf 'Unsupported plugin: %s\n' "$plugin" >&2
    usage >&2
    exit 2
    ;;
esac

case "$harness" in
  all|codex|claude|opencode2) ;;
  *)
    printf 'Unsupported harness: %s\n' "$harness" >&2
    usage >&2
    exit 2
    ;;
esac

source_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
plugin_skill_root="$source_root/plugins/$plugin/skills"

if [ "$skill" != "all" ] && [ ! -f "$plugin_skill_root/$skill/SKILL.md" ]; then
  printf 'Unsupported skill for %s: %s\n' "$plugin" "$skill" >&2
  usage >&2
  exit 2
fi

files=""

add_file() {
  files="$files
$1|$2"
}

skill_mappings() {
  selected_skill=$1

  find "$plugin_skill_root/$selected_skill" -type f | sort | while IFS= read -r source_path; do
    source_relative=${source_path#"$source_root/"}
    skill_relative=${source_path#"$plugin_skill_root/"}

    case "$harness" in
      all|codex)
        printf '%s|%s\n' "$source_relative" ".agents/skills/$skill_relative"
        ;;
    esac
    case "$harness" in
      all|claude)
        printf '%s|%s\n' "$source_relative" ".claude/skills/$skill_relative"
        ;;
    esac
    case "$harness" in
      all|opencode2)
        printf '%s|%s\n' "$source_relative" ".opencode/skills/$skill_relative"
        ;;
    esac
  done
}

if [ "$skill" = "all" ]; then
  selected_skills=$(find "$plugin_skill_root" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
else
  selected_skills=$skill
fi

for selected_skill in $selected_skills; do
  selected_mappings=$(skill_mappings "$selected_skill")
  files="$files
$selected_mappings"
done

case "$plugin" in
  metis-prelude|metis-prelude-zh)
    if [ "$skill" = "all" ] || [ "$skill" = "orca-fleet" ]; then
      case "$harness" in
        all|codex)
          for source_path in "$source_root"/agents/codex/agents/*; do
            add_file "${source_path#"$source_root/"}" ".codex/agents/$(basename -- "$source_path")"
          done
          ;;
      esac
      case "$harness" in
        all|claude)
          for source_path in "$source_root"/agents/claude/agents/*; do
            add_file "${source_path#"$source_root/"}" ".claude/agents/$(basename -- "$source_path")"
          done
          ;;
      esac
      case "$harness" in
        all|opencode2)
          for source_path in "$source_root"/agents/opencode2/agents/*; do
            add_file "${source_path#"$source_root/"}" ".opencode/agents/$(basename -- "$source_path")"
          done
          add_file agents/opencode2/commands/orca-fleet.md .opencode/commands/orca-fleet.md
          ;;
      esac
    fi
    ;;
esac

case "$plugin" in
  metis-context-ledger|metis-context-ledger-zh)
    if [ "$skill" = "all" ] || [ "$skill" = "export" ]; then
      case "$harness" in
        all|codex)
          add_file "plugins/$plugin/scripts/export_context.py" .agents/scripts/export_context.py
          ;;
      esac
      case "$harness" in
        all|claude)
          add_file "plugins/$plugin/scripts/export_context.py" .claude/scripts/export_context.py
          ;;
      esac
      case "$harness" in
        all|opencode2)
          add_file "plugins/$plugin/scripts/export_context.py" .opencode/scripts/export_context.py
          ;;
      esac
    fi
    ;;
esac

if [ "$force" -eq 0 ]; then
  conflicts=""
  for file_mapping in $files; do
    destination_relative=${file_mapping#*|}
    if [ -e "$target/$destination_relative" ]; then
      conflicts="$conflicts
$destination_relative"
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
for file_mapping in $files; do
  source_relative=${file_mapping%%|*}
  destination_relative=${file_mapping#*|}
  source_path="$source_root/$source_relative"
  destination_path="$target/$destination_relative"

  [ -f "$source_path" ] || { printf 'Missing source file: %s\n' "$source_path" >&2; exit 1; }
  mkdir -p "$(dirname -- "$destination_path")"
  cp -f "$source_path" "$destination_path"
  count=$((count + 1))
done

printf 'Installed %s Metis files for plugin=%s skill=%s harness=%s into %s\n' \
  "$count" "$plugin" "$skill" "$harness" "$target"
