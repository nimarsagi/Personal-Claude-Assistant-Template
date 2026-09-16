#!/bin/bash
# standing-rules.sh — puts the user's hard guardrails in front of Claude
# while it is writing, not only at session start.
#
# Wired into ~/.claude/settings.json's UserPromptSubmit event by the hook
# section of INSTALL.md. Whatever this prints as additionalContext is added
# to the turn Claude is about to answer. USER.md holds the full rules; this
# is the one-sentence form, and it MUST stay short or it becomes wallpaper
# Claude reads past.
#
# The reminder text lives in standing-rules.txt, NOT in this script:
# SETUP.md writes that file from the user's own interview answers (the
# preferences they tagged [hard guardrail]), and only the user changes it
# afterwards. Keeping text and logic apart means a guardrail containing a
# quote or a backslash can't break this hook's JSON.
#
# Read-only, model-free, and silent until setup has written the text file —
# an unpersonalized install injects nothing.

set -u

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin"

ASSISTANT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RULES_FILE="$ASSISTANT_DIR/install/hooks/standing-rules.txt"

# Never inject into helper sessions spawned by the session-end hook.
[ -n "${MY_CLAUDE_ASSISTANT_JOURNALER:-}" ] && exit 0

# Same live-install guard as the other two hooks: a source/dev checkout
# stays silent.
if ! grep -Fq "$ASSISTANT_DIR" "$HOME/.claude/CLAUDE.md" 2>/dev/null \
   && ! grep -Fq "~${ASSISTANT_DIR#"$HOME"}" "$HOME/.claude/CLAUDE.md" 2>/dev/null; then
  exit 0
fi

[ -f "$RULES_FILE" ] || exit 0

# Drop comment lines and blank lines, join the rest onto one line.
TEXT="$(grep -v '^[[:space:]]*#' "$RULES_FILE" 2>/dev/null \
        | tr '\n' ' ' | tr -s ' ' | sed 's/^ *//;s/ *$//')"
[ -n "$TEXT" ] || exit 0

# Escape for JSON: backslashes first, then double quotes. Control
# characters are already gone — the tr above flattened every newline.
TEXT="${TEXT//\\/\\\\}"
TEXT="${TEXT//\"/\\\"}"

cat <<JSON
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "$TEXT"
  },
  "suppressOutput": true
}
JSON
exit 0
