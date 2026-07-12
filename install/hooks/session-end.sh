#!/bin/bash
# session-end.sh — Phase 2 background journaling (see ROADMAP.md).
#
# Wired into ~/.claude/settings.json by the hook-install section of
# INSTALL.md; fires when any Claude Code session ends, in any folder.
# It does two things, both in a detached worker so session exit never
# waits on it:
#   1. Auto-commits anything uncommitted in the assistant folder — the
#      harness-enforced version of "commit after memory writes".
#   2. Feeds the session transcript to a cheap headless Claude run that
#      drafts a journal-entry proposal into memory/proposals/.
# It writes PROPOSALS ONLY — never MEMORY.md, USER.md, or journal files.
# The user approves or rejects at the next boot ("review proposals").
#
# Needs bash + python3 + git + the claude CLI on PATH. Activity is logged
# to .hook.log in the assistant folder (gitignored).

set -u

ASSISTANT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG="$ASSISTANT_DIR/.hook.log"

log() { printf '%s  %s\n' "$(date '+%F %T')" "$*" >> "$LOG" 2>/dev/null || true; }

# ---------- Phase A: invoked by Claude Code — must return instantly ----------
if [ "${1:-}" != "--detached" ]; then
  # Loop guard: never process a session this script itself spawned.
  # (CLAUDE_CODE_CHILD_SESSION can't be used here: Claude Code sets it
  # for ALL its subprocesses, including this hook in a top-level session.)
  [ -n "${MY_CLAUDE_ASSISTANT_JOURNALER:-}" ] && exit 0

  INPUT_FILE="$(mktemp "${TMPDIR:-/tmp}/session-end-hook.XXXXXX")" || exit 0
  cat > "$INPUT_FILE"

  # Only interactive sessions get journaled. Headless (`claude -p`) runs
  # end with reason=prompt_input_exit — that covers the summarizer below
  # (second loop guard) and any scripted helper sessions. A session
  # resumed in another window ends here but continues there — logging it
  # now would double-log it later.
  REASON="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("reason",""))' "$INPUT_FILE" 2>/dev/null || true)"
  case "$REASON" in
    prompt_input_exit|resume) rm -f "$INPUT_FILE"; exit 0 ;;
  esac

  # Same guard as the boot protocol: run only as the installed live
  # assistant — the path named in ~/.claude/CLAUDE.md's pointer block,
  # which may be written absolute or ~-relative. A source/dev checkout
  # of the template must never commit or write here.
  if ! grep -Fq "$ASSISTANT_DIR" "$HOME/.claude/CLAUDE.md" 2>/dev/null \
     && ! grep -Fq "~${ASSISTANT_DIR#"$HOME"}" "$HOME/.claude/CLAUDE.md" 2>/dev/null; then
    rm -f "$INPUT_FILE"; exit 0
  fi

  # Detach the worker into its own process session so it survives Claude
  # Code's exit; this hook returns immediately, so quitting never waits.
  python3 - "$0" "$INPUT_FILE" <<'PY' 2>/dev/null
import subprocess, sys
subprocess.Popen(["/bin/bash", sys.argv[1], "--detached", sys.argv[2]],
                 start_new_session=True, stdin=subprocess.DEVNULL,
                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
PY
  exit 0
fi

# ---------- Phase B: detached worker ----------
INPUT_FILE="$2"
TRANSCRIPT="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("transcript_path",""))' "$INPUT_FILE" 2>/dev/null || true)"
SESSION_CWD="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("cwd",""))' "$INPUT_FILE" 2>/dev/null || true)"
rm -f "$INPUT_FILE"

# Keep the log from growing without bound.
if [ -f "$LOG" ] && [ "$(wc -c < "$LOG")" -gt 200000 ]; then
  tail -c 100000 "$LOG" > "$LOG.tmp" 2>/dev/null && mv "$LOG.tmp" "$LOG"
fi

# 1. Auto-commit any uncommitted memory (journal entries, approved edits).
if [ -n "$(git -C "$ASSISTANT_DIR" status --porcelain 2>/dev/null)" ]; then
  if git -C "$ASSISTANT_DIR" add -A >> "$LOG" 2>&1 \
     && git -C "$ASSISTANT_DIR" commit -q -m "Auto-commit at session end (hook)" >> "$LOG" 2>&1; then
    log "auto-committed pending changes"
  else
    log "auto-commit failed (concurrent session end?) — will retry at next session end"
  fi
fi

# 2. Pull the readable conversation out of the JSONL transcript.
[ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ] || { log "no transcript at '$TRANSCRIPT' — skipped"; exit 0; }
CONVO_FILE="$(mktemp "${TMPDIR:-/tmp}/session-end-convo.XXXXXX")" || exit 0
python3 - "$TRANSCRIPT" > "$CONVO_FILE" 2>>"$LOG" <<'PY'
import json, sys

def text_of(content):
    if isinstance(content, str):
        return content
    parts = []
    for block in content or []:
        if isinstance(block, dict) and block.get("type") == "text":
            parts.append(block.get("text", ""))
    return "\n".join(parts)

turns = []
for line in open(sys.argv[1], encoding="utf-8", errors="replace"):
    try:
        d = json.loads(line)
    except json.JSONDecodeError:
        continue
    if d.get("type") not in ("user", "assistant"):
        continue
    msg = d.get("message") or {}
    t = text_of(msg.get("content")).strip()
    if t:
        turns.append(f"{d['type'].upper()}: {t[:4000]}")

out = "\n\n".join(turns)
# Very long sessions: keep the opening and the ending, which carry the
# request and the outcome.
if len(out) > 160000:
    out = out[:50000] + "\n\n[... middle of session omitted ...]\n\n" + out[-110000:]
print(out)
PY

if [ "$(wc -c < "$CONVO_FILE")" -lt 1500 ]; then
  log "conversation too small to journal — skipped"
  rm -f "$CONVO_FILE"
  exit 0
fi

# 3. Draft the proposal. disableAllHooks = loop guard #3 (--bare would be
# tidier but it also skips OAuth login). No tools: the model only returns
# text; this script does all file writes itself.
CLAUDE_BIN="$(command -v claude || echo "$HOME/.npm-global/bin/claude")"
TODAY="$(date +%F)"
# The user's canonical journal domains, if setup recorded them.
DOMAINS="$(grep -i 'journal domains:' "$ASSISTANT_DIR/memory/MEMORY.md" 2>/dev/null | head -1 | sed 's/.*[Dd]omains:[[:space:]]*//')"
PROMPT="You are the background journaler for a personal Claude assistant. Below is the conversation from a Claude Code session that just ended (working directory: ${SESSION_CWD:-unknown}, date: $TODAY). Draft a journal entry of what future sessions would need: outcomes, decisions, open loops.

If there is nothing worth keeping (trivial or purely exploratory chat with no outcomes, or the session already wrote its own journal entry after the user said 'log this session'), output only the line:
NOTHING_TO_LOG

Otherwise output the entry between these exact marker lines (markers alone on their lines, plain text, no bold or extra punctuation):
BEGIN_PROPOSAL
PROJECT: <short-kebab-case-project-name>
### Session summary (auto-drafted)
<concise markdown bullets: outcomes, decisions, open loops>
END_PROPOSAL

Optionally include, before END_PROPOSAL, a '#### Candidate lessons' subsection with at most 3 lessons. Each lesson is four short plain-language lines:
- Scope: GLOBAL (about the user, true across all projects), DOMAIN (one standing domain of the user's work), or LOCAL (this one project only)
- Rule: what a future session should do or avoid, as an imperative
- When: the situation that should trigger the rule
- Why: the concrete mistake it prevents, from this session
Write for a reader who did NOT see this session: no shorthand, no jargon left unexplained, full sentences. A lesson that merely describes what happened, or that can't be made self-explanatory, must be left out.

Rules: infer PROJECT from the working directory and content${DOMAINS:+ — prefer one of these canonical domains when it fits: $DOMAINS}, 'general' if unclear; never invent facts not in the conversation; at most 40 lines between the markers; no text outside the markers."

# One self-contained prompt: instructions, then the transcript between
# markers, then a closing reminder. Splitting them (prompt as argument,
# transcript on stdin) made the model treat the transcript as a message
# to answer rather than data to summarize.
FULL_FILE="$(mktemp "${TMPDIR:-/tmp}/session-end-prompt.XXXXXX")" || { rm -f "$CONVO_FILE"; exit 0; }
{
  printf '%s\n\n=== SESSION TRANSCRIPT START ===\n' "$PROMPT"
  cat "$CONVO_FILE"
  printf '\n=== SESSION TRANSCRIPT END ===\n\nNow reply exactly per the instructions above: either the single line NOTHING_TO_LOG, or the entry between BEGIN_PROPOSAL and END_PROPOSAL markers. No other text.\n'
} > "$FULL_FILE"
rm -f "$CONVO_FILE"

# Parse defensively — small models drift from the format (add preamble,
# bold the markers, emit both formats at once, return nothing). The
# markers decide: BEGIN_PROPOSAL present → it's a proposal (a stray
# NOTHING_TO_LOG elsewhere is ignored); no markers → only then does
# NOTHING_TO_LOG count; neither → retry once, then refuse to file garbage.
BODY=""
for ATTEMPT in 1 2; do
  OUTPUT="$(MY_CLAUDE_ASSISTANT_JOURNALER=1 "$CLAUDE_BIN" -p --model haiku --settings '{"disableAllHooks": true}' < "$FULL_FILE" 2>>"$LOG")" || {
    log "summarizer run failed (attempt $ATTEMPT)"; continue;
  }
  BODY="$(printf '%s\n' "$OUTPUT" | awk '/BEGIN_PROPOSAL/{f=1;next} /END_PROPOSAL/{f=0} f' \
          | grep -v -i '^[*_# ]*PROJECT[:* ]')"
  [ -n "$BODY" ] && break
  if printf '%s' "$OUTPUT" | grep -q 'NOTHING_TO_LOG'; then
    log "nothing to log for session in ${SESSION_CWD:-unknown}"
    rm -f "$FULL_FILE"; exit 0
  fi
  log "summarizer output unparseable (attempt $ATTEMPT); raw head: $(printf '%s' "$OUTPUT" | head -c 400 | tr '\n' ' ')"
done
rm -f "$FULL_FILE"
[ -n "$BODY" ] || { log "giving up on this session — nothing filed"; exit 0; }
PROJECT="$(printf '%s\n' "$OUTPUT" | sed -n 's/^[*_# ]*[Pp][Rr][Oo][Jj][Ee][Cc][Tt][:* ][:* ]*//p' | head -1 \
           | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-*//;s/-*$//')"
[ -n "$PROJECT" ] || PROJECT="general"

# 4. Write the proposal and commit it.
PROPOSAL="$ASSISTANT_DIR/memory/proposals/$(date +%F-%H%M%S)-$PROJECT.md"
{
  echo "# Journal proposal — pending review"
  echo "- Session ended: $(date '+%F %T') (cwd: ${SESSION_CWD:-unknown})"
  echo "- Proposed destination: memory/journal/$PROJECT/sessions/$TODAY.md"
  echo "  (a suggestion — confirm or re-route at review)"
  echo "- Auto-drafted by the session-end hook; nothing files itself —"
  echo "  approve, edit, or reject via \"review proposals\"."
  echo
  printf '%s\n' "$BODY"
} > "$PROPOSAL"

if git -C "$ASSISTANT_DIR" add "$PROPOSAL" >> "$LOG" 2>&1 \
   && git -C "$ASSISTANT_DIR" commit -q -m "Proposal: session in ${PROJECT} ($TODAY)" >> "$LOG" 2>&1; then
  log "proposal written and committed: ${PROPOSAL##*/}"
else
  log "proposal written (commit failed, will be swept up next session end): ${PROPOSAL##*/}"
fi
exit 0
