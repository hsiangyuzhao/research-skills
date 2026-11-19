#!/bin/sh
# SessionStart hook (matcher: compact). Re-injects the Macro frame and the
# Current micro story from NARRATIVE.md after context compaction. Plain stdout
# from a SessionStart hook is added to the context (capped at 10,000 characters).

file="${CLAUDE_PROJECT_DIR:-.}/NARRATIVE.md"
[ -f "$file" ] || exit 0

echo "Research narrative, re-injected after context compaction from NARRATIVE.md. Earlier micro stories are in that file. The research-narrative skill applies."
echo

# Print each section verbatim, from its heading up to the next "## " heading.
# Prints a one-line note for any section that is absent.
awk '
  function note(name) { printf "(NARRATIVE.md has no \"%s\" section.)\n\n", name }
  /^## / {
    cur = ""
    if ($0 ~ /^## Macro frame/) { cur = "macro"; seen_macro = 1 }
    else if ($0 ~ /^## Current micro story/) { cur = "micro"; seen_micro = 1 }
  }
  cur != "" { print }
  END {
    if (!seen_macro) note("## Macro frame")
    if (!seen_micro) note("## Current micro story")
  }
' "$file"
