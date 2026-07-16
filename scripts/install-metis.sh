#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage: install-metis.sh --target PATH [--skill NAME] [--harness NAME] [--force]

Skills: all, craft-agent-prompt, design-tool-workflow, handoff,
        manage-long-workflow, orca-fleet, run-long-job
Harnesses: all, codex, claude, opencode

Install Metis skills as project-local configuration in another repository.
By default, install every skill for every supported coding-agent harness.
Existing destination files are preserved unless --force is supplied.
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

if [ "$skill" = "all" ] || [ "$skill" = "orca-fleet" ]; then
  files="$files
skills/orca-fleet/SKILL.md
skills/orca-fleet/AGENTS.md"
fi

if [ "$skill" = "all" ] || [ "$skill" = "handoff" ]; then
  files="$files
skills/handoff/SKILL.md
skills/handoff/agents/openai.yaml"
fi

if [ "$skill" = "all" ] || [ "$skill" = "run-long-job" ]; then
  files="$files
skills/run-long-job/SKILL.md
skills/run-long-job/agents/openai.yaml
skills/run-long-job/scripts/long_job.py"
fi

if [ "$skill" = "all" ] || [ "$skill" = "craft-agent-prompt" ]; then
  files="$files
skills/craft-agent-prompt/SKILL.md
skills/craft-agent-prompt/agents/openai.yaml"
fi

if [ "$skill" = "all" ] || [ "$skill" = "design-tool-workflow" ]; then
  files="$files
skills/design-tool-workflow/SKILL.md
skills/design-tool-workflow/agents/openai.yaml"
fi

if [ "$skill" = "all" ] || [ "$skill" = "manage-long-workflow" ]; then
  files="$files
skills/manage-long-workflow/SKILL.md
skills/manage-long-workflow/agents/openai.yaml"
fi

if [ "$harness" = "all" ] || [ "$harness" = "codex" ] || [ "$harness" = "opencode" ]; then
  if [ "$skill" = "all" ] || [ "$skill" = "orca-fleet" ]; then
    files="$files
.agents/skills/orca-fleet/SKILL.md"
  fi
  if [ "$skill" = "all" ] || [ "$skill" = "handoff" ]; then
    files="$files
.agents/skills/handoff/SKILL.md"
  fi
  if [ "$skill" = "all" ] || [ "$skill" = "run-long-job" ]; then
    files="$files
.agents/skills/run-long-job/SKILL.md"
  fi
  if [ "$skill" = "all" ] || [ "$skill" = "craft-agent-prompt" ]; then
    files="$files
.agents/skills/craft-agent-prompt/SKILL.md"
  fi
  if [ "$skill" = "all" ] || [ "$skill" = "design-tool-workflow" ]; then
    files="$files
.agents/skills/design-tool-workflow/SKILL.md"
  fi
  if [ "$skill" = "all" ] || [ "$skill" = "manage-long-workflow" ]; then
    files="$files
.agents/skills/manage-long-workflow/SKILL.md"
  fi
fi

if { [ "$harness" = "all" ] || [ "$harness" = "codex" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "orca-fleet" ]; }; then
  files="$files
.codex/agents/orca-fleet-explorer.toml
.codex/agents/orca-fleet-general-executor.toml
.codex/agents/orca-fleet-hard-executor.toml
.codex/agents/orca-fleet-evaluator.toml"
fi

if [ "$harness" = "all" ] || [ "$harness" = "claude" ]; then
  if [ "$skill" = "all" ] || [ "$skill" = "orca-fleet" ]; then
    files="$files
.claude/skills/orca-fleet/SKILL.md
.claude/agents/orca-fleet-explorer.md
.claude/agents/orca-fleet-general-executor.md
.claude/agents/orca-fleet-hard-executor.md
.claude/agents/orca-fleet-evaluator.md"
  fi
  if [ "$skill" = "all" ] || [ "$skill" = "handoff" ]; then
    files="$files
.claude/skills/handoff/SKILL.md"
  fi
  if [ "$skill" = "all" ] || [ "$skill" = "run-long-job" ]; then
    files="$files
.claude/skills/run-long-job/SKILL.md"
  fi
  if [ "$skill" = "all" ] || [ "$skill" = "craft-agent-prompt" ]; then
    files="$files
.claude/skills/craft-agent-prompt/SKILL.md"
  fi
  if [ "$skill" = "all" ] || [ "$skill" = "design-tool-workflow" ]; then
    files="$files
.claude/skills/design-tool-workflow/SKILL.md"
  fi
  if [ "$skill" = "all" ] || [ "$skill" = "manage-long-workflow" ]; then
    files="$files
.claude/skills/manage-long-workflow/SKILL.md"
  fi
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "orca-fleet" ]; }; then
  files="$files
.opencode/agents/orca-fleet.md
.opencode/agents/orca-fleet-explorer.md
.opencode/agents/orca-fleet-general-executor.md
.opencode/agents/orca-fleet-hard-executor.md
.opencode/agents/orca-fleet-evaluator.md
.opencode/commands/orca-fleet.md"
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "handoff" ]; }; then
  files="$files
.opencode/commands/handoff.md"
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "run-long-job" ]; }; then
  files="$files
.opencode/commands/run-long-job.md"
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "craft-agent-prompt" ]; }; then
  files="$files
.opencode/commands/craft-agent-prompt.md"
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "design-tool-workflow" ]; }; then
  files="$files
.opencode/commands/design-tool-workflow.md"
fi

if { [ "$harness" = "all" ] || [ "$harness" = "opencode" ]; } && { [ "$skill" = "all" ] || [ "$skill" = "manage-long-workflow" ]; }; then
  files="$files
.opencode/commands/manage-long-workflow.md"
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

printf 'Installed %s Metis files for skill=%s harness=%s into %s\n' "$count" "$skill" "$harness" "$target"
