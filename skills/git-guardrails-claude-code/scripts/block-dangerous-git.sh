#!/bin/bash
# PreToolUse hook for Claude Code: git commands whose damage cannot be undone
# are escalated to the user for approval instead of running silently.
# Reads the hook payload on stdin; prints a permission decision on stdout.
# Requires jq.

# Fail closed: without jq the command cannot be inspected, so ask the user.
if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"jq is missing, so the git guardrail cannot inspect this command. Approve only if it is safe, or install jq."}}'
  exit 0
fi

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

S='[[:space:]]'
# "git", optionally followed by global options: -C <dir>, -c k=v, long options
# with a separate-word value (--git-dir x), or any other option such as
# --no-pager, -P, --git-dir=x
GIT="(^|[^[:alnum:]_-])git($S+-[Cc]$S+[^[:space:]]+|$S+--(git-dir|work-tree|namespace|super-prefix|config-env|exec-path)$S+[^[:space:]]+|$S+-[^[:space:]]*)*$S+"

ask() {
  jq -n --arg reason "Irreversible git operation ($1): $2 Approve only if that is intended." '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

has() { printf '%s' "$COMMAND" | grep -qE -- "$1"; }

# Deleting untracked files (results, checkpoints, data caches). Dry runs are fine,
# but each git clean invocation is judged on its own: the command is split at
# ;, & and | and newlines, and a -n/--dry-run in one segment exempts only that one.
while IFS= read -r SEGMENT; do
  printf '%s' "$SEGMENT" | grep -qE -- "${GIT}clean" || continue
  printf '%s' "$SEGMENT" | grep -qE -- "($S-[[:alpha:]]*n|--dry-run)" ||
    ask "git clean" "untracked files are deleted and git has no copy of them."
done <<< "$(printf '%s' "$COMMAND" | tr ';&|' '\n\n\n')"

# Discarding uncommitted changes
has "${GIT}reset$S+.*--hard" &&
  ask "git reset --hard" "uncommitted changes to tracked files are discarded."
has "${GIT}checkout$S+(.*$S)?--($S|$)" &&
  ask "git checkout -- <paths>" "uncommitted changes to those paths are discarded."
has "${GIT}checkout$S+\.($S|$)" &&
  ask "git checkout ." "all uncommitted changes in this directory are discarded."
if has "${GIT}restore"; then
  has "${GIT}restore.*($S--worktree|$S-W)" &&
    ask "git restore --worktree" "uncommitted changes to those paths are discarded."
  has "${GIT}restore.*($S--staged|$S-S)" ||
    ask "git restore <paths>" "uncommitted changes to those paths are discarded."
fi
has "${GIT}stash$S+(drop|clear)" &&
  ask "git stash drop/clear" "the stashed changes are deleted."

# Rewriting published history
has "${GIT}push.*$S(--force|-[[:alpha:]]*f|\+[^[:space:]]+)" &&
  ask "force push" "commits on the remote can be overwritten for everyone."

exit 0
