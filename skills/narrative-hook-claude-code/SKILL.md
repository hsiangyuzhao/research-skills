---
name: narrative-hook-claude-code
description: "Install a Claude Code hook that re-injects the Macro frame and Current micro story from NARRATIVE.md into the context after every automatic or manual compaction."
disable-model-invocation: true
---

# Setup Narrative Hook

Sets up a SessionStart hook with the `compact` matcher. After Claude Code compacts the context, the hook reads `NARRATIVE.md` at the project root and prints its `## Macro frame` and `## Current micro story` sections, which Claude Code adds to the new context. The hook is deterministic: the research gap and the confirmed micro story come back verbatim from the file, whatever the compaction summary kept or dropped. See the `research-narrative` skill for the file and its sections. Earlier micro stories stay in the file and are not injected.

If `NARRATIVE.md` is missing, the hook prints nothing. If a section is missing, it prints the other one and a one-line note naming the missing section.

This is Claude Code only. Codex and other harnesses have no equivalent hook; configure them separately.

## Steps

### 1. Ask scope

Ask the user: install for **this project only** (`.claude/settings.json`) or **all projects** (`~/.claude/settings.json`)? The hook reads `$CLAUDE_PROJECT_DIR/NARRATIVE.md` (the current directory if the variable is unset), so a global install does nothing in projects without that file.

### 2. Copy the hook script

The bundled script is at: [scripts/inject-narrative.sh](scripts/inject-narrative.sh)

Copy it to the target location based on scope:

- **Project**: `.claude/hooks/inject-narrative.sh`
- **Global**: `~/.claude/hooks/inject-narrative.sh`

Make it executable with `chmod +x`. It needs only `sh` and `awk`.

### 3. Add hook to settings

**Project** (`.claude/settings.json`):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/inject-narrative.sh"
          }
        ]
      }
    ]
  }
}
```

**Global** (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/inject-narrative.sh"
          }
        ]
      }
    ]
  }
}
```

If the settings file already exists, merge the hook into the existing `hooks.SessionStart` array. Don't overwrite other settings.

### 4. Verify

Run the installed script against the project's file:

```bash
CLAUDE_PROJECT_DIR=<project> <path-to-script>; echo "exit $?"
```

It must print the header line, the Macro frame and the Current micro story, and exit 0. In a directory without `NARRATIVE.md` it must print nothing and exit 0.

Then tell the user to check it in a real session: run `/compact`, then ask Claude to quote the macro frame it was given after compaction. The output is capped by Claude Code at 10,000 characters of plain stdout, so keep the two sections short.
