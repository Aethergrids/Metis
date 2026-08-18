#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage: install-metis.sh --target PATH [--skill NAME] [--harness NAME] [--force]

Skills: all, craft-agent-prompt, design-tool-workflow, handoff,
        manage-long-workflow, orca-fleet, run-long-job
Harnesses: all, codex, claude, opencode

Install Metis skills and provider adapters as project-local configuration.
Canonical English skills are copied from plugins/metis-prelude/skills/ into
each harness's discovery path; provider definitions are copied from agents/
into the matching harness path. Existing destination files are preserved
unless --force is supplied.
EOF
}

target=""
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

case "$skill" in
  all|craft-agent-prompt|design-tool-workflow|handoff|manage-long-workflow|orca-fleet|run-long-job) ;;
  *)
    printf 'Unsupported skill: %s\n' "$skill" >&2
    usage >&2
    exit 2
    ;;
esac

case "$harness" in
  all|codex|claude|opencode) ;;
  *)
    printf 'Unsupported harness: %s\n' "$harness" >&2
    usage >&2
    exit 2
    ;;
esac

source_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
files=""

add_file() {
  files="$files
$1|$2"
}

add_skill_files() {
  skill_name=$1
  shift

  for skill_file do
    source_file="plugins/metis-prelude/skills/$skill_name/$skill_file"

    case "$harness" in
      all|codex|opencode)
        add_file "$source_file" ".agents/skills/$skill_name/$skill_file"
        ;;
    esac

    case "$harness" in
      all|claude)
        add_file "$source_file" ".claude/skills/$skill_name/$skill_file"
        ;;
    esac
  done
}

if [ "$skill" = "all" ] || [ "$skill" = "orca-fleet" ]; then
  add_skill_files orca-fleet SKILL.md AGENTS.md
fi

if [ "$skill" = "all" ] || [ "$skill" = "handoff" ]; then
  add_skill_files handoff SKILL.md agents/openai.yaml
fi

if [ "$skill" = "all" ] || [ "$skill" = "run-long-job" ]; then
  add_skill_files run-long-job SKILL.md agents/openai.yaml scripts/long_job.py
fi

if [ "$skill" = "all" ] || [ "$skill" = "craft-agent-prompt" ]; then
  add_skill_files craft-agent-prompt SKILL.md agents/openai.yaml
fi

if [ "$skill" = "all" ] || [ "$skill" = "design-tool-workflow" ]; then
  add_skill_files design-tool-workflow SKILL.md agents/openai.yaml
fi

if [ "$skill" = "all" ] || [ "$skill" = "manage-long-workflow" ]; then
  add_skill_files manage-long-workflow SKILL.md agents/openai.yaml
fi

if { [ "$harness" = "all" ] || [ "$harness" = "codex" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "orca-fleet" ]; }; then
  add_file agents/codex/agents/orca-fleet-explorer.toml .codex/agents/orca-fleet-explorer.toml
  add_file agents/codex/agents/orca-fleet-general-executor.toml .codex/agents/orca-fleet-general-executor.toml
  add_file agents/codex/agents/orca-fleet-hard-executor.toml .codex/agents/orca-fleet-hard-executor.toml
  add_file agents/codex/agents/orca-fleet-evaluator.toml .codex/agents/orca-fleet-evaluator.toml
fi

if { [ "$harness" = "all" ] || [ "$harness" = "claude" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "orca-fleet" ]; }; then
  add_file agents/claude/agents/orca-fleet-explorer.md .claude/agents/orca-fleet-explorer.md
  add_file agents/claude/agents/orca-fleet-general-executor.md .claude/agents/orca-fleet-general-executor.md
  add_file agents/claude/agents/orca-fleet-hard-executor.md .claude/agents/orca-fleet-hard-executor.md
  add_file agents/claude/agents/orca-fleet-evaluator.md .claude/agents/orca-fleet-evaluator.md
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "orca-fleet" ]; }; then
  add_file agents/opencode/agents/orca-fleet.md .opencode/agents/orca-fleet.md
  add_file agents/opencode/agents/orca-fleet-explorer.md .opencode/agents/orca-fleet-explorer.md
  add_file agents/opencode/agents/orca-fleet-general-executor.md .opencode/agents/orca-fleet-general-executor.md
  add_file agents/opencode/agents/orca-fleet-hard-executor.md .opencode/agents/orca-fleet-hard-executor.md
  add_file agents/opencode/agents/orca-fleet-evaluator.md .opencode/agents/orca-fleet-evaluator.md
  add_file agents/opencode/commands/orca-fleet.md .opencode/commands/orca-fleet.md
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "handoff" ]; }; then
  add_file agents/opencode/commands/handoff.md .opencode/commands/handoff.md
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "run-long-job" ]; }; then
  add_file agents/opencode/commands/run-long-job.md .opencode/commands/run-long-job.md
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "craft-agent-prompt" ]; }; then
  add_file agents/opencode/commands/craft-agent-prompt.md .opencode/commands/craft-agent-prompt.md
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "design-tool-workflow" ]; }; then
  add_file agents/opencode/commands/design-tool-workflow.md .opencode/commands/design-tool-workflow.md
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "manage-long-workflow" ]; }; then
  add_file agents/opencode/commands/manage-long-workflow.md .opencode/commands/manage-long-workflow.md
fi

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

printf 'Installed %s Metis files for skill=%s harness=%s into %s\n' "$count" "$skill" "$harness" "$target"
