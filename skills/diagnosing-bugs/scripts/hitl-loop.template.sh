#!/usr/bin/env bash
# Human-in-the-loop reproduction loop.
# Copy this file, edit the steps below, and run it.
# The user runs the script in their own terminal and pastes the output back
# to the agent. It reads from the keyboard, so the agent cannot run it.
#
# Usage:
#   bash hitl-loop.template.sh
#
# Two helpers:
#   step "<instruction>"          → show instruction, wait for Enter
#   capture VAR "<question>"      → show question, read response into VAR
#
# At the end, captured values are printed as KEY=VALUE for the agent to parse.
#
# Captured values end up in the output the user pastes back, so capture
# observations only, never passwords; leave signing in to the user as a `step`.

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter when done] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- edit below ---------------------------------------------------------

step "Open outputs/debug/case_017_overlay.png (predicted mask over the image)."

capture MASK_OK "Does the predicted mask sit on the lesion? (y/n)"

capture OFFSET "If not, roughly how far off and in which direction (or 'none'):"

# --- edit above ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'MASK_OK=%s\n' "$MASK_OK"
printf 'OFFSET=%s\n' "$OFFSET"
