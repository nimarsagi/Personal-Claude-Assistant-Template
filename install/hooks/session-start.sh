#!/bin/bash
# session-start.sh — boot-context injection (post-Phase-5 hardening,
# see ROADMAP.md).
#
# Wired into ~/.claude/settings.json's SessionStart event by the hook
# section of INSTALL.md. Whatever this script prints to stdout is added
# to the new session's opening context by Claude Code — so the user
# model, global memory, and boot status arrive as DATA pushed into the
# session, not as an instruction to go read files, which a task-heavy
# first message can outrace.
#
# Read-only by design: this script writes nothing, calls no model, and
# must stay fast — it runs synchronously at every session start.

set -u

# Harden PATH before running anything else. This hook runs at the start of
# every session, in whatever directory the session opened — which may be an
# untrusted repo whose inherited PATH prepends a hostile `grep`, `find`,
# `python3`, or coreutil. Pin to trusted OS locations first so nothing on a
# session/repo-controlled path can shadow the tools used below.
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin:$HOME/.npm-global/bin"

ASSISTANT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Never inject into helper sessions spawned by the session-end hook
# (belt-and-braces: those also run with all hooks disabled).
[ -n "${MY_CLAUDE_ASSISTANT_JOURNALER:-}" ] && exit 0

# Same live-install guard as session-end.sh: inject only as the
# installed assistant — the path named in ~/.claude/CLAUDE.md's pointer
# block, written absolute or ~-relative. A source/dev checkout stays
# silent.
if ! grep -Fq "$ASSISTANT_DIR" "$HOME/.claude/CLAUDE.md" 2>/dev/null \
   && ! grep -Fq "~${ASSISTANT_DIR#"$HOME"}" "$HOME/.claude/CLAUDE.md" 2>/dev/null; then
  exit 0
fi

echo "=== My Claude Assistant — boot context (injected by the session-start hook) ==="
echo "Source: $ASSISTANT_DIR — its CLAUDE.md is the boot protocol and governs"
echo "all memory writes. The files below are the boot read; act on any"
echo "STATUS lines per that protocol."
echo

if [ -f "$ASSISTANT_DIR/SETUP.md" ]; then
  echo "STATUS: first-run setup is PENDING (SETUP.md exists)."
  echo
fi

echo "--- USER.md ---"
cat "$ASSISTANT_DIR/USER.md" 2>/dev/null || echo "(missing)"
echo
echo "--- memory/MEMORY.md ---"
cat "$ASSISTANT_DIR/memory/MEMORY.md" 2>/dev/null || echo "(missing)"
echo

# Pending proposals: anything in the inbox besides its own README.
PENDING="$(find "$ASSISTANT_DIR/memory/proposals" -type f ! -name 'README*' ! -name '.*' 2>/dev/null | wc -l | tr -d ' ')"
if [ "${PENDING:-0}" -gt 0 ]; then
  echo "STATUS: $PENDING pending proposal(s) in memory/proposals/ — mention in"
  echo "one line at your first reply; act on them only if asked."
fi

# Consolidation freshness: age of the newest dated line in the log.
LOG="$ASSISTANT_DIR/memory/consolidation-log.md"
LAST_DATE="$(grep -Eo '^[0-9]{4}-[0-9]{2}-[0-9]{2}' "$LOG" 2>/dev/null | tail -1)"
if [ -z "$LAST_DATE" ]; then
  # No dated line means one of two things, and the log alone can't tell
  # them apart: nothing has been consolidated yet, or the log got mangled
  # (a gardener entry that wrapped and left the last physical line
  # undated has done exactly this). Only nudge when there is something to
  # consolidate — a fresh install has no journal entries, so opening a
  # first-ever session with an impossible chore is noise. Once entries
  # exist, an unreadable log still shouts, which is the case the branch
  # was written for.
  if find "$ASSISTANT_DIR/memory/journal" -type f -path '*/sessions/*' \
          -name '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md' 2>/dev/null \
       | grep -q .; then
    echo "STATUS: no consolidation run recorded yet — mention in one line that"
    echo "memory consolidation is overdue; never run it unprompted."
  fi
else
  NOW_S="$(date +%s)"
  # macOS (BSD date) first, GNU date as fallback.
  LAST_S="$(date -j -f %Y-%m-%d "$LAST_DATE" +%s 2>/dev/null || date -d "$LAST_DATE" +%s 2>/dev/null || echo "$NOW_S")"
  AGE_DAYS=$(( (NOW_S - LAST_S) / 86400 ))
  if [ "$AGE_DAYS" -gt 7 ]; then
    echo "STATUS: last consolidation was $LAST_DATE ($AGE_DAYS days ago) — mention"
    echo "in one line that it's overdue; never run it unprompted."
  fi
fi

echo
echo "Journal files load on demand only — do not read them now."
echo "=== end of injected boot context ==="
exit 0
