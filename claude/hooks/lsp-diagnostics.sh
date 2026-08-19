#!/bin/bash
# PostToolUse hook: run Python diagnostics on the just-edited file, mirroring the
# ruff + basedpyright engines behind the nvim LSP. On errors/warnings, exit 2 with
# the diagnostics on stderr so Claude is forced to fix them at the source instead
# of surfacing them later at commit/push time.
#
# Python-only by design: Elixir (Expert) has no per-file headless diagnostics CLI,
# so it stays on the existing Stop-time mix checks (lint-on-stop.sh).

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // empty')
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only react to file-writing tools
case "$tool_name" in
    Edit|Write|MultiEdit) ;;
    *) exit 0 ;;
esac

# Only Python files
[ -n "$file" ] || exit 0
[[ "$file" == *.py ]] || exit 0
[ -f "$file" ] || exit 0

# uv drives the project toolchain (ruff/basedpyright live in the venv, not on PATH).
# If uv isn't available, no-op rather than block.
command -v uv >/dev/null 2>&1 || exit 0

# Run from the project root so uv resolves the correct environment.
cd "${CLAUDE_PROJECT_DIR:-$(dirname "$file")}" || exit 0

output=""
has_issues=false

# A tool that isn't installed in the project env makes `uv run` fail to spawn it.
# Treat that as "not configured for this project" and skip it silently rather than
# blocking with tooling noise.
tool_unavailable() {
    echo "$1" | grep -Eq 'Failed to spawn|No such file or directory \(os error 2\)'
}

# ruff: any lint finding produces a non-zero exit.
ruff_out=$(uv run ruff check "$file" 2>&1)
ruff_exit=$?
if ! tool_unavailable "$ruff_out" && [ $ruff_exit -ne 0 ]; then
    output+="=== ruff check ===\n${ruff_out}\n\n"
    has_issues=true
fi

# basedpyright: non-zero exit on errors. It exits 0 when there are only warnings,
# so also inspect the summary line to surface warnings (e.g. "2 warnings").
pyright_out=$(uv run basedpyright "$file" 2>&1)
pyright_exit=$?
if ! tool_unavailable "$pyright_out"; then
    if [ $pyright_exit -ne 0 ] || echo "$pyright_out" | grep -Eq '[1-9][0-9]* warning'; then
        output+="=== basedpyright ===\n${pyright_out}\n\n"
        has_issues=true
    fi
fi

if [ "$has_issues" = true ]; then
    echo -e "LSP diagnostics in ${file} \xE2\x80\x94 fix these before continuing:\n\n${output}" >&2
    exit 2
fi

exit 0
